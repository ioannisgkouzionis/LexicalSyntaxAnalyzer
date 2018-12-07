%{
#include <stdarg.h>
#include <stdio.h>	
#include "cgen.h"
#include <string.h>
extern int yylex(void);
extern char* yytext;
extern int line_num;
%}

%union
{
	char* crepr;
}

%token <crepr> IDENT
%token <crepr> POSINT 
%token <crepr> REAL 
%token <crepr> STRING
%token <crepr> BOOLEAN_CONSTANT 
%token <crepr> DATATYPE_CASTING 

%token OP_ASSIGNMENT 336
%token OP_PLUS 337
%token OP_MINUS 338
%token OP_MULT 339
%token OP_DIVIDE 340
%token OP_BIGGER 341
%token OP_SMALLER 342
%token OP_DIFFERENT 343
%token OP_EQUAL 344
%token OP_SEMICOLON 345
%token OP_DOT 346
%token OP_COMMA 347
%token OP_COLON 348
%token OP_SMALLER_EQUAL 349
%token OP_BIGGER_EQUAL 351
%token OP_LOGICAL_NOT 352
%token OP_LOGICAL_AND 353
%token OP_LOGICAL_OR 354
%token OP_LEFT_PARENTHESIS 355
%token OP_RIGHT_PARENTHESIS 356
%token OP_LEFT_BRACKET 357
%token OP_RIGHT_BRACKET 358

%token KW_PROGRAM 300
%token KW_BEGIN 301
%token KW_END 302
%token KW_AND 308
%token KW_DIV 309
%token KW_FUNCTION 310
%token KW_MOD 311
%token KW_PROC 312
%token KW_RESULT 313
%token KW_ARRAY 314
%token KW_DO 315
%token KW_GOTO 316
%token KW_NOT 317
%token KW_RETURN 318
%token KW_BOOLEAN 319
%token KW_ELSE 320
%token KW_IF 321
%token KW_OF 322
%token KW_REAL 323
%token KW_THEN 324
%token KW_CHAR 325
%token KW_FOR 326
%token KW_INTEGER 327
%token KW_OR 328
%token KW_REPEAT 329
%token KW_UNTIL 330
%token KW_VAR 331
%token KW_WHILE 332
%token KW_TO 333
%token KW_DOWNTO 334

%left OP_LOGICAL_OR KW_OR
%left OP_LOGICAL_AND KW_AND
%left OP_EQUAL OP_DIFFERENT OP_SMALLER OP_BIGGER OP_SMALLER_EQUAL OP_BIGGER_EQUAL
%right OP_PLUS OP_MINUS
%left OP_MULT OP_DIVIDE KW_DIV KW_MOD
%right KW_NOT OP_LOGICAL_NOT

%left OP_LEFT_PARENTHESIS
%right OP_RIGHT_PARENTHESIS
%left OP_COMMA OP SEMICOLON
%right KW_THEN  KW_ELSE 
%left OP_ASSIGNMENT



%start program

%type <crepr> program_decl variables variables2 variables3 data_Type all_data_types array_1_or_multi_dimension dimension temp_type     pos_int real_num Str bool_const proc_func_decl proc_body id 

%type <crepr>  proc_call arguments
%type <crepr> arglist /*expression*/
%type <crepr> proc_statements proc_statement_list proc_statement proc_statement_2 proc_var_args 
%type <crepr> proc_expr proc_expr_type1 proc_expr_type2 proc_expr_type3 
%type <crepr> command_assignment command_return command_goto command_for command_repeat command_while command_if goto_label label command_result
%%
program:  program_decl  variables  proc_func_decl  proc_body OP_DOT
{ 
	/* We have a successful parse! 
		Check for any errors and generate output. 
	*/
	if(yyerror_count==0) {
		printf("\n \n /* This is the program transformed by our ptuc parser */ \n");
		puts(c_prologue);
		printf("/* program  %s */ \n\n", $1);
		printf("%s \n",$2);
		printf("%s \n",$3);
		printf("int main()\n{ %s \n}\n", $4);
	}
};


program_decl : KW_PROGRAM id OP_SEMICOLON  	{ $$ = $2; };

id: IDENT {$$=strdup(yytext);};
pos_int :POSINT {$$=strdup(yytext);};
real_num:REAL {$$=strdup(yytext);};
Str:STRING {$$=strdup(yytext);};
bool_const:BOOLEAN_CONSTANT{
	$$=strdup(yytext);
  	if(strlen($$)==4) $$=template("%d",1);
 	else  $$=template("%d",0);  
  };

all_data_types : /* no type declaration*/ {$$=template("");}
		|data_Type   {$$=template("%s",$1);}
		|array_1_or_multi_dimension  {$$=template("%s",$1);};
		

array_1_or_multi_dimension :KW_ARRAY dimension KW_OF data_Type  {if (strlen($2)>1) $$=template("%s  %s",$4,$2); else $$=template("%s *",$4) ;}
			|  KW_ARRAY dimension KW_OF id {if (strlen($2)>1) $$=template("%s  %s",$4,$2);else $$=template("%s * ",$4);};

dimension : /* array of unknown number of elements */ {$$="";}
	 | OP_LEFT_BRACKET temp_type OP_RIGHT_BRACKET dimension {$$=template("[%s]%s",$2,$4);};
	 

temp_type:id {$$=template("%s",$1); }
	|pos_int {$$=template("%s",$1); };

data_Type : KW_INTEGER {$$ = template("int");}
	 | KW_BOOLEAN {$$ = template("int");}
	 | KW_CHAR    {$$ = template("char");}
	 | KW_REAL    {$$ = template("double");};


proc_call: id OP_LEFT_PARENTHESIS arguments OP_RIGHT_PARENTHESIS proc_expr_type2{ $$ = template("%s(%s)%s", $1, $3,$5); };

arguments :									{ $$ = ""; }
	 	  | arglist 						{ $$ = $1; };

arglist: proc_expr							{ $$ = $1; }
       | arglist  OP_COMMA proc_expr 			{ $$ = template("%s,%s", $1, $3);};


/*------------------------variables---------------------------*/
variables:/**/ {$$=template("");}
|KW_VAR id variables2 OP_COLON all_data_types OP_SEMICOLON variables3 variables   {$$=template("%s %s %s;\n%s%s ",$5,$2,$3,$7,$8);};

variables2:/*no variables*/ {$$=template("");}
|OP_COMMA id variables2 {$$=template(",%s%s",$2,$3);};

variables3:/**/ {$$=template("");}
|id variables2 OP_COLON all_data_types OP_SEMICOLON variables3 {$$=template("%s %s %s;\n%s",$4,$1,$2,$6);};

/*--------------------------procedure-function----------------*/
proc_func_decl : /**/ 	{ $$ = ""; }
			   
| KW_PROC id OP_LEFT_PARENTHESIS proc_var_args OP_RIGHT_PARENTHESIS OP_SEMICOLON variables proc_func_decl proc_body OP_SEMICOLON proc_func_decl 
{ $$ = template("\nvoid %s(%s);\n {\n  %s %s\n   %s\n}\n%s",$2,$4,$7,$8,$9,$11); }
| KW_FUNCTION id OP_LEFT_PARENTHESIS proc_var_args OP_RIGHT_PARENTHESIS OP_COLON all_data_types  OP_SEMICOLON  variables proc_func_decl proc_body OP_SEMICOLON proc_func_decl 
{ $$ = template("\n%s %s(%s){\n %s %s %s \nreturn result;\n}\n%s",$7,$2,$4,$9,$10,$11,$13); };

	     



proc_var_args: /* no variables declaration */ { $$ = template(""); }
		| id variables2 OP_COLON all_data_types proc_var_args { $$ = template("%s %s%s %s",$4,$1,$2,$5); }
		| id variables2 OP_COLON all_data_types OP_SEMICOLON proc_var_args { $$ = template("%s %s%s ; %s",$4,$1,$2,$6); }
		| id variables2 OP_COLON all_data_types OP_SEMICOLON OP_RIGHT_PARENTHESIS proc_var_args { $$ = template("%s %s%s ; %s",$4,$1,$2,$7); };

proc_body:KW_BEGIN proc_statements KW_END {$$ = template("  \n %s\n  ", $2);};
proc_statements: { $$ = ""; };
proc_statements: proc_statement_list { $$ = $1; };
proc_statement_list: proc_statement   {$$=template("%s",$1);}                  
	   	   | proc_statement_list OP_SEMICOLON proc_statement  { $$ = template(" %s\n%s", $1, $3); }; 
proc_statement:command_assignment  {$$=template("   %s",$1);}
	      |command_result 	  {$$=template("   %s",$1);}
	      |proc_call 	  {$$=template("   %s;",$1);}
	      |command_repeat	  {$$=template("   %s",$1);}
	      |command_while	  {$$=template("   %s",$1);}
	      |command_for	  {$$=template("   %s",$1);}	     
	      |command_if	  {$$=template("   %s",$1);}
	      |command_return	  {$$=template("   %s",$1);}
	      |command_goto	  {$$=template("   %s",$1);}
	      |goto_label	  {$$=template("   %s",$1);};

proc_statement_2:proc_body {$$=template("{ %s }",$1);}
	       |proc_statement  {$$=template("  %s",$1);};

command_if:KW_IF proc_expr KW_THEN proc_statement_2 {$$=template("if (%s)\n   %s\n",$2,$4);}
	  |KW_IF proc_expr KW_THEN proc_statement_2 KW_ELSE proc_statement_2 {$$=template("if (%s)\n   %s\nelse    %s\n",$2,$4,$6);};

command_repeat:KW_REPEAT proc_statement_2 KW_UNTIL proc_expr {$$=template("do\n   %s\n while (%s)",$2,$4);};
command_while:KW_WHILE proc_expr KW_DO proc_statement_2 {$$=template("while(%s)\n    %s",$2,$4);};


command_goto: KW_GOTO id {$$=template("goto %s;\n",$2);};


command_return : KW_RETURN {$$=template("return 0;\n");};
command_assignment : id proc_expr_type3 OP_ASSIGNMENT proc_expr {$$=template("%s%s=%s;\n",$1,$2,$4);};

command_for: KW_FOR id proc_expr_type1 OP_ASSIGNMENT proc_expr KW_TO proc_expr KW_DO proc_statement_2 
			{ $$ = template("for(%s%s = %s; %s%s <= %s; %s%s ++ )\n   %s\n",$2,$3,$5,$2,$3,$7,$2,$3,$9); }
	  | KW_FOR id proc_expr_type1 OP_ASSIGNMENT proc_expr KW_DOWNTO proc_expr KW_DO proc_statement_2
			{ $$ = template("for(%s%s = %s; %s%s >= %s; %s%s -- )\n   %s\n",$2,$3,$5,$2,$3,$7,$2,$3,$9); };
goto_label:id OP_COLON label {$$=template("%s : %s;\n",$1,$3);};

command_result: KW_RESULT OP_ASSIGNMENT proc_expr {$$=template("result=%s;\n",$3);};



label:/* */ {$$=template("");}
     |proc_body {$$=template("%s",$1);}
     |proc_statement {$$=template("%s",$1);};

proc_expr:/* no expressions*/ {$$=template("");}
	| Str   {$$=string_ptuc2c($1);}
	| pos_int  {$$=template("%s",$1);}
	| real_num 	   {$$=template("%s",$1);}
	| bool_const {$$=template("%s",$1);}
	| id	   {$$=template("%s",$1);}
	| OP_LEFT_PARENTHESIS proc_expr OP_RIGHT_PARENTHESIS {$$=template("(%s)",$2);}
	| proc_expr OP_PLUS proc_expr {$$=template("%s + %s",$1,$3);}
	| proc_expr OP_MINUS proc_expr {$$=template("%s - %s",$1,$3);}
	| proc_expr OP_MULT proc_expr  {$$=template("%s * %s",$1,$3);}
	| proc_expr OP_DIVIDE proc_expr  {$$=template("%s / %s",$1,$3);}
        | proc_expr KW_DIV proc_expr  {$$=template("int(%s/%s)",$1,$3);}
	| proc_expr KW_MOD proc_expr  {$$=template("%s %% %s",$1,$3);}
	| proc_expr OP_LOGICAL_AND proc_expr  {$$=template("%s && %s",$1,$3);}
	| proc_expr KW_AND proc_expr  {$$=template("%s && %s",$1,$3);}
	| proc_expr OP_LOGICAL_OR proc_expr  {$$=template("%s || %s",$1,$3);}
	| proc_expr KW_OR proc_expr  {$$=template("%s || %s",$1,$3);}
	| proc_expr OP_EQUAL proc_expr  {$$=template("%s = %s",$1,$3);}
	| proc_expr OP_BIGGER proc_expr  {$$=template("%s > %s",$1,$3);}
	| proc_expr OP_SMALLER proc_expr  {$$=template("%s < %s",$1,$3);}
	| proc_expr OP_DIFFERENT proc_expr  {$$=template("%s != %s",$1,$3);}
	| proc_expr OP_BIGGER_EQUAL proc_expr  {$$=template("%s >= %s",$1,$3);}
	| proc_expr OP_SMALLER_EQUAL proc_expr  {$$=template("%s <= %s",$1,$3);}
	| OP_LOGICAL_NOT proc_expr  {$$=template("! %s",$2);}
	| KW_NOT proc_expr  {$$=template("! %s",$2);}
	| OP_PLUS  proc_expr  {$$=template("(+ %s)",$2);}
	| OP_MINUS proc_expr   {$$=template("(- %s)",$2);}
	| id OP_LEFT_PARENTHESIS proc_expr_type1 OP_RIGHT_PARENTHESIS proc_expr_type2 {$$=template("%s(%s)%s",$1,$3,$5);}
	| id OP_LEFT_BRACKET proc_expr OP_RIGHT_BRACKET proc_expr_type3 {$$=template("%s[%s]%s",$1,$3,$5);};


proc_expr_type1:proc_expr {$$=template("%s",$1);}
		| proc_expr_type1 OP_COMMA proc_expr_type1 {$$=template("%s , %s",$1,$3);};

proc_expr_type2:/*no expressions*/ {$$=template("");}
		|OP_LEFT_PARENTHESIS proc_expr_type1 OP_RIGHT_PARENTHESIS proc_expr_type2 {$$=template("(%s)%s",$2,$4);};

proc_expr_type3:/*no expressions*/ {$$=template("");}
		|OP_LEFT_BRACKET proc_expr OP_RIGHT_BRACKET proc_expr_type3 {$$=template("[%s]%s",$2,$4);};
%%

