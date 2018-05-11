grammar NCalc2;

options{language=CSharp3;}

@header {
using System;
using System.Text;
using System.Globalization;
using System.Collections.Generic;
using NCalc2.Expressions;
using ValueType = NCalc2.Expressions.ValueType;
}

@members {
private const char BS = '\\';
private static NumberFormatInfo numberFormatInfo = new NumberFormatInfo();

private string extractString(string text) {
    
    StringBuilder sb = new StringBuilder(text);
    int startIndex = 1; // Skip initial quote
    int slashIndex = -1;

    while ((slashIndex = sb.ToString().IndexOf(BS, startIndex)) != -1)
    {
        char escapeType = sb[slashIndex + 1];
        switch (escapeType)
        {
            case 'u':
              string hcode = String.Concat(sb[slashIndex+4], sb[slashIndex+5]);
              string lcode = String.Concat(sb[slashIndex+2], sb[slashIndex+3]);
              char unicodeChar = Encoding.Unicode.GetChars(new byte[] { System.Convert.ToByte(hcode, 16), System.Convert.ToByte(lcode, 16)} )[0];
              sb.Remove(slashIndex, 6).Insert(slashIndex, unicodeChar); 
              break;
            case 'n': sb.Remove(slashIndex, 2).Insert(slashIndex, '\n'); break;
            case 'r': sb.Remove(slashIndex, 2).Insert(slashIndex, '\r'); break;
            case 't': sb.Remove(slashIndex, 2).Insert(slashIndex, '\t'); break;
            case '\'': sb.Remove(slashIndex, 2).Insert(slashIndex, '\''); break;
            case '\\': sb.Remove(slashIndex, 2).Insert(slashIndex, '\\'); break;
            default: throw new Exception("Unvalid escape sequence: \\" + escapeType);
        }

        startIndex = slashIndex + 1;

    }

    sb.Remove(0, 1);
    sb.Remove(sb.Length - 1, 1);

    return sb.ToString();
}
}

@init {
    numberFormatInfo.NumberDecimalSeparator = ".";
}
ncalc returns[LogicalExpression retValue] 
    : expr EOF { $retValue = $expr.retValue;}
    ;

expr returns[LogicalExpression retValue]
    : first=orExpr '?' middle=expr ':' right=expr   { $retValue = new TernaryExpression($first.retValue, $middle.retValue, $right.retValue);}
    | orExpr                                        { $retValue = $orExpr.retValue;}
    ;

orExpr returns[LogicalExpression retValue] 
    : first=orExpr ('||'|'or') andExpr      { $retValue = new BinaryExpression(BinaryExpressionType.Or, $first.retValue, $andExpr.retValue);}
    | andExpr                               { $retValue = $andExpr.retValue;}
    ;

andExpr returns[LogicalExpression retValue] 
    : first=andExpr ('&&'|'and') bitOrExpr  { $retValue = new BinaryExpression(BinaryExpressionType.And, $first.retValue, $bitOrExpr.retValue);}
    | bitOrExpr                             { $retValue = $bitOrExpr.retValue;}
    ;

bitOrExpr returns[LogicalExpression retValue] 
    : first=bitOrExpr '|' bitXorExpr    { $retValue = new BinaryExpression(BinaryExpressionType.BitwiseOr, $first.retValue, $bitXorExpr.retValue);}
    | bitXorExpr                        { $retValue = $bitXorExpr.retValue;}
    ;

bitXorExpr returns[LogicalExpression retValue] 
    : first=bitXorExpr '^' bitAndExpr   { $retValue = new BinaryExpression(BinaryExpressionType.BitwiseXOr, $first.retValue, $bitAndExpr.retValue);}
    | bitAndExpr                        { $retValue = $bitAndExpr.retValue;}
    ;

bitAndExpr returns[LogicalExpression retValue] 
    : first=bitAndExpr '&' eqExpr       { $retValue = new BinaryExpression(BinaryExpressionType.BitwiseAnd, $first.retValue, $eqExpr.retValue);}
    | eqExpr                            { $retValue = $eqExpr.retValue;}
    ;

eqExpr returns[LogicalExpression retValue] 
    : first=eqExpr ('=='|'=')  relExpr  { $retValue = new BinaryExpression(BinaryExpressionType.Equal, $first.retValue, $relExpr.retValue);}
    | first=eqExpr ('!='|'<>') relExpr  { $retValue = new BinaryExpression(BinaryExpressionType.NotEqual, $first.retValue, $relExpr.retValue);}
    | relExpr                           { $retValue = $relExpr.retValue;}
    ;

relExpr returns[LogicalExpression retValue] 
    : first=relExpr '<'  shiftExpr      { $retValue = new BinaryExpression(BinaryExpressionType.Lesser, $first.retValue, $shiftExpr.retValue);}
    | first=relExpr '<=' shiftExpr      { $retValue = new BinaryExpression(BinaryExpressionType.LesserOrEqual, $first.retValue, $shiftExpr.retValue);}
    | first=relExpr '>'  shiftExpr      { $retValue = new BinaryExpression(BinaryExpressionType.Greater, $first.retValue, $shiftExpr.retValue);}
    | first=relExpr '>=' shiftExpr      { $retValue = new BinaryExpression(BinaryExpressionType.GreaterOrEqual, $first.retValue, $shiftExpr.retValue);}
    | shiftExpr                         { $retValue = $shiftExpr.retValue;}
    ;

shiftExpr returns[LogicalExpression retValue] 
    : first=shiftExpr '<<' addExpr      { $retValue = new BinaryExpression(BinaryExpressionType.LeftShift, $first.retValue, $addExpr.retValue);}
    | first=shiftExpr '>>' addExpr      { $retValue = new BinaryExpression(BinaryExpressionType.RightShift, $first.retValue, $addExpr.retValue);}
    | addExpr                           { $retValue = $addExpr.retValue;}
    ;

addExpr returns[LogicalExpression retValue] 
    : first=addExpr '+' multExpr        { $retValue = new BinaryExpression(BinaryExpressionType.Plus, $first.retValue, $multExpr.retValue);}
    | first=addExpr '-' multExpr        { $retValue = new BinaryExpression(BinaryExpressionType.Minus, $first.retValue, $multExpr.retValue);}
    | multExpr                          { $retValue = $multExpr.retValue;}
    ;                                   

multExpr returns[LogicalExpression retValue] 
    : first=multExpr '*' unaryExpr      { $retValue = new BinaryExpression(BinaryExpressionType.Times, $first.retValue, $unaryExpr.retValue);}
    | first=multExpr '/' unaryExpr      { $retValue = new BinaryExpression(BinaryExpressionType.Div, $first.retValue, $unaryExpr.retValue);}
    | first=multExpr '%' unaryExpr      { $retValue = new BinaryExpression(BinaryExpressionType.Modulo, $first.retValue, $unaryExpr.retValue);}
    | unaryExpr                         { $retValue = $unaryExpr.retValue;}
    ;
    
unaryExpr returns[LogicalExpression retValue] 
    : ('!' | 'not') primaryExpr         { $retValue = new UnaryExpression(UnaryExpressionType.Not, $primaryExpr.retValue);}
    | '~' primaryExpr                   { $retValue = new UnaryExpression(UnaryExpressionType.BitwiseNot, $primaryExpr.retValue);}
    | '-' primaryExpr                   { $retValue = new UnaryExpression(UnaryExpressionType.Negate, $primaryExpr.retValue);}
    | primaryExpr                       { $retValue = $primaryExpr.retValue;}
    ;

primaryExpr returns[LogicalExpression retValue] 
    @init { var args = new List<LogicalExpression>(); }
    : '(' expr ')'                      { $retValue = $expr.retValue;}
    | value                             { $retValue = $value.retValue;}
    | id 
        '(' expr                        { args.Add($expr.retValue);} 
            (',' expr                   { args.Add($expr.retValue);}
            )*
        ')'                             { $retValue = new FunctionExpression((IdentifierExpression)$id.retValue, args.ToArray());}
    | id                                { $retValue = $id.retValue;}
    ;

value returns[LogicalExpression retValue]
    : INTEGER     { try{ $retValue = new ValueExpression(int.Parse($INTEGER.text), ValueType.Integer);} catch { $retValue = new ValueExpression(long.Parse($INTEGER.text), ValueType.Integer); } }
    | FLOAT       { $retValue = new ValueExpression(double.Parse($FLOAT.text, NumberStyles.Float, numberFormatInfo), ValueType.Float);}
    | STRING      { $retValue = new ValueExpression(extractString($STRING.text), ValueType.String);}
    | DATETIME    { $retValue = new ValueExpression(DateTime.Parse($DATETIME.text.Substring(1, $DATETIME.text.Length - 2)), ValueType.DateTime);}
    | TRUE        { $retValue = new ValueExpression(true, ValueType.Boolean);}
    | FALSE       { $retValue = new ValueExpression(false, ValueType.Boolean);}
    ;

id returns[LogicalExpression retValue]
    : NAME { $retValue = new IdentifierExpression($NAME.text); }
    | VAR  { $retValue = new IdentifierExpression($VAR.text.Substring(1, $VAR.text.Length - 2)); }
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