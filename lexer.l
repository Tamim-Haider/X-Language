%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

int line_num = 1;
%}

%option noyywrap

%%

[ \t]+                  { /* ignore whitespace */ }
\n                      { line_num++; }

"&welcome"              { return WELCOME; }
"starts"                { return STARTS; }
"show"                  { return SHOW; }
"&end"                  { return END; }
"whatif"                { return WHATIF; }
"otherwise"             { return OTHERWISE; }
"ifnot"                 { return IFNOT; }
"choose"                { return CHOOSE; }
"when"                  { return WHEN; }
"DEFAULT"               { return DEFAULT; }
"stop"                  { return STOP; }
"during"                { return DURING; }
"until"                 { return UNTIL; }
"execute"               { return EXECUTE; }
"check"                 { return CHECK; }
"digit"                 { return DIGIT_TYPE; }
"text"                  { return TEXT_TYPE; }
"fraction"              { return FRACTION_TYPE; }

[a-zA-Z_][a-zA-Z0-9_]*  { yylval.str = strdup(yytext); return IDENTIFIER; }
[0-9]+                  { yylval.num = atoi(yytext); return NUMBER; }
[0-9]+\.[0-9]+          { yylval.fnum = atof(yytext); return FLOAT; }
\'.\'                   { yylval.str = strdup(yytext); return CHAR; }
\"[^\"]*\"              { yylval.str = strdup(yytext); return STRING; }

"("                     { return LPAREN; }
")"                     { return RPAREN; }
"{"                     { return LBRACE; }
"}"                     { return RBRACE; }
";"                     { return SEMICOLON; }
","                     { return COMMA; }
"="                     { return ASSIGN; }
"+"                     { return '+'; }
"-"                     { return '-'; }
"*"                     { return '*'; }
"/"                     { return '/'; }
"%"                     { return '%'; }  /* For format strings */

"=="                    { return EQ; }
"!="                    { return NE; }
">"                     { return GT; }
"<"                     { return LT; }
">="                    { return GE; }
"<="                    { return LE; }

"@"[^ \n]*              { /* single-line comment */ }
"@!"(.|\n)*"!\@"        { /* multi-line comment */ }

.                       { printf("Unknown character: %c\n", yytext[0]); }

%%