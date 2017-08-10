TARGET=sample5
C_SRCFILES=ast.cpp expr_parser.cpp expr_lexer.cpp main.cpp
OBJ_FILES=${C_SRCFILES:.cpp=.o}
.PHONY: clean

$(TARGET): $(OBJ_FILES)
	g++ -o $@ $(OBJ_FILES)

expr_lexer.cpp: expr.l
	flex -o $@ $^

expr_parser.cpp: expr.y
	bison -v -rall --defines=tokens.h -o $@ $<

%.o: %.cpp tokens.h ast.h
	g++ -c -o $@ $<

run: $(TARGET)
	./$(TARGET) inge_if.txt

clean:
	rm -f expr_parser.cpp expr_lexer.cpp
	rm -f *.o
	rm -f $(TARGET)