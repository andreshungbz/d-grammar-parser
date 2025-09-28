/// bnf.symbols contains enumrations and a unified struct Symbol for the BNF grammar
module bnf.symbols;

enum Terminal : string
{
  HI = "HI",
  BYE = "BYE",
  BAR = "bar",
  LINE = "line",
  FILL = "fill",

  SEMICOLON = ";",
  COMMA = ",",

  A = "A",
  B = "B",
  C = "C",
  D = "D",
  E = "E",

  ONE = "1",
  TWO = "2",
  THREE = "3",
  FOUR = "4",
  FIVE = "5",

  EOF = "<EOF>", // indicates where parsing ends
  ERROR = "<ERROR>" // error to indicate invalid lexeme
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

  /// Constructor that builds a terminal symbol
  static Symbol T(Terminal t)
  {
    return Symbol(true, t);
  }

  /// Constructor that builds a nonterminal symbol
  static Symbol NT(NonTerminal nt)
  {
    return Symbol(false, nt);
  }

  // string formatting shows the value only
  string toString() const
  {
    return value;
  }
}

// terminalFromString is an associate array mapping strings to their enum types
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
