.PHONY: all clean

BIN=dice

all: $(BIN)
clean:
	rm -- $(BIN)

$(BIN): dice.d
	dmd -O dice.d -L-lncurses -L-lreadline



