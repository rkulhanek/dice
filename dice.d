/* Copyright 2017 Ray Kulhanek
 * This work is free. You can redistribute it and/or modify it under the
 * terms of the Do What The Fuck You Want To Public License, Version 2,
 * as published by Sam Hocevar. See the COPYING file for more details.
 */

import std.stdio;
import std.random;
import std.string;
import std.conv;
import std.regex;

static string prev = "";

extern (C) {
	int nocbreak();
	int noecho();
	int raw();
	char *readline(const char*);
	void add_history(const char*);
}

string readline(string prompt) {
	auto s = readline(prompt.toStringz).to!string.strip;
	if (s.length > 0) add_history(s.toStringz);
	return s;
}

int roll(int n, int d) {
	int sum = 0;
	for (int i = 0; i < n; i++) {
		sum += uniform(0, d) + 1;
	}
	return sum;
}

void parseLine(string line) {
	bool matches(string reg) {
		return line.matchFirst(regex(reg, "m")).length() > 0;
	}

	int sign = 1;
	int sum = 0;
	line = line.replaceAll(regex("[ \t\n]"), " ");
	if (matches("^ $")) {
		line = prev;//repeat on empty string
		writef("\033[1A");//move cursor up
	}
	prev = line;

	while (line.length) {
		if (matches("^[0-9]+[dD]") || matches("^[0-9]*[dD][0-9]+")) { //die code
			uint n = 1, d = 6;
			auto dcode = line.matchFirst(regex("^([0-9]*)[dD]([0-9]*)"));
			if (dcode[1].length > 0) {
				string s = dcode[1];
				n = s.parse!uint;
			}
			if (dcode[2].length > 0) {
				string s = dcode[2];
				d = s.parse!uint;
			}
			auto r = roll(n, d);
			writef("%s ", r);
			sum += sign * r;
			line = line[dcode[0].length..$];
		}
		else if (matches("^[0-9]+")) { // constant
			auto n = line.parse!uint;
			writef("%s ", n);
			sum += sign * n;
		}
		else if (0 != line.indexOfAny("+-, ")) {//comment
			auto offset = line.indexOfAny("+-, ");
			writef("\x1b[38;5;245m%s\x1b[0m ", line[0..offset]);
			line = line[offset..$];
		}

		if (line.length > 0) {
			switch (line[0]) {
				case '+':
					sign = 1;
					writef("+ ");
					line = line[1..$];
					break;
				case '-':
					writef("- ");
					sign *= -1;
					line = line[1..$];
					break;
				case ',':
					writef("=\x1b[34;1m %s \x1b[0m, ", sum);
					sum = 0;
					sign = 1;
					line = line[1..$];
					break;
				case ' ':
					line = line[1..$];
					break;
				default:
					break;
			}
		}
	}
	writef("=\x1b[34;1m %s \x1b[0m\n", sum);
}

void main() {
	writef("Syntax example: sword 1d20 + 5, 1d8+2d6 (fire)+2 \n");
	//Sort of issue: the +s are unnecessary.  - signs toggle whether the next number will
	//be added or subtracted, but it starts out as "add" whether or not a + appears. "sword 1d20 5, 1d8 2d6 (fire) 2"
	//is equivalent to the above.  The comma is syntactically significant, though.
	//5 - + 6 is equivalent to 5 + 6 or 5 6.  All this doesn't matter if stuff is entered in the canonical format, but
	//it's still odd enough that I'm tempted to write a proper LR parser.
	noecho();
	raw();
	
	while (1) {
		string line = readline("> ") ~ " ";
		if ("exit " == line || "quit " == line) break;
		try {
			parseLine(line);
		}
		catch (Throwable) {
			writef("syntax error\n");
		}
		next:;
	}
}

