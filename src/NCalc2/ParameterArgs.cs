using System;

namespace NCalc2
{
    public class ParameterArgs : EventArgs
    {
        private object result;

        public object Result
        {
            get { return result; }
            set
            {
                result = value;
                HasResult = true;
            }
        }

        public bool HasResult { get; set; }
    }
}