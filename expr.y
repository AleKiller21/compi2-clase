%code requires
{
    #include "ast.h"
    #include <string>
}

%{
    #include <stdio.h>
    

    using namespace std;

    int yylex();
    void print_format(int format, int expression);
    char* bin2dec(char* temp_buffer, int dec);
    extern int yylineno;
    extern char* yyfilename;
    void yyerror(const char* msg)
    {
        printf("File %s Line: %d: %s\n", yyfilename, yylineno, msg);
    }

    #define YYERROR_VERBOSE 1
    #define YYDEBUG 1
%}

%union
{
    Statement* statement_t;
    Expr* expr_t;
    string* id_t;
    int int_t;
}

%type <statement_t> stmt_list stmt assign_statement print_statement if_statement block_statement else_statement
%type <expr_t> expr
%type <expr_t> term factor
%type <expr_t> arithmetic_expressions 
%type <expr_t> relational_expressions 
%type <expr_t> equality_expressions
%type <int_t> output_format

%token <int_t> RW_DEC RW_HEX RW_BIN
%token <int_t> TK_NUMBER
%token <id_t> TK_ID
%token TK_EOL TK_EOF TK_ERROR
%token RW_PRINT RW_IF RW_ELSE
%token OP_LESS_THAN_EQUAL "<="
%token OP_GREATER_THAN_EQUAL ">="
%token OP_EQUAL "=="
%token OP_NOT_EQUAL "!="

%expect 1
%glr-parser

%%

source: opt_new_line stmt_list opt_new_line { $2->exec(); }
;

stmt_list: stmt {$$ = new BlockStatement(); ((BlockStatement*)$$)->addStatement($1); }
        | stmt_list new_line stmt { $$ = $1; ((BlockStatement*)$$)->addStatement($3); }
;

opt_new_line: new_line
            | %empty
;

new_line: TK_EOL
        | new_line TK_EOL
;

stmt: print_statement { $$ = $1; }
    | assign_statement { $$ = $1; }
    | if_statement { $$ = $1; }
;

print_statement: RW_PRINT '(' expr output_format ')' { $$ = new PrintStatement($3, $4); }
;

assign_statement: TK_ID '=' expr { $$ = new AssignStatement($1, $3); }
;

if_statement: RW_IF '(' expr ')' new_line block_statement else_statement %dprec 2 { $$ = new IfStatement($3, $6, $7); }
            | RW_IF '(' expr ')' new_line block_statement %dprec 1 { $$ = new IfStatement($3, $6, NULL); }
;

block_statement: '{' new_line stmt_list new_line '}' { $$ = $3; }
              | stmt { $$ = $1; }
;

else_statement: RW_ELSE new_line block_statement { $$ = $3; }
;

output_format: ',' RW_BIN { $$ = $2; }
            |  ',' RW_DEC { $$ = $2; }
            |  ',' RW_HEX { $$ = $2; }
            |  %empty { $$ = 0; }
;

expr: equality_expressions { $$ = $1; }
;

equality_expressions: equality_expressions "==" relational_expressions { $$ = new EqualExpr($1, $3); }
                    | equality_expressions "!=" relational_expressions { $$ = new NotEqualExpr($1, $3); }
                    | relational_expressions { $$ = $1; }
;

relational_expressions: relational_expressions '<' arithmetic_expressions { $$ = new LessThanEqualExpr($1, $3); }
                      | relational_expressions '>' arithmetic_expressions { $$ = new GreaterThanExpr($1, $3); }
                      | relational_expressions "<=" arithmetic_expressions { $$ = new LessThanEqualExpr($1, $3); }
                      | relational_expressions ">=" arithmetic_expressions { $$ = new GreaterThanEqualExpr($1, $3); }
                      | arithmetic_expressions { $$ = $1; }
;

arithmetic_expressions: arithmetic_expressions '+' term { $$ = new AddExpr($1, $3); }
                      | arithmetic_expressions '-' term { $$ = new SubExpr($1, $3); }
                      | term { $$ = $1; }
;


term: term '*' factor { $$ = new MulExpr($1, $3); }
    | term '/' factor { $$ = new DivExpr($1, $3); }
    | factor { $$ = $1; }
;

factor: TK_NUMBER { $$ = new NumberExpr($1); }
        | '(' expr ')' { $$ = $2; }
        | TK_ID { $$ = new VarExpr($1); }
;
