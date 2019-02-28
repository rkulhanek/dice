.PHONY: all clean

BIN=dice
CFLAGS=-g

all: $(BIN)
clean:
	rm -- $(BIN) lex.yy.o dice.tab.o dice.o

$(BIN): dice.d lex.yy.o dice.tab.o
	dmd -O $^ -L-lncurses -L-lreadline

lex.yy.o: lex.yy.c dice.tab.h
	gcc $(CFLAGS) -c lex.yy.c

dice.tab.o: dice.tab.c dice.tab.h
	gcc $(CFLAGS) -c dice.tab.c

lex.yy.c: dice.lex
	flex $<

dice.tab.c: dice.tab.h

dice.tab.h: dice.y
	bison -d $<
