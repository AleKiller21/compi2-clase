%code requires
{
    #include "ast.h"
}

%{
    #include <stdio.h>
    int yylex();
    void print_format(int format, int expression);
    char* bin2dec(char* temp_buffer, int dec);
    extern int yylineno;
    extern char* yyfilename;
    void yyerror(const char* msg)
    {
        printf("File %s Line: %d: %s\n", yyfilename, yylineno, msg);
    }

    #define YYERROR_VERBOSE 1;
%}

%union
{
    Statement* statement_t;
    Expr* expr_t;
    int int_t;
}

%type <statement_t> assign_statement print_statement stmt stmt_list
%type <expr_t> expr term factor
%type <int_t> output_format

%token <int_t> TK_NUMBER TK_INDEX
%token TK_EOL TK_EOF TK_ERROR
%token RW_PRINT RW_IF RW_ELSE
%token <int_t> RW_DEC RW_HEX RW_BIN
%token OP_LESS_THAN_EQUAL OP_GREATER_THAN_EQUAL OP_EQUAL OP_NOT_EQUAL 

%%

source: opt_new_line stmt_list opt_new_line { $2->exec(); }
;

stmt_list: stmt {$$ = new BlockStatement(); ((BlockStatement*)$$)->addStatement($1); }
        | stmt_list new_line stmt { $$ = $1; ((BlockStatement*)$$)->addStatement($3); }
;

opt_new_line: new_line
            | %empty
;

new_line: new_line TK_EOL
        | TK_EOL
;

stmt: print_statement { $$ = $1; }
    | assign_statement { $$ = $1; }
;

print_statement: RW_PRINT '(' expr ',' output_format ')' { $$ = new PrintStatement($3, $5); }
;

assign_statement: TK_INDEX '=' expr { $$ = new AssignStatement($1, $3); }
;

output_format: RW_BIN { $$ = $1; }
            |  RW_DEC { $$ = $1; }
            |  RW_HEX { $$ = $1; }
;

expr: expr '+' term { $$ = new AddExpr($1, $3); }
    | expr '-' term { $$ = new SubExpr($1, $3); }
    | term { $$ = $1; }
;

term: term '*' factor { $$ = new MulExpr($1, $3); }
    | term '/' factor { $$ = new DivExpr($1, $3); }
    | factor { $$ = $1; }
;

factor: TK_NUMBER { $$ = new NumberExpr($1); }
        | '(' expr ')' { $$ = $2; }
        | TK_INDEX { $$ = new VarExpr($1); }
;
