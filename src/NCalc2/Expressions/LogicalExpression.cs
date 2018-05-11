using NCalc2.Visitors;

namespace NCalc2.Expressions
{
    public abstract class LogicalExpression
    {
        public override string ToString()
        {
            var serializer = new SerializationVisitor();
            this.Accept(serializer);

            return serializer.Result.ToString().TrimEnd(' ');
        }

        public abstract void Accept(LogicalExpressionVisitor visitor);
    }
}