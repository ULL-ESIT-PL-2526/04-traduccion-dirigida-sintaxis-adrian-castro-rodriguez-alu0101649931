/* Lexer */
%lex
%%
\s+                                     { /* skip whitespace */; }
\/\/[^\n]*                              { /* skip comment */;    }
[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?     { return 'NUMBER';       }
"**"                                    { return 'OP';           }
[-+*/]                                  { return 'OP';           }
<<EOF>>                                 { return 'EOF';          }
.                                       { return 'INVALID';      }
/lex

/* Parser */
%token number
%token opad
%token opmu
%token opow
%token LPAREN RPAREN

%%

L
  : E eof                { $$ = $1; }
  ;

E
  : E opad T             { $$ = operate($2, $1, $3); }
  | T                    { $$ = $1; }
  ;

T
  : T opmu R             { $$ = operate($2, $1, $3); }
  | R                    { $$ = $1; }
  ;

R
  : F opow R             { $$ = operate($2, $1, $3); }
  | F                    { $$ = $1; }
  ;

F
  : number               { $$ = convert($1); }
  | LPAREN E RPAREN      { $$ = $2; }
  ;
%%

function operate(op, left, right) {
  switch (op) {
    case '+': return left + right;
    case '-': return left - right;
    case '*': return left * right;
    case '/': return left / right;
    case '**': return Math.pow(left, right);
  }
}
