%{
#define YYDEBUG 1
#include <stdio.h>
#include "dice.tab.h"

/* TODO: I want yylex to return 0 after it's returned a newline. 
https://stackoverflow.com/questions/780676/string-input-to-flex-lexer

Can quite trivally write parts of this in D by just doing extern C decls.

typedef void* d_string;

Just have a d_string append_str(d_string str, char *t) written in D that does the necessary allocs.
One thing to watch out for is making sure D doesn't garbage collect anything it shouldn't.
str is actually a string*

I can then have a print_str(d_string str) or a char *d2c_string(d_string str);
Or I could have a structure on the D side and a function like d2c_string(d_struct s) for each of its
members
*/

void parse_line(const char *s) {
//	yydebug=1;
	yy_scan_string(s);
	yyparse();
}

%}

%option noyywrap

%%

[()]+ { return *yytext; }
[0-9]+ { yylval.d = atoi(yytext); return NUMBER; }
[-+*/] { return *yytext; }
[\n,] { yylval.s = yytext; return DELIM; }
[^-+*/%0-9, \t]+d { yylval.s = yytext; return COMMENT; }
d[^-+*/%0-9, \t]+ { yylval.s = yytext; return COMMENT; }
[^-+*/%0-9d,\n \t]+ { yylval.s = yytext; return COMMENT; }
d { return D; }
[ \t] {/* skip whitespace */}

%%

