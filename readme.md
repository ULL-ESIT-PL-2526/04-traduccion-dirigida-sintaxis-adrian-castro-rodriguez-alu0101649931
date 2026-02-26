# Práctica 4 - Traducción Dirigida Sintaxis

## 1 Reponde las siguientes preguntas

### 1.1 Diferencia entre `/* skip whitespace */` y devolver un token

En el lexer:

```js
\s+ { /* skip whitespace */; }
```

Esta regla **reconoce espacios en blanco** (espacios, tabs, saltos de línea); no hace `return`, por lo tanto **no genera ningún token**; y el analizador simplemente los ignora.

En cambio:

```js
[0-9]+ { return 'NUMBER'; }
```

Reconoce números, devuelve un token `NUMBER` y ese token pasa al parser para el análisis sintáctico.

### 1.2 Secuencia de tokens para `123**45+@`

| Lexema | Token   |
| ------ | ------- |
| 123    | NUMBER  |
| **     | OP      |
| 45     | NUMBER  |
| +      | OP      |
| @      | INVALID |
| EOF    | EOF     |

Secuencia: `NUMBER OP NUMBER OP INVALID EOF`

### 1.3 ¿Por qué `"**"` debe aparecer antes que `[-+*/]`?

Porque el lexer funciona por máxima coincidencia y por orden de aparición.

Si `[-+*/]` apareciera antes:

* El primer `*` sería reconocido como `OP`
* El segundo `*` sería reconocido como otro `OP`

En vez de reconocer `**` como un único operador. Por eso `"**"` debe ir antes, para que tenga prioridad.

### 1.4 ¿Cuándo se devuelve EOF?

```js
<<EOF>> { return 'EOF'; }
```

Se devuelve cuando el lexer llega al final del archivo o no quedan más caracteres por analizar. Esto es necesario porque la gramática incluye:

```
L → E eof
```

El parser necesita saber cuándo termina la entrada.

### 1.5 ¿Por qué existe la regla `.` que devuelve INVALID?

```js
. { return 'INVALID'; }
```

Esta regla sirve para paptura cualquier carácter no reconocido, evitar que el lexer se bloquee y permitir detectar errores léxicos.

## 2. Ignorar comentarios `//`

```js
\/\/.[^\n]*           { /* skip comment */;    }
```

Lexer modificado:

```js
%lex
%%
\s+                   { /* skip whitespace */; }
\/\/.[^\n]*           { /* skip comment */;    }
[0-9]+                { return 'NUMBER';       }
"**"                  { return 'OP';           }
[-+*/]                { return 'OP';           }
<<EOF>>               { return 'EOF';          }
.                     { return 'INVALID';      }
/lex
```

## 3. Soporte para números en punto flotante

```js
[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?
```

Lexer final:

```js
%lex
%%
\s+                                     { /* skip whitespace */; }
\/\/.*                                  { /* skip comment */;    }
[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?     { return 'NUMBER';       }
"**"                                    { return 'OP';           }
[-+*/]                                  { return 'OP';           }
<<EOF>>                                 { return 'EOF';          }
.                                       { return 'INVALID';      }
/lex
```

## 4. Añadir pruebas para las modificaciones (Jest)

```js
describe('Modification tests', () => {
  test("ignore comments", () => {
    expect(parse("2+3 // comment")).toBe(5);
  });

  test("simple floating point", () => {
    expect(parse("2.5+2.5")).toBe(5);
  });

  test("scientific notation e-", () => {
    expect(parse("2.35e-3")).toBeCloseTo(0.00235);
  });

  test("scientific notation e+", () => {
    expect(parse("2.35e+3")).toBeCloseTo(2350);
  });

  test("scientific notation E-", () => {
    expect(parser.parse("2.35E-3")).toBeCloseTo(0.00235);
  });
})
```
