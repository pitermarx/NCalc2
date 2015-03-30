using NCalc2.Visitors;

namespace NCalc2.Expressions
{
    public class IdentifierExpression : LogicalExpression
    {
        public IdentifierExpression(string name)
        {
            Name = name;
        }

        public string Name { get; set; }

        public override void Accept(LogicalExpressionVisitor visitor)
        {
            visitor.Visit(this);
        }
    }
}