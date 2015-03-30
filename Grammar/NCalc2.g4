grammar NCalc2;

options{language=CSharp3;}

ncalc
    : expr EOF
    ;

expr
    : orExpr '?' orExpr ':' orExpr      #ternaryExpression
    |   orExpr                          #toOrExpression
    ;

orExpr
    : orExpr ('||'|'or') andExpr        #orExpression
    | andExpr                           #toAndExpression
    ;

andExpr
    : andExpr ('&&'|'and') bitOrExpr    #andExpression
    | bitOrExpr                         #toBitOrExpression
    ;

bitOrExpr
    : bitOrExpr '|' bitXorExpr          #bitOrExpression
    | bitXorExpr                        #toBitXorExpression
    ;

bitXorExpr
    : bitXorExpr '^' bitAndExpr         #bitXorExpression
    | bitAndExpr                        #toBitAndExpression
    ;

bitAndExpr
    : bitAndExpr '&' eqExpr             #bitAndExpression
    | eqExpr                            #toEqualExpression
    ;

eqExpr
    : eqExpr ('=='|'=')	 relExpr        #equalExpression
    | eqExpr ('!='|'<>') relExpr        #notEqualExpression
    | relExpr                           #toRelationalExpression
    ;

relExpr
    : relExpr '<'  shiftExpr            #lessExpression
    | relExpr '<=' shiftExpr            #lessOrEqualExpression
    | relExpr '>'  shiftExpr            #greaterExpression
    | relExpr '>=' shiftExpr            #greaterOrEqualExpression
    | shiftExpr                         #toShiftExpression
    ;

shiftExpr
    : shiftExpr '<<' addExpr            #shiftLeftExpression
    | shiftExpr '>>' addExpr            #shiftRightExpression
    | addExpr                           #toAddExpression
    ;

addExpr
    : addExpr '+' multExpr              #addExpression
    | addExpr '-' multExpr              #subtractExpression
    | multExpr                          #toMultExpression
    ;

multExpr
    : multExpr '*' unaryExpr            #multiplyExpression
    | multExpr '/' unaryExpr            #divideExpression
    | multExpr '%' unaryExpr            #moduloExpression
    | unaryExpr                         #toUnaryExpression
    ;

unaryExpr
    : ('!' | 'not') primaryExpr         #notExpression
    | '~' primaryExpr                   #bitNotExpression
    | '-' primaryExpr                   #negateExpression
    | primaryExpr                       #toPrimaryExpression
    ;

primaryExpr
    : '(' expr ')'                      #toLogicalExpression
    | value                             #toValue
    | id '(' expr (',' expr)* ')'       #function
    | id                                #toIdentifier
    ;

value
    :   INTEGER     #Integer
    |   FLOAT       #Float
    |   STRING      #String
    |   DATETIME    #DateTime
    |   TRUE        #True
    |   FALSE       #False
    ;

id
    :   NAME        #Name
    |   VAR         #Variable
    ;

TRUE    : 'true'  ;
FALSE   : 'false' ;
NAME    : LETTER (LETTER | DIGIT)* ;
INTEGER : DIGIT+  ;
DATETIME: '#' (~('#')*) '#' ;
VAR     : '[' (~(']')*) ']' ;
E       : ('E'|'e') ('+'|'-')? DIGIT+ ;

FLOAT
    : DIGIT* '.' DIGIT+ E?
    | DIGIT+ E
    ;
STRING
    : '\'' 
      ( EscapeSequence 
      | (~('\u0000'..'\u001f' | '\\' | '\''))
      )*
      '\''
    ;

fragment LETTER
    : 'a'..'z'
    | 'A'..'Z'
    | '_'
    ;

fragment DIGIT : '0'..'9';
fragment EscapeSequence 
    : '\\'
        ( 'n'
        | 'r'
        | 't'
        | '\''
        | '\\'
        | UnicodeEscape
        )
    ;

fragment HexDigit : ('0'..'9'|'a'..'f'|'A'..'F');
fragment UnicodeEscape : 'u' HexDigit HexDigit HexDigit HexDigit;

/* Ignore white spaces */	
WS : (' '|'\r'|'\t'|'\u000C'|'\n') -> skip;