using System;
using System.Collections.Generic;
using System.Diagnostics;
using NUnit.Framework;

namespace NCalc2.Tests
{
    [TestFixture]
    public class PerformanceTests
    {
        public static void AssertTime(Action action, TimeSpan expected, int times = 1000)
        {
            var stopwatch = Stopwatch.StartNew();
            for (var i = 0; i < times; i += 1) action();
            stopwatch.Stop();
            Console.Write(stopwatch.Elapsed);
            Assert.LessOrEqual(stopwatch.Elapsed, expected);
        }

        private readonly List<string> expressions = new List<string>
        {
            "true ? 1 : false ? 2 : 1",
            "Abs(-1) + Cos(2)",
            "2 + 3 + 5",
            "2 * 3 + 5",
            "2 * (3 + 5)",
            "2 * (2*(2*(2+1)))",
            "10 % 3",
            "true or false",
            "not true",
            "false || not (false and true)",
            "3 > 2 and 1 <= (3-2)",
            "3 % 2 != 10 % 3"
        };

        [Test, Explicit]
        public void ExpressionMixNoCachePerformanceTest()
        {
            AssertTime(() => expressions.ForEach(e => new Expression(e, EvaluateOptions.NoCache).Evaluate()), TimeSpan.FromMilliseconds(500));
        }

        [Test, Explicit]
        public void ExpressionMixCachePerformanceTest()
        {
            // warmup
            expressions.ForEach(e => new Expression(e).Evaluate());
            AssertTime(() => expressions.ForEach(e => new Expression(e).Evaluate()), TimeSpan.FromMilliseconds(25));
        }
    }
}