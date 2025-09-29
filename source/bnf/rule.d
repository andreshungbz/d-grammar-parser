/// bnf.rule defines structures for the RHS (Alternative) and LHS (Rule) of the BNF grammar
/// these are mainly used for printing the grammar
module bnf.rule;

import bnf.symbols;

/// Alternative represents a possible RHS for a nonterminal
struct Alternative
{
  Symbol[] symbols;

  // string formatting
  string toString() const
  {
    string result;
    foreach (i, s; symbols)
    {
      // ensure that symbols {<x> <y> ,} do not have a space between each other
      if (i > 0
        && s.value != ","
        && symbols[i - 1].value != ","
        && !(symbols[i - 1].value == "<x>" && s.value == "<y>")
        )
      {
        result ~= " ";
      }
      result ~= s.value;
    }
    return result;
  }
}

/// Rule associates a nonterminal with their possible RHSs
struct Rule
{
  NonTerminal nonTerminal;
  Alternative[] alternatives;

  /// alternativesToString returns the RHSs delimited with " | "
  string alternativesToString() const
  {
    import std.algorithm : joiner, map;
    import std.conv : to;

    return alternatives
      .map!(a => a.toString) // Alternative's toString() ensures each symbol is delimited by a space except for {<x> <y> ,}
      .joiner(" | ")
      .to!string;
  }
}
