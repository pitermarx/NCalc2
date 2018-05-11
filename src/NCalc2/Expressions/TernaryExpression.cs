﻿using NCalc2.Visitors;

namespace NCalc2.Expressions
{
    public class TernaryExpression : LogicalExpression
    {
        public TernaryExpression(LogicalExpression leftExpression, LogicalExpression middleExpression, LogicalExpression rightExpression)
        {
            this.LeftExpression = leftExpression;
            this.MiddleExpression = middleExpression;
            this.RightExpression = rightExpression;
        }

        public LogicalExpression LeftExpression { get; set; }

        public LogicalExpression MiddleExpression { get; set; }

        public LogicalExpression RightExpression { get; set; }

        public override void Accept(LogicalExpressionVisitor visitor)
        {
            visitor.Visit(this);
        }
    }
}