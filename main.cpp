#include <stdio.h>

// extern FILE* yyin;
// int yylex();
int push_file(char* filename);
//extern int yylineno;
void yyparse();

int main(int argc, char* argv[])
{
    if(argc < 2)
    {
        fprintf(stderr, "Usage: %s <input file>\n", argv[0]);
        return 1;
    }

    if(push_file(argv[1]) != 0) return 1;
    yyparse();
}