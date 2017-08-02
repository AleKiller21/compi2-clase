TARGET=sample5
C_SRCFILES=ast.cpp expr_parser.cpp expr_lexer.cpp main.cpp
OBJ_FILES=${C_SRCFILES:.cpp=.o}
.PHONY: clean

$(TARGET): $(OBJ_FILES)
	g++ -o $@ $(OBJ_FILES)

expr_lexer.cpp: expr.l
	flex -o $@ $^

expr_parser.cpp: expr.y
	bison --defines=tokens.h -o $@ $<

%.o: %.cpp tokens.h ast.h
	g++ -c -o $@ $<

run: $(TARGET)
	./$(TARGET) input1.txt

clean:
	rm -f expr_parser.cpp expr_lexer.cpp
	rm -f *.o
	rm -f $(TARGET)