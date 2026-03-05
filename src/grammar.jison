/* Lexer */
%lex
%%

\s+                                     { /* skip whitespace */ }
\/\/[^\n]*                              { /* skip comment */    }
[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?     { return 'NUMBER';      }
"**"                                    { return 'OPOW';        }
[*/]                                    { return 'OPMU';        }
[-+]                                    { return 'OPAD';        }
"("                                     { return '(';           }
")"                                     { return ')';           }
<<EOF>>                                 { return 'EOF';         }
.                                       { return 'INVALID';     }

/lex

/* Parser */
%start expressions

%token NUMBER
%token OPAD
%token OPMU
%token OPOW

%%

L
  : E eof                { $$ = $1; }
  ;

expression
  : expression OPAD term
    { $$ = operate($OPAD, $expression, $term); }
  | term
    { $$ = $term; }
  ;

term
  : term OPMU power
    { $$ = operate($OPMU, $term, $power); }
  | power
    { $$ = $power; }
  ;

power
  : factor OPOW power
    { $$ = operate($OPOW, $factor, $power); }
  | factor
    { $$ = $factor; }
  ;

factor
  : NUMBER
    { $$ = Number(yytext); }
  | '(' expression ')'
    { $$ = $expression; }
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