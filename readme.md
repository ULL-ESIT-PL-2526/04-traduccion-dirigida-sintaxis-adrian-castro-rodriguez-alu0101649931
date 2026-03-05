# Práctica 5 - Traducción Dirigida Sintaxis

## 1. Partiendo de la gramática y las siguientes frases `4.0-2.0*3.0`, `2**3**2` y `7-4/2`:

### 1.1 Escriba la derivación para cada una de las frases.

Frase 1: `4.0 - 2.0 * 3.0`

```
L
E eof
E op T eof
E op T op T eof
T op T op T eof
number op T op T eof
number op number op T eof
number op number op number eof
```

Frase 2: `2 ** 3 ** 2`

```
L
E eof
E op T
E op T op T
T op T op T
number op number op number
```

Frase 3: `7 - 4 / 2`

```
L
E
E op T
E op T op T
T op T op T
number op number op number
```

### 1.2 Escriba el árbol de análisis sintáctico (parse tree) para cada una de las frases.

Frase 1: `4.0 - 2.0 * 3.0`

```
L
├─ E
│  ├─ E
│  │  ├─ E
│  │  │  └─ T
│  │  │     └─ <NUM,4.0>
│  │  ├─ OP
│  │  │  └─ -
│  │  └─ T
│  │     └─ <NUM,2.0>
│  ├─ OP
│  │  └─ *
│  └─ T
│     └─ <NUM,3.0>
└─ EOF
```

Frase 2: `2 ** 3 ** 2`

```
L
├─ E
│  ├─ E
│  │  ├─ E
│  │  │  └─ T
│  │  │     └─ <NUM,2>
│  │  ├─ OP
│  │  │  └─ **
│  │  └─ T
│  │     └─ <NUM,3>
│  ├─ OP
│  │  └─ **
│  └─ T
│     └─ <NUM,2>
└─ EOF
```

Frase 3: `7 - 4 / 2`

```
L
├─ E
│  ├─ E
│  │  ├─ E
│  │  │  └─ T
│  │  │     └─ <NUM,7>
│  │  ├─ OP
│  │  │  └─ -
│  │  └─ T
│  │     └─ <NUM,4>
│  ├─ OP
│  │  └─ /
│  └─ T
│     └─ <NUM,2>
└─ EOF
```

### 1.3 ¿En qué orden se evaluan las acciones semánticas para cada una de las frases?

Es evaluación bottom-up: se convierten los números, se evalúa la operación más a la izquierda primero y luego se sigue reduciendo hacia arriba. Por tanto, todo es asociativo por la izquierda y no hay precedencia.

## 2. Modifique la gramática del fichero grammar.jison de manera que se respete la precedencia y la asociatividad de los operadores matemáticos.

```js
/* Lexer */
%lex
%%

\s+                                     { /* skip whitespace */ }
\/\/[^\n]*                              { /* skip comment */    }
[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?     { return 'NUMBER';      }
"**"                                    { return 'OPOW';        }
[*/]                                    { return 'OPMU';        }
[-+]                                    { return 'OPAD';        }
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
%%
```

## 3 Añada los test correspondientes para comprobar que se respeta la precedencia y asociatividad con flotantes.

```js
test('should handle floats with precedence', () => {
  expect(parse("2.5 + 3.5 * 2")).toBe(9.5);
  expect(parse("10.0 - 4.0 / 2.0")).toBe(8.0);
  expect(parse("2.0 ** 3.0 ** 2.0")).toBe(512.0);
});
```

## 4. Modifique el programa Jison para que se reconozcan expresiones entre paréntesis.

```js
/* Lexer */
"("     { return '('; }
")"     { return ')'; }

/* Parser */
factor
  : NUMBER
    { $$ = Number(yytext); }
  | '(' expression ')'
    { $$ = $expression; }
  ;
```

## 5. Añada los test correspondientes para las expresiones entre paréntesis.

```js
test('should handle parentheses correctly', () => {
  expect(parse("(2 + 3) * 4")).toBe(20);
  expect(parse("2 * (3 + 4)")).toBe(14);
  expect(parse("(2 + 3) * (4 + 1)")).toBe(25);
  expect(parse("2 ** (3 ** 2)")).toBe(512);
});
```