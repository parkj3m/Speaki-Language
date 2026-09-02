%{
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "defines.h"
#include "spki.tab.h"

const char *lex_err_msg = "Lexical Error: Line %d\n";

%}

SPACE [ \t]+
NUMBER 0|[1-9][0-9]*
IDENTIFIER [a-zA-Z][a-zA-Z_0-9]*
COMMENT "없는거예요!"[^\n]*
STRINGDEF (\"([^\"\\]|\\.)*\")|(\'([^\'\\]|\\.)*\')

%option never-interactive
%option yylineno
%option noyywrap

%%
 /* Keywords */
"def" { return DEF; }
"enddef" { return ENDDEF; }
"return" { return RETURN; }

"if" { return IF; }
"elif" { return ELIF; }
"else" { return ELSE; }
"endif" { return ENDIF; }

"while" { return WHILE; }
"endwhile" { return ENDWHILE; }

"foreach" { return FOREACH; }
"in" { return IN; }
"endforeach" { return ENDFOREACH; }

"print" { return PRINT; }

 /* Math */
"==" { return EQ; }
"!=" { return NE; }
"<=" { return LE; }
">=" { return GE; }
"<" { return LT; }
">" { return GT; }

"+=" { return PLUSEQ; }
"-=" { return MINUSEQ; }
"*=" { return MULEQ; }
"/=" { return DIVEQ; }

"=" { return IS; }
"+" { return PLUS; }
"-" { return MINUS; }
"*" { return MUL; }
"/" { return DIV; }
"%" { return MOD; }

"(" { return LPAREN; }
")" { return RPAREN; }

 /* Other */

":" { return COLON; }
"," { return COMMA; }
";" { return SEMICOLON; }

{NUMBER} {
    yylval.ival = atoi(yytext); 
    return INT;
}
{IDENTIFIER} {
    char* sval = (char*)malloc(sizeof(char) * IDMAX);
    if(sval == NULL) {
        fprintf(stderr, "Could not allocate memory!\n");
        exit(2);
    }
    strcpy(sval, yytext);
    yylval.sval = sval;
    return ID;
}
{STRINGDEF} {
    int len = strlen(yytext);

    char* str = (char*)malloc(sizeof(char) * (len + 1));
    if(str == NULL) {
        fprintf(stderr, "Could not allocate memory!\n");
        exit(2);
    }

    strcpy(str, yytext);
    str[len] = '\0';

    yylval.sval = str;

    return STRING;
}


{SPACE} { ; }
{COMMENT} { ; }
\n { ; }

. 	{ 
 	    fprintf(stderr, lex_err_msg, yylineno); 
	    exit(-1);
	}



%%
