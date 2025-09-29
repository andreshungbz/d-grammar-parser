/// bnf.symbols contains enumrations and a unified struct Symbol for the BNF grammar
module bnf.symbols;

enum Terminal : string
{
  // keywords
  HI = "HI",
  BYE = "BYE",
  BAR = "bar",
  LINE = "line",
  FILL = "fill",

  // punctuation
  SEMICOLON = ";",
  COMMA = ",",

  // valid X values
  A = "A",
  B = "B",
  C = "C",
  D = "D",
  E = "E",

  // valid Y values
  ONE = "1",
  TWO = "2",
  THREE = "3",
  FOUR = "4",
  FIVE = "5",

  EOF = "<EOF>", // indicates end of input
  ERROR = "<ERROR>" // indicates invalid lexeme
}

enum NonTerminal : string
{
  GRAPH = "<graph>",
  DRAW = "<draw>",
  ACTION = "<action>",
  X = "<x>",
  Y = "<y>"
}

/// Symbol represents a unified view (either terminal or nonterminal)
struct Symbol
{
  bool isTerminal;
  string value;

  // constructors

  static Symbol T(Terminal t)
  {
    return Symbol(true, t);
  }

  static Symbol NT(NonTerminal nt)
  {
    return Symbol(false, nt);
  }

  // string formatting
  string toString() const
  {
    return value;
  }
}

/// terminalFromString is an associate array mapping strings to their enum types
immutable Terminal[string] terminalFromString =
{
  import std.traits : EnumMembers;

  Terminal[string] map;
  foreach (t; EnumMembers!Terminal)
  {
    map[t] = t;
  }
  return map;
}();
