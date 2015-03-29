using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using Antlr4.Runtime;
using NCalc2.Domain;

namespace NCalc2
{
    public class NCalc2Visitor : NCalc2BaseVisitor<LogicalExpression>
    {
        public static readonly NumberFormatInfo NumberFormatInfo = new NumberFormatInfo();

        static NCalc2Visitor()
        {
            NumberFormatInfo.NumberDecimalSeparator = ".";
        }

        private static string ExtractString(string text)
        {
            var sb = new StringBuilder(text);
            int slashIndex, startIndex = 1; // Skip initial quote

            while ((slashIndex = sb.ToString().IndexOf('\\', startIndex)) != -1)
            {
                char escapeType = sb[slashIndex + 1];
                switch (escapeType)
                {
                    case 'u':
                        string hcode = String.Concat(sb[slashIndex + 4], sb[slashIndex + 5]);
                        string lcode = String.Concat(sb[slashIndex + 2], sb[slashIndex + 3]);
                        char unicodeChar = Encoding.Unicode.GetChars(new[] { Convert.ToByte(hcode, 16), Convert.ToByte(lcode, 16) })[0];
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

        private LogicalExpression Aggregate<T1, T2>(IEnumerable<T1> items, T2 seed, BinaryExpressionType type)
            where T1 : ParserRuleContext
            where T2 : ParserRuleContext
        {
            var res = items.Aggregate(Visit(seed), 
                (current, item) => 
                    new BinaryExpression(type, current, Visit(item)));
            return res;
        }

        public override LogicalExpression VisitNcalc(NCalc2Parser.NcalcContext context)
        {
            return Visit(context.expr());
        }

        public override LogicalExpression VisitTernaryExpression(NCalc2Parser.TernaryExpressionContext context)
        {
            var expr = context.orExpr();
            return new TernaryExpression(Visit(expr[0]), Visit(expr[1]), Visit(expr[2]));
        }

        public override LogicalExpression VisitToOrExpression(NCalc2Parser.ToOrExpressionContext context)
        {
            return Visit(context.orExpr());
        }

        public override LogicalExpression VisitOrExpression(NCalc2Parser.OrExpressionContext context)
        {
            return new BinaryExpression(BinaryExpressionType.Or, Visit(context.orExpr()), Visit(context.andExpr()));
        }

        public override LogicalExpression VisitToAndExpression(NCalc2Parser.ToAndExpressionContext context)
        {
            return Visit(context.andExpr());
        }

        public override LogicalExpression VisitAndExpression(NCalc2Parser.AndExpressionContext context)
        {
            return new BinaryExpression(BinaryExpressionType.And, Visit(context.andExpr()), Visit(context.bitOrExpr()));
        }

        public override LogicalExpression VisitToBitOrExpression(NCalc2Parser.ToBitOrExpressionContext context)
        {
            return Visit(context.bitOrExpr());
        }

        public override LogicalExpression VisitBitOrExpression(NCalc2Parser.BitOrExpressionContext context)
        {
            return new BinaryExpression(BinaryExpressionType.BitwiseOr, Visit(context.bitOrExpr()), Visit(context.bitOrExpr()));
        }

        public override LogicalExpression VisitToBitXorExpression(NCalc2Parser.ToBitXorExpressionContext context)
        {
            return Visit(context.bitXorExpr());
        }

        public override LogicalExpression VisitBitXorExpression(NCalc2Parser.BitXorExpressionContext context)
        {
            return new BinaryExpression(BinaryExpressionType.BitwiseXOr, Visit(context.bitXorExpr()), Visit(context.bitAndExpr()));
        }

        public override LogicalExpression VisitToBitAndExpression(NCalc2Parser.ToBitAndExpressionContext context)
        {
            return Visit(context.bitAndExpr());
        }

        public override LogicalExpression VisitBitAndExpression(NCalc2Parser.BitAndExpressionContext context)
        {
            return new BinaryExpression(BinaryExpressionType.BitwiseAnd, Visit(context.bitAndExpr()), Visit(context.eqExpr()));
        }

        public override LogicalExpression VisitToEqualExpression(NCalc2Parser.ToEqualExpressionContext context)
        {
            return Visit(context.eqExpr());
        }

        public override LogicalExpression VisitEqualExpression(NCalc2Parser.EqualExpressionContext context)
        {
            return new BinaryExpression(BinaryExpressionType.Equal, Visit(context.eqExpr()), Visit(context.relExpr()));
        }

        public override LogicalExpression VisitNotEqualExpression(NCalc2Parser.NotEqualExpressionContext context)
        {
            return new BinaryExpression(BinaryExpressionType.NotEqual, Visit(context.eqExpr()), Visit(context.relExpr()));
        }

        public override LogicalExpression VisitToRelationalExpression(NCalc2Parser.ToRelationalExpressionContext context)
        {
            return Visit(context.relExpr());
        }

        public override LogicalExpression VisitLessExpression(NCalc2Parser.LessExpressionContext context)
        {
            return new BinaryExpression(BinaryExpressionType.Lesser, Visit(context.relExpr()), Visit(context.shiftExpr()));
        }

        public override LogicalExpression VisitLessOrEqualExpression(NCalc2Parser.LessOrEqualExpressionContext context)
        {
            return new BinaryExpression(BinaryExpressionType.LesserOrEqual, Visit(context.relExpr()), Visit(context.shiftExpr()));
        }

        public override LogicalExpression VisitGreaterExpression(NCalc2Parser.GreaterExpressionContext context)
        {
            return new BinaryExpression(BinaryExpressionType.Greater, Visit(context.relExpr()), Visit(context.shiftExpr()));
        }

        public override LogicalExpression VisitGreaterOrEqualExpression(NCalc2Parser.GreaterOrEqualExpressionContext context)
        {
            return new BinaryExpression(BinaryExpressionType.GreaterOrEqual, Visit(context.relExpr()), Visit(context.shiftExpr()));
        }

        public override LogicalExpression VisitToShiftExpression(NCalc2Parser.ToShiftExpressionContext context)
        {
            return Visit(context.shiftExpr());
        }

        public override LogicalExpression VisitShiftLeftExpression(NCalc2Parser.ShiftLeftExpressionContext context)
        {
            return new BinaryExpression(BinaryExpressionType.LeftShift, Visit(context.shiftExpr()), Visit(context.addExpr()));
        }

        public override LogicalExpression VisitShiftRightExpression(NCalc2Parser.ShiftRightExpressionContext context)
        {
            return new BinaryExpression(BinaryExpressionType.RightShift, Visit(context.shiftExpr()), Visit(context.addExpr()));
        }

        public override LogicalExpression VisitToAddExpression(NCalc2Parser.ToAddExpressionContext context)
        {
            return Visit(context.addExpr());
        }

        public override LogicalExpression VisitAddExpression(NCalc2Parser.AddExpressionContext context)
        {
            return new BinaryExpression(BinaryExpressionType.Plus, Visit(context.addExpr()), Visit(context.multExpr()));
        }

        public override LogicalExpression VisitSubtractExpression(NCalc2Parser.SubtractExpressionContext context)
        {
            return new BinaryExpression(BinaryExpressionType.Minus, Visit(context.addExpr()), Visit(context.multExpr()));
        }

        public override LogicalExpression VisitToMultExpression(NCalc2Parser.ToMultExpressionContext context)
        {
            return Visit(context.multExpr());
        }

        public override LogicalExpression VisitMultiplyExpression(NCalc2Parser.MultiplyExpressionContext context)
        {
            return new BinaryExpression(BinaryExpressionType.Times, Visit(context.multExpr()), Visit(context.unaryExpr()));
        }

        public override LogicalExpression VisitDivideExpression(NCalc2Parser.DivideExpressionContext context)
        {
            return new BinaryExpression(BinaryExpressionType.Div, Visit(context.multExpr()), Visit(context.unaryExpr()));
        }

        public override LogicalExpression VisitModuloExpression(NCalc2Parser.ModuloExpressionContext context)
        {
            return new BinaryExpression(BinaryExpressionType.Modulo, Visit(context.multExpr()), Visit(context.unaryExpr()));
        }

        public override LogicalExpression VisitToUnaryExpression(NCalc2Parser.ToUnaryExpressionContext context)
        {
            return Visit(context.unaryExpr());
        }

        public override LogicalExpression VisitNotExpression(NCalc2Parser.NotExpressionContext context)
        {
            return new UnaryExpression(UnaryExpressionType.Not, Visit(context.primaryExpr()));
        }

        public override LogicalExpression VisitBitNotExpression(NCalc2Parser.BitNotExpressionContext context)
        {
            return new UnaryExpression(UnaryExpressionType.BitwiseNot, Visit(context.primaryExpr()));
        }

        public override LogicalExpression VisitNegateExpression(NCalc2Parser.NegateExpressionContext context)
        {
            return new UnaryExpression(UnaryExpressionType.Negate, Visit(context.primaryExpr()));
        }

        public override LogicalExpression VisitToPrimaryExpression(NCalc2Parser.ToPrimaryExpressionContext context)
        {
            return Visit(context.primaryExpr());
        }

        public override LogicalExpression VisitToLogicalExpression(NCalc2Parser.ToLogicalExpressionContext context)
        {
            return Visit(context.expr());
        }

        public override LogicalExpression VisitToValue(NCalc2Parser.ToValueContext context)
        {
            return Visit(context.value());
        }

        public override LogicalExpression VisitFunction(NCalc2Parser.FunctionContext context)
        {
            var id = Visit(context.id());
            var args = context.expr().Select(Visit).ToArray();
            return new Function((Identifier) id, args);
        }

        public override LogicalExpression VisitToIdentifier(NCalc2Parser.ToIdentifierContext context)
        {
            return Visit(context.id());
        }

        public override LogicalExpression VisitInteger(NCalc2Parser.IntegerContext context)
        {
            try
            {
                return new ValueExpression(int.Parse(context.INTEGER().GetText()));
            }
            catch
            {
                return new ValueExpression(long.Parse(context.INTEGER().GetText()));
            }
        }

        public override LogicalExpression VisitFloat(NCalc2Parser.FloatContext context)
        {
            return new ValueExpression(double.Parse(context.FLOAT().GetText(), NumberStyles.Float, NumberFormatInfo));
        }

        public override LogicalExpression VisitString(NCalc2Parser.StringContext context)
        {
            return new ValueExpression(ExtractString(context.STRING().GetText()));
        }

        public override LogicalExpression VisitDateTime(NCalc2Parser.DateTimeContext context)
        {
            var datetext = context.DATETIME().GetText();
            var date = DateTime.Parse(datetext.Substring(1, datetext.Length - 2));
            return new ValueExpression(date);
        }

        public override LogicalExpression VisitTrue(NCalc2Parser.TrueContext context)
        {
            return new ValueExpression(true);
        }

        public override LogicalExpression VisitFalse(NCalc2Parser.FalseContext context)
        {
            return new ValueExpression(false);
        }

        public override LogicalExpression VisitVariable(NCalc2Parser.VariableContext context)
        {
            var name = context.VAR().GetText();
            return new Identifier(name.Substring(1, name.Length - 2));
        }

        public override LogicalExpression VisitName(NCalc2Parser.NameContext context)
        {
            return new Identifier(context.NAME().GetText());
        }
    }
}