%{
#include <stdarg.h>
#include <stdio.h>	
#include "cgen.h"

extern int yylex(void);
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
%token KW_WRITE_STRING 367
%token KW_WRITE_REAL 368
%token KW_WRITE_INTEGER 369

%start program

%type <crepr> program_decl body statements statement_list
%type <crepr> statement proc_call arguments
%type <crepr> arglist expression

%%

program:  program_decl body  '.'   		
{ 
	/* We have a successful parse! 
		Check for any errors and generate output. 
	*/
	if(yyerror_count==0) {
		puts(c_prologue);
		printf("/* program  %s */ \n\n", $1);
		printf("int main() %s \n", $2);
	}
};


program_decl : KW_PROGRAM IDENT ';'  	{ $$ = $2; };

body : KW_BEGIN statements KW_END   	{ $$ = template("{\n %s \n }\n", $2); };

statements: 				        	{ $$ = ""; };
statements: statement_list		   		{ $$ = $1; };

statement_list: statement                     
			  | statement_list ';' statement  { $$ = template("%s%s", $1, $3); }; 


statement: proc_call  						{ $$ = template("%s;\n", $1); };

proc_call: IDENT '(' arguments ')' 			{ $$ = template("%s(%s)", $1, $3); };

arguments :									{ $$ = ""; }
	 	  | arglist 						{ $$ = $1; };

arglist: expression							{ $$ = $1; }
       | arglist ',' expression 			{ $$ = template("%s,%s", $1, $3);  };

expression: POSINT 							/* Default action: $$ = $1 */
          | REAL							
          | STRING 							{ $$ = string_ptuc2c($1); };

%%

