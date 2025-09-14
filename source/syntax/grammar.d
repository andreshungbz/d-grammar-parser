// Grammar definition

module syntax.grammar;

import syntax.symbols;
import std.algorithm : map;
import std.array : join;

/** 
 * Alternative represents an options that a nonterminal can derive to, consisting of symbols.
 */
struct Alternative
{
  string[] symbols;

  // string representation
  string toString() const
  {
    string result;
    foreach (i, sym; symbols)
    {
      // no space before comma or at start, and no space between <x><y>
      if (i > 0 && sym != "," && symbols[i - 1] != ","
        && !(symbols[i - 1] == "<x>" && sym == "<y>"))
        result ~= " ";
      result ~= sym;
    }
    return result;
  }
}

/** 
 * Rule represents a nonterminal string and an array of Alternatives.
 */
struct Rule
{
  string nonTerminal;
  Alternative[] alternatives;
}

/** 
 * BNF rules defined in the program specification.
 */
Rule[5] rules = [
  Rule(NonTerminal.GRAPH, [
      Alternative([Terminal.HI, NonTerminal.DRAW, Terminal.BYE])
    ]),
  Rule(NonTerminal.DRAW, [
      Alternative([NonTerminal.ACTION]),
      Alternative([NonTerminal.ACTION, Terminal.SEMICOLON, NonTerminal.DRAW])
    ]),
  Rule(NonTerminal.ACTION, [
      Alternative([
        Terminal.BAR, NonTerminal.X, NonTerminal.Y, Terminal.COMMA, NonTerminal.Y
      ]),
      Alternative([
        Terminal.LINE, NonTerminal.X, NonTerminal.Y, Terminal.COMMA, NonTerminal.X,
        NonTerminal.Y
      ]),
      Alternative([Terminal.FILL, NonTerminal.X, NonTerminal.Y])
    ]),
  Rule(NonTerminal.X, [
      Alternative([Terminal.A]),
      Alternative([Terminal.B]),
      Alternative([Terminal.C]),
      Alternative([Terminal.D]),
      Alternative([Terminal.E])
    ]),
  Rule(NonTerminal.Y, [
      Alternative([Terminal.ONE]),
      Alternative([Terminal.TWO]),
      Alternative([Terminal.THREE]),
      Alternative([Terminal.FOUR]),
      Alternative([Terminal.FIVE])
    ])
];
