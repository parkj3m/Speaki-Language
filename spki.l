%{
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "defines.h"
#include "spki.tab.h"

const char *lex_err_msg = "아앗, 실패했어요... :  줄 %d을/를 확인해보세요!\n";

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
"스피키가" { return DEF; }
"해볼게요!" { return ENDDEF; }
"얍!" { return RETURN; }

"조아요," { return IF; }
"조아요" { return ELIF; }
"물걸레질" { return ELSE; }
"조아요!" { return ENDIF; }

"흐에엥," { return WHILE; }
"에으응!" { return ENDWHILE; }

"쪼아요쪼아요," { return FOREACH; }
"호박이" { return IN; }
"쪼아요!" { return ENDFOREACH; }

"보여드릴게요!" { return PRINT; }

 /* Math */
"같은거예요!" { return EQ; }
"다른거예요!" { return NE; }
"작거나같은거예요!" { return LE; }
"크거나같은거예요!" { return GE; }
"작은거예요!" { return LT; }
"큰거예요!" { return GT; }

"더해지는거예요!" { return PLUSEQ; }
"빼지는거예요!" { return MINUSEQ; }
"곱해지는거예요!" { return MULEQ; }
"나눠지는거예요!" { return DIVEQ; }

"는요" { return IS; }

"더하는거예요!" { return PLUS; }
"빼는거예요!" { return MINUS; }
"곱하는거예요!" { return MUL; }
"나누는거예요!" { return DIV; }
"나머지예요!" { return MOD; }

"(" { return LPAREN; }
")" { return RPAREN; }

 /* Other */

",," { return COLON; }
"," { return COMMA; }
"!" { return SEMICOLON; }

{NUMBER} {
    yylval.ival = atoi(yytext); 
    return INT;
}
{IDENTIFIER} {
    char* sval = (char*)malloc(sizeof(char) * IDMAX);
    if(sval == NULL) {
        fprintf(stderr, "스피키 역부족이었나봐요!");
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
        fprintf(stderr, "스피키 역부족이었나봐요!");
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
