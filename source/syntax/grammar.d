// Grammar definition

module syntax.grammar;

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
        && !((symbols[i - 1] == "<x>" && sym == "<y>")))
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
  Rule("<graph>", [
      Alternative(["HI", "<draw>", "BYE"])
    ]),
  Rule("<draw>", [
      Alternative(["<action>"]),
      Alternative(["<action>", ";", "<draw>"])
    ]),
  Rule("<action>", [
      Alternative(["bar", "<x>", "<y>", ",", "<y>"]),
      Alternative(["line", "<x>", "<y>", ",", "<x>", "<y>"]),
      Alternative(["fill", "<x>", "<y>"])
    ]),
  Rule("<x>", [
      Alternative(["A"]),
      Alternative(["B"]),
      Alternative(["C"]),
      Alternative(["D"]),
      Alternative(["E"])
    ]),
  Rule("<y>", [
      Alternative(["1"]),
      Alternative(["2"]),
      Alternative(["3"]),
      Alternative(["4"]),
      Alternative(["5"])
    ])
];
