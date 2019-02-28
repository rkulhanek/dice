%{
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#define YYDEBUG 1

int yylex(void);
void yyerror(char*);

int verbose = 1;

#define GREY "38;5;245"
#define BLUE "34;1"

#define COLOR(COL, FMT, ...) do { \
	printf("\x1b[%sm", COL);      \
	printf((FMT), __VA_ARGS__);   \
	printf("\x1b[0m");            \
} while(0)

int roll(int sides) {
	//we want it to be unbiased, but don't care about guaranteed termination *more*.
	int bound = (RAND_MAX / sides) * sides;
	for (int i = 0; i < 10000; i++) {
		int r = rand();
		if (r < bound) return (r % sides) + 1;
	}
	return rand() % sides;
}

struct Stack {
	struct Stack *next;
	void *p;
};

struct Stack *alloced = NULL;

void free_alloced(void) {
	while (alloced) {
		struct Stack *p = alloced;
		alloced = alloced->next;
		free(p->p);
		free(p);
	}
}

void add_to_alloced(void *p) {
	struct Stack *entry = malloc(sizeof(struct Stack));
	if (!entry) {
		fprintf(stderr, "Failed to allocate %zu bytes\n", sizeof(struct Stack));
		free_alloced();
		abort();
	}
	entry->p = p;
	entry->next = alloced;
	alloced = entry;
}

char *format(const char *fmt, ...) {
	va_list args;
	va_start(args, fmt);
	char *s = NULL;
	int n = vasprintf(&s, fmt, args);
	if (n < 0) {
		fprintf(stderr, "Failed to allocate string\n");
		free_alloced();
		abort();
	}
	va_end(args);
	//printf("format(%s): [%s]\n", fmt, s);
	return s;
}

//n.b. need to pass $$, $1, $3. They get expanded by yacc. The macro gets expanded by cc.
#define OP_EXPR(TO, A, B, OPERATOR) \
	TO.lbl = verbose ? format("%s%c %s", A.lbl, *#OPERATOR, B.lbl) : format("%s%s", A.lbl, B.lbl); \
	TO.val = A.val OPERATOR B.val;


%}

%code requires {
	struct Pair {
		char *lbl;
		int val;
	};
}

%union {
	int d;
	char *s;
	struct Pair pair;
}

%type <pair> expr
%type <d> diecode constant
%token D
%token <d> NUMBER
%token <s> COMMENT DELIM
%left '+' '-' '*' '/'
%%

program: exprlst { }

exprlst: exprlst expr DELIM { 
		printf((verbose ? "%s= " : "%s "), $2.lbl);
		COLOR(BLUE, "%d", $2.val);
		printf("%s%s", $3, ('\n' == *$3) ? "" : " ");
		free_alloced();
	}
	| COMMENT {
		COLOR(GREY, "%s ", $1);
	}
	| exprlst error
	| error
	| /* empty */ ;
	
/* TODO: how to print the expressions? 
	e.g. for expr + expr, I've already printed the two expressions.
	I'll need to delay printing and instead assemble a string as I go.
*/

expr: 
	  expr '+' expr { OP_EXPR($$, $1, $3, +) }
	| expr '-' expr { OP_EXPR($$, $1, $3, -) }
	| expr '*' expr { OP_EXPR($$, $1, $3, *) }
	| expr '/' expr { OP_EXPR($$, $1, $3, /) }
	| expr '%' expr { OP_EXPR($$, $1, $3, %) }
	/*| '(' expr ')' {
		$$.val = $2.val;
		$$.lbl = verbose ? format("( %s)", $2.lbl) : $2.lbl;
	}*//* Possible syntax error if they're part of a comment. Which is more common than having actual parenthesized dice codes */
	| diecode {
		$$.val = roll($1);
		$$.lbl = verbose ? format("%d ", $$.val) : "";
	}
	| NUMBER diecode { 
		$$.val = 0;
		for (int i = 0; i < $1; i++) $$.val += roll($2);
		$$.lbl = verbose ? format("%d ", $$.val) : "";
	}
	| constant { 
		$$.val = $1; 
		$$.lbl = verbose ? format("%d ", $1) : "";
	}
	| expr COMMENT {
		$$.val = $1.val;
		$$.lbl = format("%s\x1b[%sm%s\x1b[0m ", $1.lbl, GREY, $2);
	}

diecode: D NUMBER { $$ = $2; };
constant: NUMBER { $$ = $1; };

%% 
/* TODO: parse parentheses */
void yyerror(char *s) {
	fprintf(stderr, "%s\n", s);
}
/*
int main(void) {
	while (!feof(stdin)) yyparse();
	return 0;
}
*/
