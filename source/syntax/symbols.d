module syntax.symbols;

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
  FIVE = "5"
}

enum NonTerminal : string
{
  GRAPH = "<graph>",
  DRAW = "<draw>",
  ACTION = "<action>",
  X = "<x>",
  Y = "<y>"
}
