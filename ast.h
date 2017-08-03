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

class RelationalExpr : public BinaryExpr
{
public:
    RelationalExpr(Expr* expr1, Expr* expr2) : BinaryExpr(expr1, expr2) {}
};

class EqualityExpr : public BinaryExpr
{
public:
    EqualityExpr(Expr* expr1, Expr* expr2) : BinaryExpr(expr1, expr2) {}
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

class LessThanExpr : public RelationalExpr
{
public:
    LessThanExpr(Expr* expr1, Expr* expr2) : RelationalExpr(expr1, expr2) {}
    int eval();
};

class GreaterThanExpr : public RelationalExpr
{
public:
    GreaterThanExpr(Expr* expr1, Expr* expr2) : RelationalExpr(expr1, expr2) {}
    int eval();
};

class LessThanEqualExpr : public RelationalExpr
{
public:
    LessThanEqualExpr(Expr* expr1, Expr* expr2) : RelationalExpr(expr1, expr2) {}
    int eval();
};

class GreaterThanEqualExpr : public RelationalExpr
{
public:
    GreaterThanEqualExpr(Expr* expr1, Expr* expr2) : RelationalExpr(expr1, expr2) {}
    int eval();
};

class EqualExpr : public EqualityExpr
{
public:
    EqualExpr(Expr* expr1, Expr* expr2) : EqualityExpr(expr1, expr2) {}
    int eval();
};

class NotEqualExpr : public EqualityExpr
{
public:
    NotEqualExpr(Expr* expr1, Expr* expr2) : EqualityExpr(expr1, expr2) {}
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

class IfStatement : public Statement
{
public:
    Expr* condition;
    Statement* true_list;
    Statement* false_list;

    IfStatement(Expr* condition, Statement* true_list, Statement* false_list)
    {
        this->condition = condition;
        this->true_list = true_list;
        this->false_list = false_list;
    }
    
    void exec();
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