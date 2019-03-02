/* Copyright 2017-19 Ray Kulhanek
 * This work is free. You can redistribute it and/or modify it under the
 * terms of the Do What The Fuck You Want To Public License, Version 2,
 * as published by Sam Hocevar. See the COPYING file for more details.
 */

import std.stdio, std.random, std.string, std.conv, std.regex, std.uni, std.getopt;

static string prev = "";

extern (C) {
	int nocbreak();
	int noecho();
	int raw();
	char *readline(const char*);
	void add_history(const char*);
	void parse_line(const char*);
	extern __gshared int verbose, yydebug;
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

int main(string[] argv) {
	bool quiet = 0;
	bool debugmode = 0;
	auto opts = getopt(argv,
		"q|quiet", "By default, prints intermediate results. Quiet makes it only print the final sum.", &quiet,
		"debug", "set yacc's debug output on", &debugmode,
	);
	verbose = !quiet;
	yydebug = debugmode;

	if (opts.helpWanted) {
		defaultGetoptPrinter("", opts.options);
		return 1;
	}
	
	noecho();
	raw();

	writef("Syntax example: sword 1d20 + 5, 1d8+2d6 (fire)+2 \n");

	string prevLine = "";
	while (1) {
		string line = readline("> ");
		if ("exit " == line) break;
		if (!line.length) line = prevLine;
		prevLine = line;
		try {
			//parseLine(line);
			line ~= "\n";
			parse_line(line.toStringz);
		}
		catch (Throwable) {
			writef("syntax error\n");
		}
	}
	return 0;
}

