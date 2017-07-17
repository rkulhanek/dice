import std.stdio;
import std.random;
import std.string;
import std.conv;
import std.regex;

extern (C) {
	int nocbreak();
	int noecho();
	int raw();
	char *readline(const char*);
	void add_history(const char*);
}

string readline(string prompt) {
	auto s = readline(prompt.ptr);
	add_history(s);
	return to!string(s);
}

int roll(int n, int d) {
	int sum = 0;
	for (int i = 0; i < n; i++) {
		sum += uniform(0, d) + 1;
	}
	return sum;
}

void main() {
	writef("Syntax example: sword 1d20 + 5, 1d8+2d6 (fire)+2 \n");
	noecho();
	raw();

	int sign = 1;
	string prev = "";
	while (1) {
		auto line = readline("> ") ~ " ";
		if ("exit " == line || "quit " == line) break;
		try {
			int sum = 0;
			line = line.replaceAll(regex("[ \t\n]"), " ");
			if (!line.length) {
				line = prev;//repeat on empty string
				writef("\033[1A");//move cursor up
			}
			prev = line;

			bool matches(string reg) {
				return line.matchFirst(regex(reg, "m")).length() > 0;
			}
				
			sign = 1;
			while (line.length) {
				if (matches("^[0-9]*d[0-9]+")) { //die code
					uint n = 1;
					if ('d' != line[0]) {
						n = line.parse!uint;
					}
					line = line[1..$];
					auto d = line.parse!uint;
					auto r = roll(n, d);
					writef("%s ", r);
					sum += sign * r;
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
							sign = -1;
							line = line[1..$];
							break;
						case ',':
							writef("=\x1b[34;1m %s \x1b[0m, ", sum);
							sum = 0;
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
		catch {
			writef("syntax error\n");
		}
		next:;
	}
}

