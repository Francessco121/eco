# Eco Grammar

```ebnf
program          -> declaration* EOF ;

declaration      -> import_decl | function_decl | var_decl | statement ;

import_decl      -> "import" STRING "as" IDENTIFIER ;
function_decl    -> "pub"? "fn" IDENTIFIER "(" parameters? ")" ( block_stmt | "=>" expression ";" ) ;
var_decl         -> "pub"? "var" IDENTIFIER ( "=" expression )? ";" ;

statement        -> block_stmt | break_stmt | continue_stmt | expr_stmt | for_stmt | foreach_stmt 
                  | if_stmt | return_stmt | while_stmt | write_stmt | tag_stmt ;

block_stmt       -> "{" declaration* "}" ;
break_stmt       -> "break" ";" ;
continue_stmt    -> "continue" ";" ;
expr_stmt        -> expression ";" ;
for_stmt         -> "for" "(" ( var_decl | expr_stmt | ";" ) expression? ";" expression? ")" 
                    statement ;
foreach_stmt     -> "foreach" "(" "var" IDENTIFIER ( "," IDENTIFIER )? "in" expression ")" statement ;
if_stmt          -> "if" "(" expression ")" statement ( "else" statement )? ;
return_stmt      -> "return" expression? ";" ;
while_stmt       -> "while" "(" expression ")" statement ;

write_stmt       -> "write" expression ";" ;
tag_stmt         -> "tag" STRING with_clause? ( ";" | "{" declaration* "}" ) ;
with_clause      -> "with" attribute ( "," attribute )* ;
attribute        -> ( IDENTIFIER | STRING ) ":" expression ;

expression       -> assignment ;

assignment       -> ( IDENTIFIER | value ( get | index ) ) "=" expression 
                  | ternary_expr ;

ternary_expr     -> null_coalesce ( "?" expression ":" expression )? ;

null_coalesce    -> concatenation ( "??" expression )? ;

concatenation    -> logic_or ( ".." logic_or )* ;

logic_or         -> logic_and ( "or" logic_and )* ;
logic_and        -> equality ( "and" equality )* ;

equality         -> comparison ( ( "==" | "!=" ) comparison )* ;
comparison       -> addition ( ( ">" | ">=" | "<" | "<=" ) addition )* ;
addition         -> multiplication ( ( "-" | "+" ) multiplication )* ;
multiplication   -> unary ( ( "/" | "*" | "%" ) unary )* ;

unary            -> ( ( "!" | "-" | "#" ) unary ) 
                  | ( value ( "++" | "--" )* ) ;
				
value            -> function ;

function         -> "fn" "(" parameters? ")" ( block_stmt | "=>" expression )
                  | map ;
parameters       -> parameter ( "," parameter )* ;
parameter        -> IDENTIFIER ( "=" value )? ;

map              -> "{" ( key_value_pair ( "," key_value_pair )* )? "}"
                  | array ;
key_value_pair   -> expression ":" expression ;

array            -> "[" ( expression ( "," expression )* )? "]" 
                  | html ;

html             -> "html" "{" declaration* "}" ;
                  | access ;

access           -> primary ( get | index | call )* ;

get              -> "." IDENTIFIER ;

index            -> "[" expression "]" ; 

call             -> "(" arguments? ")" ;
arguments        -> argument ( "," argument )* ;
argument         -> ( IDENTIFIER ":" )? expression ;

primary          -> IDENTIFIER | NUMBER | STRING | "false" | "true" | "null"
                  | "(" expression ")" ;
```