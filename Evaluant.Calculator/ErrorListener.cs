using System.Collections.Generic;
using Antlr4.Runtime;

namespace NCalc2
{
    public class ErrorListener : IAntlrErrorListener<IToken>
    {
        public readonly List<string> Errors = new List<string>();

        public void SyntaxError(IRecognizer recognizer, IToken offendingSymbol, int line, int charPositionInLine, string msg,
            RecognitionException e)
        {
            Errors.Add(string.Format("{0} at {1}:{2}", msg, line, charPositionInLine));
        }
    }
}