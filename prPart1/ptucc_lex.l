%{
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "ptucc_parser.tab.h" 
#include "cgen.h"

int line_num = 1;


/* 
	A primitive macro facility:
	just one macro is allowed to be defined! 
*/
#define MAXMACRO 32
char* mactable[MAXMACRO][2];
int mactable_size = 0;

/* Return 1 on success, 0 on failure (macro table full) */
int set_macro(char* name, char* def);

/* Return def for macro, or NULL if no such macro is defined. */
char* get_macro(char* name);

%}

ID [a-zA-Z_][0-9a-zA-Z_]*
DIGIT  [0-9]
NUMBER  {DIGIT}{DIGIT}*
DECIMAL ("."{NUMBER})|({NUMBER}("."{NUMBER}?)?)
REAL    {DECIMAL}([eE][+-]?{NUMBER})?
STRING ([\']([^\n'"\\]|([\\][n]|[\\][t]|[\\][r]|[\\][\\]|[\\][']|[\\]["]))+[\'])|([\"]([^\n'"\\]|([\\][n]|[\\][t]|[\\][r]|[\\][\\]|[\\][']|[\\]["]))+[\"])
ONE_LINE_COMMENT [\/][\/](.)*
BOOLEAN_CONSTANT (?i:true)|(?i:false)
DATATYPE [\()]((?i:integer)|(?i:boolean)|(?i:char)|(?i:real))[\)]


%x comment
%x macro

%%

@defmacro[ \r\t]+       {BEGIN(macro);line_num++;}
<macro>{ID}             {
							/* Store macro name */
							char* name = strdup(yytext);
							char* def = NULL;
							size_t deflen = 0;
							char c;
							
							FILE* deff = open_memstream(&def, &deflen);

							while((c=input())!='\n')
							   fputc(c, deff);
							fclose(deff);

							if(!set_macro(name, def)) {
								yyerror("lexer error: failed to define macro '%s'\n", name); 
								printf("lexer error: failed to define macro %s\n", name);
							}
							BEGIN(INITIAL);
						};

program					{
							printf("TOKEN KEYWORD_PROGRAM: %s\n", yytext);
							return KW_PROGRAM;
						}
							
begin 					{ 
							printf("TOKEN KEYWORD_BEGIN: %s\n", yytext);
							return KW_BEGIN;
						}
						
end						{
							printf("TOKEN KEYWORD_END: %s\n", yytext);
							return KW_END;
						}
						
and						{
							printf("TOKEN KEYWORD_AND: %s\n", yytext);
							return KW_AND;
						}
						
div						{
							printf("TOKEN KEYWORD_DIV: %s\n", yytext);
							return KW_DIV;
						}
						
function				{
							printf("TOKEN KEYWORD_FUNCTION: %s\n", yytext);
							return KW_FUNCTION;
						}
mod						{
							printf("TOKEN KEYWORD_MOD: %s\n", yytext);
							return KW_MOD;
						}
						
procedure				{
							printf("TOKEN KEYWORD_PROCEDURE: %s\n", yytext);
							return KW_PROC;
						}
						
result					{
							printf("TOKEN KEYWORD_RESULT: %s\n", yytext);
							return KW_RESULT;
						}
						
array					{
							printf("TOKEN KEYWORD_ARRAY: %s\n", yytext);
							return KW_ARRAY;
						}
						
do						{
							printf("TOKEN KEYWORD_DO: %s\n", yytext);
							return KW_DO;
						}
						
goto					{
							printf("TOKEN KEYWORD_GOTO: %s\n", yytext);
							return KW_GOTO;
						}
						
not						{
							printf("TOKEN KEYWORD_NOT: %s\n", yytext);
							return KW_NOT;
						}
						
return					{
							printf("TOKEN KEYWORD_RETURN: %s\n", yytext);
							return KW_RETURN;
						}
						
boolean					{
							printf("TOKEN KEYWORD_BOOLEAN: %s\n", yytext);
							return KW_BOOLEAN;
						}
						
else					{
							printf("TOKEN KEYWORD_ELSE: %s\n", yytext);
							return KW_ELSE;
						}
if						{
							printf("TOKEN KEYWORD_IF: %s\n", yytext);
							return KW_IF;
						}
						
of						{
							printf("TOKEN KEYWORD_OF: %s\n", yytext);
							return KW_OF;
						}
							
real					{
							printf("TOKEN KEYWORD_REAL: %s\n", yytext);
							return KW_REAL;
						}
						
then					{
							printf("TOKEN KEYWORD_THEN: %s\n", yytext);
							return KW_THEN;
						}
							
char					{
							printf("TOKEN KEYWORD_CHAR: %s\n", yytext);
							return KW_CHAR;
						}
						
for						{
							printf("TOKEN KEYWORD_FOR: %s\n", yytext);
							return KW_FOR;
						}
							
integer					{
							printf("TOKEN KEYWORD_INTEGER: %s\n", yytext);
							return KW_INTEGER;
						}
							
or						{
							printf("TOKEN KEYWORD_OR: %s\n", yytext);
							return KW_OR;
						}
										
repeat					{
							printf("TOKEN KEYWORD_REPEAT: %s\n", yytext);
							return KW_REPEAT;
						}
											
until					{
							printf("TOKEN KEYWORD_UNTIL: %s\n", yytext);
							return KW_UNTIL;
						}
						
var						{
							printf("TOKEN KEYWORD_VAR: %s\n", yytext);
							return KW_VAR;
						}
										
while					{
							printf("TOKEN KEYWORD_WHILE: %s\n", yytext);
							return KW_WHILE;
						}
									
to						{
							printf("TOKEN KEYWORD_TO: %s\n", yytext);
							return KW_TO;
						}
						
downto					{
							printf("TOKEN KEYWORD_DOWNTO: %s\n", yytext);
							return KW_DOWNTO;
						}

writeString				{
							printf("TOKEN KEYWORD_WRITE_STRING: %s\n", yytext);
							return KW_WRITE_STRING;
						}

writeReal				{
							printf("TOKEN KEYWORD_WRITE_REAL: %s\n", yytext);
							return KW_WRITE_REAL;
						}

writeInteger				{
							printf("TOKEN KEYWORD_WRITE_INTEGER: %s\n", yytext);
							return KW_WRITE_INTEGER;
						}

{DATATYPE} 				{
							printf("TOKEN DATATYPE_CASTING: %s\n", yytext);
							return DATATYPE_CASTING;
						}

						
{BOOLEAN_CONSTANT}		{
							printf("TOKEN BOOLEAN_CONSTANT: %s\n", yytext);
							return BOOLEAN_CONSTANT;
						}

					
{ID}  					{
						   char* def = get_macro(yytext);
						   if(def==NULL) {
						   		/* yylval.crepr = strdup(yytext); */
						   		printf("TOKEN IDENTIFIER: %s\n", yytext);
						   		return IDENT;
						   }
						   else {	
							   for(int i=strlen(def); i>0; i--) {
								  unput(def[i-1]);
							   }
						   }
						} 
											
{NUMBER}				{
							/* yylval.crepr = strdup(yytext); */
							printf("TOKEN POSITIVE_INTEGER: %d\n", atoi(yytext));
							return POSINT;
						}
{REAL}					{
							/* yylval.crepr = strdup(yytext); */
							printf("TOKEN REAL: %f\n", atof(yytext));
							return REAL;
						}
						
{STRING}				{
							/* yylval.crepr = strdup(yytext); */
							printf("TOKEN STRING: %s\n", yytext);
							return STRING;
						}		
	
":="					{
							printf("TOKEN OP_ASSIGNMENT: %s\n", yytext);
							return OP_ASSIGNMENT;
						}

"+"						{
							printf("TOKEN OP_PLUS: %s\n", yytext);
							return OP_PLUS;
						}
						
"-"						{
							printf("TOKEN OP_MINUS: %s\n", yytext);
							return OP_MINUS;
						}

"*"						{
							printf("TOKEN OP_MULT: %s\n", yytext);
							return OP_MULT;
						}
						
"/"						{
							printf("TOKEN OP_DIVIDE: %s\n", yytext);
							return OP_DIVIDE;
						}
						
">"						{
							printf("TOKEN OP_BIGGER: %s\n", yytext);
							return OP_BIGGER;
						}
						
"<"						{
							printf("TOKEN OP_SMALLER: %s\n", yytext);
							return OP_SMALLER;
						}
						
"<>"					{
							printf("TOKEN OP_DIFFERENT: %s\n", yytext);
							return OP_DIFFERENT;
						}
						
"="						{
							printf("TOKEN OP_EQUAL: %s\n", yytext);
							return OP_EQUAL;
						}
						
"<="					{
							printf("TOKEN OP_SMALLER_EQUAL: %s\n", yytext);
							return OP_SMALLER_EQUAL;
						}
						
">="					{
							printf("TOKEN OP_BIGGER_EQUAL: %s\n", yytext);
							return OP_BIGGER_EQUAL;
						}
						
"!"						{
							printf("TOKEN OP_LOGICAL_NOT: %s\n", yytext);
							return OP_LOGICAL_NOT;
						}
						
"&&"					{
							printf("TOKEN OP_LOGICAL_AND: %s\n", yytext);
							return OP_LOGICAL_AND;
						}
						
"||"					{
							printf("TOKEN OP_LOGICAL_OR: %s\n", yytext);
							return OP_LOGICAL_OR;
						}																																																																												
						
";"						{
							printf("TOKEN SEMICOLON: %s\n", yytext);
							return OP_SEMICOLON;
						}
						
"."						{
							printf("TOKEN DOT: %s\n", yytext);
							return OP_DOT;
						}
						
","						{
							printf("TOKEN COMMA: %s\n", yytext);
							return OP_COMMA;
						}
						
"("						{
							printf("TOKEN LEFT_PARENTHESIS: %s\n", yytext);
							return OP_LEFT_PARENTHESIS;
						}
						
")"						{
							printf("TOKEN RIGHT_PARENTHESIS: %s\n", yytext);
							return OP_RIGHT_PARENTHESIS;
						}
						
"["						{
							printf("TOKEN LEFT_BRACKET: %s\n", yytext);
							return OP_LEFT_BRACKET;
						}
						
"]"						{
							printf("TOKEN RIGHT_BRACKET: %s\n", yytext);
							return OP_RIGHT_BRACKET;
						}
						
":"						{
							printf("TOKEN COLON: %s\n", yytext);
							return OP_COLON;
						}

"(*"					BEGIN(comment);
<comment>[^*\n]*        /* eat anything that's not a '*' */
<comment>"*"+[^*)\n]*   /* eat up '*'s not followed by ')'s */
{ONE_LINE_COMMENT}		{
							/*  eat up one line comment */
							++line_num;
						}
<comment>\n             ++line_num;
<comment>"*"+")"		BEGIN(INITIAL);

[ \r\t]					/* skip whitespace */
\n 						++line_num;
<<EOF>> 				{
							return EOF;
						}

.        {
			/* yyerror("lexical error: unrecognized literal '%s'\n", yytext); */
			printf("Unrecognized token %s in line %d\n", yytext, line_num);
			return EOF;
		 }


%%

int set_macro(char* name, char* def)
{
	/* Check to see if macro already defined, and redefine it. */
	int i;
	for(i=0; i<mactable_size; i++) {
		if(strcmp(mactable[i][0], name)==0) {
			/* found ! */
			free(name);
			free(mactable[i][1]);
			mactable[i][1] = def;
			break;
		}
	}
	if(i<mactable_size)
		return 1;
	else if(mactable_size < MAXMACRO) {
		/* new entry */
		assert(i==mactable_size);
		mactable[i][0] = name;
		mactable[i][1] = def;
		mactable_size++;
		return 1;
	}
	else
		return 0;
}

char* get_macro(char* name)
{
	for(int i=0;i<mactable_size; i++) {
		if(strcmp(mactable[i][0], name)==0)
			return mactable[i][1];
	}
	return NULL;
}


