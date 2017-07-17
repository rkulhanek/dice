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
	writef("Syntax example: 1d20 + 5, 1d8+2d6+2\n");
	noecho();
	raw();

	int sign = 1;
	string prev = "";
	while (1) {
		auto line = readline("> ");
		if ("exit" == line || "quit" == line) break;
		try {
			int sum = 0;
			line = line.replaceAll(regex("[ \t\n]"), "");
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
				if (matches("^[0-9]*d[0-9]+")) {
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
				else if (matches("^[0-9]+")) {
					auto n = line.parse!uint;
					writef("%s ", n);
					sum += sign * n;
				}

				if (line.length > 0) {
					switch (line[0]) {
						case '+':
							sign = 1;
							writef("+ ");
							break;
						case '-':
							writef("- ");
							sign = -1;
							break;
						case ',':
							writef("=\x1b[34;1m %s \x1b[0m, ", sum);
							sum = 0;
							break;
						default:
							writef("syntax error (%s)\n", line);
							goto next;
					}
					line = line[1..$];
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

