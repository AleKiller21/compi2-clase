#ifndef _AST_h
#define _AST_h

#include <stdio.h>
#include <list>

using namespace std;

class Expr
{
public:
    virtual int eval() = 0;
};

class BinaryExpr : public Expr
{
public:
    Expr* expr1, *expr2;

protected:
    BinaryExpr(Expr* expr1, Expr* expr2)
    {
        this->expr1 = expr1;
        this->expr2 = expr2;
    }
};

class AddExpr : public BinaryExpr
{
public:
    AddExpr(Expr* expr1, Expr* expr2) : BinaryExpr(expr1, expr2) {}
    int eval();
};

class SubExpr : public BinaryExpr
{
public:
    SubExpr(Expr* expr1, Expr* expr2) : BinaryExpr(expr1, expr2) {}
    int eval();
};

class MulExpr : public BinaryExpr
{
public:
    MulExpr(Expr* expr1, Expr* expr2) : BinaryExpr(expr1, expr2) {}
    int eval();
};

class DivExpr : public BinaryExpr
{
public:
    DivExpr(Expr* expr1, Expr* expr2) : BinaryExpr(expr1, expr2) {}
    int eval();
};

class NumberExpr : public Expr
{
public:
    int value;

    NumberExpr(int value)
    {
        this->value = value;
    }

    int eval()
    {
        return value;
    }
};

class VarExpr : public Expr
{
public:
    int index;
    
    VarExpr(int index)
    {
        this->index = index;
    }

    int eval();
};

class Statement
{
public:
    virtual void exec() = 0;
};

class AssignStatement : public Statement
{
public:
    VarExpr* var;
    Expr* expr;

    AssignStatement(int index, Expr* expr)
    {
        this->var = new VarExpr(index);
        this->expr = expr;
    }

    void assign_value();
    void exec();
};

class PrintStatement : public Statement
{
public:
    Expr* expr;
    int format;

    PrintStatement(Expr* expr, int format)
    {
        this->expr = expr;
        this->format = format;
    }

    void print_format();
    void exec();

private:
    char* bin2dec(char* temp_buffer, int dec);
};

class BlockStatement: public Statement
{
public:
    list<Statement*> statementList;

    BlockStatement() {}

    void addStatement(Statement* statement)
    {
        statementList.push_back(statement);
    }

    void exec();
};

#endif //_AST_h