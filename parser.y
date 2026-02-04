%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern int line_num;

void yyerror(const char *s);

typedef struct {
    char *name;
    int type; // 0 = int, 1 = float, 2 = char
    union {
        int ival;
        float fval;
        char cval;
    } value;
} variable_t;

variable_t variables[100];
int var_count = 0;

variable_t* find_variable(char *name);
void add_variable(char *name, int type);
void print_value(variable_t *var);
%}

%union {
    int num;
    float fnum;
    char *str;
}

%token <num> NUMBER
%token <fnum> FLOAT
%token <str> CHAR STRING IDENTIFIER

%token WELCOME STARTS SHOW END
%token WHATIF OTHERWISE IFNOT
%token CHOOSE WHEN DEFAULT STOP
%token DURING UNTIL EXECUTE CHECK
%token DIGIT_TYPE TEXT_TYPE FRACTION_TYPE
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON COMMA ASSIGN
%token EQ NE GT LT GE LE

%type <num> expression condition

%left '+' '-'
%left '*' '/' '%'

%%

program:
    WELCOME STARTS LPAREN RPAREN LBRACE statements END
    {
        // Program completed
    }
    ;

statements:
    statement
    | statements statement
    ;

statement:
    variable_declaration SEMICOLON
    | assignment SEMICOLON
    | print_statement SEMICOLON
    | input_statement SEMICOLON
    | if_statement
    | switch_statement
    | for_loop
    | while_loop
    | do_while_loop
    | STOP SEMICOLON { printf("Break\n"); }
    ;

variable_declaration:
    DIGIT_TYPE IDENTIFIER ASSIGN expression
    {
        add_variable($2, 0);
        variable_t *var = find_variable($2);
        if (var) var->value.ival = $4;
    }
    | FRACTION_TYPE IDENTIFIER ASSIGN FLOAT
    {
        add_variable($2, 1);
        variable_t *var = find_variable($2);
        if (var) var->value.fval = $4;
    }
    | TEXT_TYPE IDENTIFIER ASSIGN CHAR
    {
        add_variable($2, 2);
        variable_t *var = find_variable($2);
        if (var) var->value.cval = $4[1];  // Extract char
    }
    | DIGIT_TYPE IDENTIFIER  /* Declaration without init */
    {
        add_variable($2, 0);
    }
    /* Similar for other types without init */
    ;

assignment:
    IDENTIFIER ASSIGN expression
    {
        variable_t *var = find_variable($1);
        if (var && var->type == 0) {
            var->value.ival = $3;
        } else {
            printf("Error: Variable %s not declared or wrong type\n", $1);
        }
    }
    /* Add for float/char */
    ;

print_statement:
    SHOW LPAREN STRING RPAREN
    {
        char *output = $3;
        output++; output[strlen(output)-1] = '\0';
        printf("%s\n", output);
    }
    | SHOW LPAREN expression RPAREN
    {
        printf("%d\n", $3);
    }
    | SHOW LPAREN STRING COMMA expression RPAREN  /* Basic format support */
    {
        if (strcmp($3, "\"%d \"") == 0) {
            printf("%d ", $5);
        } /* Expand for more */
    }
    /* Add more variants */
    ;

input_statement:
    CHECK LPAREN IDENTIFIER RPAREN
    {
        variable_t *var = find_variable($3);
        if (var) {
            printf("Enter value for %s: ", $3);
            if (var->type == 0) scanf("%d", &var->value.ival);
            else if (var->type == 1) scanf("%f", &var->value.fval);
            else if (var->type == 2) scanf(" %c", &var->value.cval);
        }
    }
    ;

if_statement:
    WHATIF LPAREN condition RPAREN LBRACE statements RBRACE
    | WHATIF LPAREN condition RPAREN LBRACE statements RBRACE OTHERWISE LPAREN condition RPAREN LBRACE statements RBRACE
    | WHATIF LPAREN condition RPAREN LBRACE statements RBRACE IFNOT LBRACE statements RBRACE
    {
        // Placeholder: Actual branching needs AST
    }
    ;

switch_statement:
    CHOOSE IDENTIFIER LBRACE cases DEFAULT LBRACE statements RBRACE RBRACE
    {
        // Placeholder
    }
    ;

cases:
    | cases WHEN expression LBRACE statements STOP RBRACE
    ;

for_loop:
    DURING LPAREN assignment SEMICOLON condition SEMICOLON assignment RPAREN LBRACE statements RBRACE
    {
        // Placeholder
    }
    ;

while_loop:
    UNTIL LPAREN condition RPAREN LBRACE statements RBRACE
    {
        // Placeholder
    }
    ;

do_while_loop:
    EXECUTE LBRACE statements RBRACE UNTIL LPAREN condition RPAREN
    {
        // Placeholder
    }
    ;

condition:
    expression EQ expression { $$ = ($1 == $3); }
    | expression NE expression { $$ = ($1 != $3); }
    | expression GT expression { $$ = ($1 > $3); }
    | expression LT expression { $$ = ($1 < $3); }
    | expression GE expression { $$ = ($1 >= $3); }
    | expression LE expression { $$ = ($1 <= $3); }
    ;

expression:
    NUMBER { $$ = $1; }
    | IDENTIFIER
    {
        variable_t *var = find_variable($1);
        if (var && var->type == 0) $$ = var->value.ival;
        else $$ = 0;
    }
    | expression '+' expression { $$ = $1 + $3; }
    | expression '-' expression { $$ = $1 - $3; }
    | expression '*' expression { $$ = $1 * $3; }
    | expression '/' expression { $$ = $3 ? $1 / $3 : 0; }
    | LPAREN expression RPAREN { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    printf("Error at line %d: %s\n", line_num, s);
}

variable_t* find_variable(char *name) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(variables[i].name, name) == 0) return &variables[i];
    }
    return NULL;
}

void add_variable(char *name, int type) {
    if (var_count < 100) {
        variables[var_count].name = strdup(name);
        variables[var_count].type = type;
        var_count++;
    }
}

void print_value(variable_t *var) {
    if (var->type == 0) printf("%d", var->value.ival);
    else if (var->type == 1) printf("%.2f", var->value.fval);
    else printf("%c", var->value.cval);
}

int main() {
    printf("X Language Interpreter\nEnter program:\n");
    yyparse();
    return 0;
}