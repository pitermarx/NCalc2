grammar NCalc;

options
{
	output=AST;
	ASTLabelType=CommonTree;
	language=CSharp3;
}

@header {
using System;
using System.Text;
using System.Globalization;
using System.Collections.Generic;
using NCalc.Domain;
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
	            default: throw new RecognitionException("Unvalid escape sequence: \\" + escapeType, this, InputStream, null);
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

ncalcExpression returns [LogicalExpression retval]
	: logicalExpression EOF  { $retval = $logicalExpression.retval; }
	;

logicalExpression returns [LogicalExpression retval]
	:	left=conditionalExpression { $retval = $left.retval; } 
		( '?' middle=conditionalExpression ':' right=conditionalExpression { $retval = new TernaryExpression($left.retval, $middle.retval, $right.retval); })? 
	;

conditionalExpression returns [LogicalExpression retval]
@init {
BinaryExpressionType type = BinaryExpressionType.Unknown;
}
	:	left=booleanAndExpression { $retval = $left.retval; } (
			('||' | 'or') { type = BinaryExpressionType.Or; } 
			right=conditionalExpression { $retval = new BinaryExpression(type, $retval, $right.retval); } 
			)* 
	;
		
booleanAndExpression returns [LogicalExpression retval]
@init {
BinaryExpressionType type = BinaryExpressionType.Unknown;
}
	:	left=bitwiseOrExpression { $retval = $left.retval; } (
			('&&' | 'and') { type = BinaryExpressionType.And; } 
			right=bitwiseOrExpression { $retval = new BinaryExpression(type, $retval, $right.retval); } 
			)* 
	;

bitwiseOrExpression returns [LogicalExpression retval]
@init {
BinaryExpressionType type = BinaryExpressionType.Unknown;
}
	:	left=bitwiseXOrExpression { $retval = $left.retval; } (
			'|' { type = BinaryExpressionType.BitwiseOr; } 
			right=bitwiseOrExpression { $retval = new BinaryExpression(type, $retval, $right.retval); } 
			)* 
	;
		
bitwiseXOrExpression returns [LogicalExpression retval]
@init {
BinaryExpressionType type = BinaryExpressionType.Unknown;
}
	:	left=bitwiseAndExpression { $retval = $left.retval; } (
			'^' { type = BinaryExpressionType.BitwiseXOr; } 
			right=bitwiseAndExpression { $retval = new BinaryExpression(type, $retval, $right.retval); } 
			)* 
	;

bitwiseAndExpression returns [LogicalExpression retval]
@init {
BinaryExpressionType type = BinaryExpressionType.Unknown;
}
	:	left=equalityExpression { $retval = $left.retval; } (
			'&' { type = BinaryExpressionType.BitwiseAnd; } 
			right=equalityExpression { $retval = new BinaryExpression(type, $retval, $right.retval); } 
			)* 
	;
		
equalityExpression returns [LogicalExpression retval]
@init {
BinaryExpressionType type = BinaryExpressionType.Unknown;
}
	:	left=relationalExpression { $retval = $left.retval; } (
			( ('==' | '=' ) { type = BinaryExpressionType.Equal; } 
			| ('!=' | '<>' ) { type = BinaryExpressionType.NotEqual; } ) 
			right=relationalExpression { $retval = new BinaryExpression(type, $retval, $right.retval); } 
			)* 
	;
	
relationalExpression returns [LogicalExpression retval]
@init {
BinaryExpressionType type = BinaryExpressionType.Unknown;
}
	:	left=shiftExpression { $retval = $left.retval; } (
			( '<' { type = BinaryExpressionType.Lesser; } 
			| '<=' { type = BinaryExpressionType.LesserOrEqual; }  
			| '>' { type = BinaryExpressionType.Greater; } 
			| '>=' { type = BinaryExpressionType.GreaterOrEqual; } ) 
			right=shiftExpression { $retval = new BinaryExpression(type, $retval, $right.retval); } 
			)* 
	;

shiftExpression returns [LogicalExpression retval]
@init {
BinaryExpressionType type = BinaryExpressionType.Unknown;
}
	: left=additiveExpression { $retval = $left.retval; } (
			( '<<' { type = BinaryExpressionType.LeftShift; } 
			| '>>' { type = BinaryExpressionType.RightShift; }  )
			right=additiveExpression { $retval = new BinaryExpression(type, $retval, $right.retval); } 
			)* 
	;

additiveExpression returns [LogicalExpression retval]
@init {
BinaryExpressionType type = BinaryExpressionType.Unknown;
}
	:	left=multiplicativeExpression { $retval = $left.retval; } (
			( '+' { type = BinaryExpressionType.Plus; } 
			| '-' { type = BinaryExpressionType.Minus; } ) 
			right=multiplicativeExpression { $retval = new BinaryExpression(type, $retval, $right.retval); } 
			)* 
	;

multiplicativeExpression returns [LogicalExpression retval]
@init {
BinaryExpressionType type = BinaryExpressionType.Unknown;
}
	:	left=unaryExpression { $retval = $left.retval; } (
			( '*' { type = BinaryExpressionType.Times; } 
			| '/' { type = BinaryExpressionType.Div; } 
			| '%' { type = BinaryExpressionType.Modulo; } ) 
			right=unaryExpression { $retval = new BinaryExpression(type, $retval, $right.retval); } 
			)* 
	;

	
unaryExpression returns [LogicalExpression retval]
	:	primaryExpression { $retval = $primaryExpression.retval; }
    	|	('!' | 'not') primaryExpression { $retval = new UnaryExpression(UnaryExpressionType.Not, $primaryExpression.retval); }
    	|	('~') primaryExpression { $retval = new UnaryExpression(UnaryExpressionType.BitwiseNot, $primaryExpression.retval); }
    	|	'-' primaryExpression { $retval = new UnaryExpression(UnaryExpressionType.Negate, $primaryExpression.retval); }
   	;
		
primaryExpression returns [LogicalExpression retval]
	:	'(' logicalExpression ')' 	{ $retval = $logicalExpression.retval; }
	|	expr=value		{ $retval = $expr.retval; }
	|	identifier {$retval = (LogicalExpression) $identifier.retval; } (arguments {$retval = new Function($identifier.retval, ($arguments.retval).ToArray()); })?
	;

value returns [ValueExpression retval]
	: 	INTEGER		{ try { $retval = new ValueExpression(int.Parse($INTEGER.text)); } catch(System.OverflowException) { $retval = new ValueExpression(long.Parse($INTEGER.text)); } }
	|	FLOAT		{ $retval = new ValueExpression(double.Parse($FLOAT.text, NumberStyles.Float, numberFormatInfo)); }
	|	STRING		{ $retval = new ValueExpression(extractString($STRING.text)); }
	| 	DATETIME	{ $retval = new ValueExpression(DateTime.Parse($DATETIME.text.Substring(1, $DATETIME.text.Length-2))); }
	|	TRUE		{ $retval = new ValueExpression(true); }
	|	FALSE		{ $retval = new ValueExpression(false); }
	;

identifier returns[Identifier retval]
	: 	ID { $retval = new Identifier($ID.text); }
	| 	NAME { $retval = new Identifier($NAME.text.Substring(1, $NAME.text.Length-2)); }
	;

expressionList returns [List<LogicalExpression> retval]
@init {
List<LogicalExpression> expressions = new List<LogicalExpression>();
}
	:	first=logicalExpression {expressions.Add($first.retval);}  ( ',' follow=logicalExpression {expressions.Add($follow.retval);})* 
	{ $retval = expressions; }
	;
	
arguments returns [List<LogicalExpression> retval]
@init {
$retval = new List<LogicalExpression>();
}
	:	'(' ( expressionList {$retval = $expressionList.retval;} )? ')' 
	;			

TRUE
	:	'true'
	;

FALSE
	:	'false'
	;
			
ID 
	: 	LETTER (LETTER | DIGIT)*
	;

INTEGER
	:	DIGIT+
	;

FLOAT 
	:	DIGIT* '.' DIGIT+ E?
	|	DIGIT+ E
	;

STRING
    	:  	'\'' ( EscapeSequence | (options {greedy=false;} : ~('\u0000'..'\u001f' | '\\' | '\'' ) ) )* '\''
    	;

DATETIME 
 	:	'#' (options {greedy=false;} : ~('#')*) '#'
        ;

NAME	:	'[' (options {greedy=false;} : ~(']')*) ']'
	;
	
E	:	('E'|'e') ('+'|'-')? DIGIT+ 
	;	
	
fragment LETTER
	:	'a'..'z'
	|	'A'..'Z'
	|	'_'
	;

fragment DIGIT
	:	'0'..'9'
	;
	
fragment EscapeSequence 
	:	'\\'
  	(	
  		'n' 
	|	'r' 
	|	't'
	|	'\'' 
	|	'\\'
	|	UnicodeEscape
	)
  ;

fragment HexDigit 
	: 	('0'..'9'|'a'..'f'|'A'..'F') ;


fragment UnicodeEscape
    	:    	'u' HexDigit HexDigit HexDigit HexDigit 
    	;

/* Ignore white spaces */	
WS	:  (' '|'\r'|'\t'|'\u000C'|'\n') -> channel(HIDDEN)
	;
		