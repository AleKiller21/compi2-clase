#include <stdio.h>

int push_file(char* filename);
extern int yydebug;
void yyparse();

int main(int argc, char* argv[])
{
    if(argc < 2)
    {
        fprintf(stderr, "Usage: %s <input file>\n", argv[0]);
        return 1;
    }

    if(push_file(argv[1]) != 0) return 1;
    yydebug = 0;
    yyparse();
}