%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "defines.h"

extern int yylineno;
int yyerror(const char *s);
extern int yylex();

const char *pass_msg = "스피키! 대성공!\n\n";
const char *syn_err_msg = "네르가 진거니까 네르를 탓하세요! 줄 %d을/를 확인해보세요!\n\n";

int scope_level = 0;

void add_indent() {
    for(int i = 0; i < scope_level; i++) {
        printf("    ");        
    }
}

char* cpy_str(char* str) {
    char* cpyd_str = (char*)malloc(sizeof(char) * IDMAX);
    if(cpyd_str == NULL) {
        fprintf(stderr, "스피키 역부족이었나봐요!");
        exit(2);
    }
    strcpy(cpyd_str, str);

    return cpyd_str;
}

char* cat_str(char* a, char* b, char* c) {
    int a_len = strlen(a);
    int b_len = strlen(b);
    int c_len = strlen(c);

    // "a b c\0"
    char* catd_str = (char*)malloc(sizeof(char) * (a_len + 1 + b_len + 1 + c_len + 1));
    if(catd_str == NULL) {
        fprintf(stderr, "스피키 역부족이었나봐요!");
        exit(2);
    }

    strcpy(catd_str, a);
    catd_str[a_len] = ' ';
    catd_str[a_len + 1] = '\0';

    strcat(catd_str, b);
    catd_str[a_len + 1 + b_len] = ' ';
    catd_str[a_len + 1 + b_len + 1] = '\0';

    strcat(catd_str, c);
    catd_str[a_len + 1 + b_len + 1 + c_len] = '\0';

    return catd_str;
}

char* cat_paren(char* str) {
    int len = strlen(str);
    
    // "(str)\0"
    char* catd_paren = (char*)malloc(sizeof(char) * (len + 3));
    if(catd_paren == NULL) {
        fprintf(stderr, "스피키 역부족이었나봐요!");
        exit(2);
    }
    
    catd_paren[0] = '(';
    catd_paren[1] = '\0';

    strcat(catd_paren, str);
    catd_paren[len + 1] = ')';
    catd_paren[len + 2] = '\0';

    return catd_paren;
}

char* func_call(char* func_name, char* args) {
    int func_len = strlen(func_name);
    int args_len = strlen(args);

    // "func_name(args)\0"
    char* func_calld_str = (char*)malloc(sizeof(char) * (func_len + 1 + args_len + 1 + 1));
    if(func_calld_str == NULL) {
        fprintf(stderr, "스피키 역부족이었나봐요!");
        exit(2);
    }
    
    strcpy(func_calld_str, func_name);
    func_calld_str[func_len] = '(';
    func_calld_str[func_len + 1] = '\0';

    strcat(func_calld_str, args);
    func_calld_str[func_len + 1 + args_len] = ')';
    func_calld_str[func_len + 1 + args_len + 1] = '\0';

    return func_calld_str;
}

%}

%union {
    int ival;
    char* sval;
}

%token DEF ENDDEF RETURN IF ELIF ELSE ENDIF WHILE ENDWHILE FOREACH IN ENDFOREACH PRINT
%token EQ NE LE GE LT GT IS PLUS MINUS MUL DIV MOD PLUSEQ MINUSEQ MULEQ DIVEQ
%token LPAREN RPAREN
%token COLON COMMA SEMICOLON
%token <ival> INT
%token <sval> ID
%token <sval> STRING

%left PLUS MINUS
%left MUL DIV MOD
%right NEG
%nonassoc EQ NE LE GE LT GT

%type <sval> exp arg_list arg_list_p param_list param_list_p

%%

program         : func_list stmt_list
                ;

func_list       : func_list func_def
                | %empty
                ;

stmt_list       : stmt_list stmt
                | %empty
                ;

stmt            : simple_stmt
                | if_stmt
                | while_stmt
                | foreach_stmt
                ;

simple_stmt     : assign_stmt SEMICOLON
                | print_stmt SEMICOLON
                | return_stmt SEMICOLON
                | exp SEMICOLON {
                    add_indent();
                    printf("%s\n", $1);

                    free($1);
                }
                ;

assign_stmt     : ID IS exp {
                    add_indent();
                    printf("%s = %s\n", $1, $3);

                    free($1);
                    free($3);
                }
                | ID PLUSEQ exp {
                    add_indent();
                    printf("%s += %s\n", $1, $3);

                    free($1);
                    free($3);
                }
                | ID MINUSEQ exp {
                    add_indent();
                    printf("%s -= %s\n", $1, $3);

                    free($1);
                    free($3);
                }
                | ID MULEQ exp {
                    add_indent();
                    printf("%s *= %s\n", $1, $3);

                    free($1);
                    free($3);
                }
                | ID DIVEQ exp {
                    add_indent();
                    printf("%s /= %s\n", $1, $3);

                    free($1);
                    free($3);
                }
                ;

print_stmt      : PRINT LPAREN arg_list RPAREN {
                    add_indent();
                    printf("print(%s)\n", $3);

                    free($3);
                }
                ;

return_stmt     : RETURN {
                    add_indent();
                    printf("return\n");
                }
                | RETURN exp {
                    add_indent();
                    printf("return %s\n", $2);

                    free($2);
                }
                ;

if_stmt         : IF exp COLON {
                    add_indent();
                    printf("if %s:\n", $2);

                    free($2);

                    scope_level++;
                }
                stmt_list { scope_level--; }
                elif_list else ENDIF
                ;

elif_list       : elif_list ELIF exp COLON {
                    add_indent();
                    printf("elif %s:\n", $3);

                    free($3);
                    scope_level++;
                }
                stmt_list { scope_level--; }
                | %empty
                ;

else            : ELSE COLON {
                    add_indent();
                    printf("else:\n");

                    scope_level++;
                }
                stmt_list { scope_level--; }
                | %empty
                ;

while_stmt      : WHILE exp COLON {
                    add_indent();
                    printf("while %s:\n", $2);

                    free($2);

                    scope_level++;
                }
                stmt_list ENDWHILE { scope_level--; }
                ;

foreach_stmt    : FOREACH ID IN exp COLON {
                    add_indent();
                    printf("for %s in %s:\n", $2, $4);

                    free($2);
                    free($4);

                    scope_level++;
                }
                stmt_list ENDFOREACH { scope_level--; }
                ;

func_def        : DEF ID LPAREN param_list RPAREN COLON {
                    while(scope_level > 0) {
                        scope_level--;
                    }
                    add_indent();
                    printf("def %s(%s):\n", $2, $4);

                    free($2);
                    free($4);

                    scope_level++;
                }
                stmt_list ENDDEF { scope_level--; }
                ;

param_list      : param_list_p { $$ = $1; }
                | %empty { $$ = cpy_str(""); }
                ;

param_list_p    : ID { $$ = $1; }
                | param_list_p COMMA ID {
                    int param_list_len = strlen($1);
                    int id_len = strlen($3);

                    // "param_list_p, ID\0"
                    char* p_list = (char*)malloc(param_list_len + 2 + id_len + 1);
                    if(p_list == NULL) {
                        fprintf(stderr, "스피키 역부족이었나봐요!");
                        exit(2);
                    }

                    strcpy(p_list, $1);
                    p_list[param_list_len] = ',';
                    p_list[param_list_len + 1] = ' ';
                    p_list[param_list_len + 2] = '\0';

                    strcat(p_list, $3);
                    p_list[param_list_len + 2 + id_len] = '\0';

                    free($1);
                    free($3);

                    $$ = p_list;
                }
                ;

arg_list        : arg_list_p { $$ = $1; }
                | %empty { $$ = cpy_str(""); }
                ;

arg_list_p      : exp { $$ = $1; }
                | arg_list_p COMMA exp {
                    int arg_list_len = strlen($1);
                    int exp_len = strlen($3);

                    char* a_list = (char*)malloc(arg_list_len + 2 + exp_len + 1);
                    if(a_list == NULL) {
                        fprintf(stderr, "스피키 역부족이었나봐요!");
                        exit(2);
                    }

                    strcpy(a_list, $1);
                    a_list[arg_list_len] = ',';
                    a_list[arg_list_len + 1] = ' ';
                    a_list[arg_list_len + 2] = '\0';

                    strcat(a_list, $3);
                    a_list[arg_list_len + 2 + exp_len] = '\0';

                    free($1);
                    free($3);

                    $$ = a_list;
                }
                ;

exp             : INT {
                    char* buff = (char*)malloc(sizeof(char) * INTDIGITMAX);
                    if(buff == NULL) {
                        fprintf(stderr, "스피키 역부족이었나봐요!");
                        exit(2);
                    }
                    snprintf(buff, INTDIGITMAX, "%d", $1);
                    $$ = cpy_str(buff);
                    free(buff);
                }
                | ID { $$ = $1; }
                | ID LPAREN arg_list RPAREN {
                    char* call = func_call($1, $3);
                    
                    free($1);
                    free($3);

                    $$ = call;
                }
                | LPAREN exp RPAREN {
                    char* paren_str = cat_paren($2);
                    
                    free($2);

                    $$ = paren_str;
                }
                | exp PLUS exp {
                    $$ = cat_str($1, "+", $3);
                    
                    free($1);
                    free($3);
                }
                | exp MINUS exp {
                    $$ = cat_str($1, "-", $3);
                    
                    free($1);
                    free($3);
                }
                | exp MUL exp {
                    $$ = cat_str($1, "*", $3);
                    
                    free($1);
                    free($3);
                }
                | exp DIV exp {
                    $$ = cat_str($1, "/", $3);
                    
                    free($1);
                    free($3);
                }
                | exp MOD exp {
                    $$ = cat_str($1, "%", $3);
                    
                    free($1);
                    free($3);
                }
                | exp EQ exp {
                    $$ = cat_str($1, "==", $3);
                    
                    free($1);
                    free($3);
                }
                | exp NE exp {
                    $$ = cat_str($1, "!=", $3);
                    
                    free($1);
                    free($3);
                }
                | exp LE exp {
                    $$ = cat_str($1, "<=", $3);
                    
                    free($1);
                    free($3);
                }
                | exp GE exp {
                    $$ = cat_str($1, ">=", $3);
                    
                    free($1);
                    free($3);
                }
                | exp LT exp {
                    $$ = cat_str($1, "<", $3);
                    
                    free($1);
                    free($3);
                }
                | exp GT exp {
                    $$ = cat_str($1, ">", $3);
                    
                    free($1);
                    free($3);
                }
                | MINUS exp %prec NEG {
                    int exp_len = strlen($2);

                    // "-exp\0"
                    char* neg_exp_str = (char*)malloc(sizeof(char) * (1 + exp_len + 1));
                    if(neg_exp_str == NULL) {
                        fprintf(stderr, "스피키 역부족이었나봐요!");
                        exit(2);
                    }
                    
                    neg_exp_str[0] = '-';
                    neg_exp_str[1] = '\0';

                    strcat(neg_exp_str, $2);

                    free($2);

                    $$ = neg_exp_str;
                }
                | STRING { $$ = $1; }
                ;

%%

int main() {
    yyparse();
    fprintf(stderr, "%s", pass_msg);
    return 0;
}

int yyerror(const char *s) {
    fprintf(stderr, syn_err_msg, yylineno);
    exit(-1);
}