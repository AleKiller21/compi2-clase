#include "ast.h"

int vars[8];

int VarExpr::eval()
{
    return vars[index];
}

int AddExpr::eval()
{
    int v1 = expr1->eval();
    int v2 = expr2->eval();

    return v1 + v2;
}

int SubExpr::eval()
{
    int v1 = expr1->eval();
    int v2 = expr2->eval();

    return v1 - v2;
}

int MulExpr::eval()
{
    int v1 = expr1->eval();
    int v2 = expr2->eval();

    return v1 * v2;
}

int DivExpr::eval()
{
    int v1 = expr1->eval();
    int v2 = expr2->eval();

    return v1 / v2;
}

int LessThanExpr::eval()
{
    return expr1->eval() < expr2->eval();
}

int GreaterThanExpr::eval()
{
    return expr1->eval() > expr2->eval();
}

int LessThanEqualExpr::eval()
{
    return expr1->eval() <= expr2->eval();
}

int GreaterThanEqualExpr::eval()
{
    return expr1->eval() >= expr2->eval();
}

int EqualExpr::eval()
{
    return expr1->eval() == expr2->eval();
}

int NotEqualExpr::eval()
{
    return expr1->eval() != expr2->eval();
}

void AssignStatement::assign_value()
{
    vars[var->index] = expr->eval();
}

void AssignStatement::exec()
{
    assign_value();
}

void PrintStatement::print_format()
{
    char buffer[33];
    char* bin = NULL;
    switch(format)
    {
        case 2:
            bin = bin2dec(buffer, expr->eval());
            printf("%s\n", bin);
            delete [] bin;
            break;
        
        case 0:
            sprintf(buffer, "%d", expr->eval());
            printf("%s\n", buffer);
            break;

        case 1:
            sprintf(buffer, "%x", expr->eval());
            printf("%s\n", buffer);
            break;
    }
}

char* PrintStatement::bin2dec(char* temp_buffer, int dec)
{
    char* bin = NULL;
    int counter = 0;
    while(dec > 0)
    {
        if(dec % 2 != 0) temp_buffer[counter] = '1';
        else temp_buffer[counter] = '0';
        dec /= 2;
        counter++;
    }

    bin = new char[counter + 1];
    for(int i = 0; i < counter; i++)
    {
        bin[i] = temp_buffer[counter - (i + 1)];
    }
    bin[counter] = '\0';

    return bin;
}

void PrintStatement::exec()
{
    print_format();
}

void IfStatement::exec()
{
    if(expr->eval()) true_list->exec();
    else false_list->exec();
}

void BlockStatement::exec()
{
    for(list<Statement*>::iterator it = statementList.begin(); it != statementList.end(); it++)
    {
        (*it)->exec();
    }
}