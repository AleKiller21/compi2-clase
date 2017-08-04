%option noyywrap
%option yylineno
%x comment
%x include

%{
#include <stdio.h>
//#include <string.h>
#include <string>
#include "tokens.h"

using namespace std;

typedef struct include_stack
{
    struct include_stack* prev;
    FILE* f;
    int lineno;
    char* filename;
    YY_BUFFER_STATE bs;
} include_stack_t;

include_stack_t* inc_stack = NULL;
char* yyfilename;
char* include_filename_symbol;
int push_file(char* filename);
int consume_filename();
int pop_file();


%}

NUMBER      [0-9]+
ID          [a-zA-z_][a-zA-z0-9_]*

%%
[ \t]                               { /*Nada*/ }
^"#"[ \t]*"include"[ \t]*[\"\<]     { include_filename_symbol = yytext+yyleng-1; BEGIN(include); }
"/*"                                { BEGIN(comment); }
"//".*\n                            { return TK_EOL; }
"+"                                 { return '+'; }
"-"                                 { return '-'; }
"*"                                 { return '*'; }
"/"                                 { return '/'; }
"("                                 { return '('; /*)*/ }
")"                                 { return ')'; }
"=="                                { return OP_EQUAL;}
"!="                                { return OP_NOT_EQUAL;}
"<"                                 { return '<';}
">"                                 { return '>';}
"<="                                { return OP_LESS_THAN_EQUAL;}
">="                                { return OP_GREATER_THAN_EQUAL;}
"="                                 { return '='; }
"{"                                 { return '{'; /*}*/ }
"}"                                 { /*{*/ return '}'; }
","                                 { return ',';}
"print"                             { return RW_PRINT; }
"if"                                { return RW_IF; }
"else"                              { return RW_ELSE; }
"dec"                               { yylval.int_t = 0; return RW_DEC; }
"hex"                               { yylval.int_t = 1; return RW_HEX; }
"bin"                               { yylval.int_t = 2; return RW_BIN; }
{ID}                                { yylval.id_t = new string(yytext); return TK_ID; }
{NUMBER}                            { yylval.int_t = atoi(yytext); return TK_NUMBER; }
"\n"                                { return TK_EOL; }
<INITIAL><<EOF>>                    { if(pop_file() != 0) yyterminate();}
.                                   { return TK_ERROR; }


<include>[^\"\>\n]+                 { if(consume_filename() == 1) yyterminate(); }


<comment>"*/"                       { BEGIN(INITIAL); }
<comment>.|\n                       { /*Nothing*/ }
<comment><<EOF>>                    { printf("Line %d: Block comment without end\n", yylineno); return 0; }

%%

int consume_filename()
{
    int c;
    int filename_complete = 0;
    int extra_tokens = 0;
    if((c = yyinput()) && c != '"' && c != '>')
    {
      int lineno = c == '\n' ? yylineno - 1 : yylineno;
      fprintf(stderr, "File %s Line number %d: include directive malformed.\n", yyfilename, lineno);
      BEGIN(INITIAL);
      filename_complete = 1;
    }

    if(*include_filename_symbol == '<' && c != '>')
    {
      fprintf(stderr, "File %s Line number %d: Missing terminating > character.\n", yyfilename, yylineno);
      BEGIN(INITIAL);
      filename_complete = 1;
    }

    else if(*include_filename_symbol == '"' && c != '"')
    {
      fprintf(stderr, "File %s Line number %d: Missing terminating \" character.\n", yyfilename, yylineno);
      BEGIN(INITIAL);
      filename_complete = 1;
    }

    if(filename_complete == 0)
    {
      char* yytext_temp = strdup(yytext);
      while((c = yyinput()) != EOF && c != '\n') extra_tokens = 1;
      if(extra_tokens == 1) printf("File %s Line %d: warning: extra tokens at end of #include directive.\n", yyfilename, yylineno - 1);
      if(push_file(yytext_temp) != 0)
      {
          //free(yytext_temp);
          return 1;
      }
      //free(yytext_temp);
      BEGIN(INITIAL);
    }

    return 0;
}

int push_file(char* filename)
{
    FILE* f = fopen(filename, "r");

    if(f == NULL)
    {
        fprintf(stderr, "File %s not found.\n", filename);
        return 1;
    }

    //include_stack_t* is = malloc(sizeof(include_stack_t));
    include_stack_t* is = new(include_stack_t);
    if(is == NULL)
    {
        fprintf(stderr, "Out of memory.\n");
        return 1;
    }

    is->f = f;
    is->lineno = yylineno;
    is->filename = yyfilename;
    is->bs = yy_create_buffer(f, YY_BUF_SIZE);
    is->prev = inc_stack;
    inc_stack = is;
    yyfilename = filename;
    yylineno = 1;

    yy_switch_to_buffer(is->bs);
    return 0;
}

int pop_file()
{
    include_stack_t* prev_is = inc_stack->prev;
    fclose(inc_stack->f);
    yy_delete_buffer(inc_stack->bs);


    yylineno = inc_stack->lineno;
    yyfilename = inc_stack->filename;
    free(inc_stack);
    if(prev_is == NULL) return 1;
    yy_switch_to_buffer(prev_is->bs);
    inc_stack = prev_is;
    return 0;
}
