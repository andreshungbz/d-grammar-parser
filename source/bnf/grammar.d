/// bnf.grammar defines the grammar rules according to the program specifications
/// these are only used for printing the grammar
module bnf.grammar;

import bnf.rule : Rule, Alternative;
import bnf.symbols : Terminal, NonTerminal, Symbol;

Rule[] rules = [
  // <graph> --> HI <draw> BYE
  Rule(
    NonTerminal.GRAPH,
    [
      Alternative([
        Symbol.T(Terminal.HI),
        Symbol.NT(NonTerminal.DRAW),
        Symbol.T(Terminal.BYE)
      ])
    ]
  ),
  // <draw> --> <action> | <action> ; <draw> 
  Rule(
    NonTerminal.DRAW,
    [
      Alternative([Symbol.NT(NonTerminal.ACTION)]),
      Alternative([
        Symbol.NT(NonTerminal.ACTION),
        Symbol.T(Terminal.SEMICOLON),
        Symbol.NT(NonTerminal.DRAW)
      ])
    ]
  ),
  // <action> --> bar <x><y>,<y> | line <x><y>,<x><y> | fill <x><y> 
  Rule(
    NonTerminal.ACTION,
    [
      Alternative([
        Symbol.T(Terminal.BAR),
        Symbol.NT(NonTerminal.X),
        Symbol.NT(NonTerminal.Y),
        Symbol.T(Terminal.COMMA),
        Symbol.NT(NonTerminal.Y)
      ]),
      Alternative([
        Symbol.T(Terminal.LINE),
        Symbol.NT(NonTerminal.X),
        Symbol.NT(NonTerminal.Y),
        Symbol.T(Terminal.COMMA),
        Symbol.NT(NonTerminal.X),
        Symbol.NT(NonTerminal.Y)
      ]),
      Alternative([
        Symbol.T(Terminal.FILL),
        Symbol.NT(NonTerminal.X),
        Symbol.NT(NonTerminal.Y)
      ])
    ]
  ),
  // <x> --> A | B | C | D | E
  Rule(
    NonTerminal.X,
    [
      Alternative([Symbol.T(Terminal.A)]),
      Alternative([Symbol.T(Terminal.B)]),
      Alternative([Symbol.T(Terminal.C)]),
      Alternative([Symbol.T(Terminal.D)]),
      Alternative([Symbol.T(Terminal.E)])
    ]
  ),
  // <y> --> 1 | 2 | 3 | 4 | 5
  Rule(
    NonTerminal.Y,
    [
      Alternative([Symbol.T(Terminal.ONE)]),
      Alternative([Symbol.T(Terminal.TWO)]),
      Alternative([Symbol.T(Terminal.THREE)]),
      Alternative([Symbol.T(Terminal.FOUR)]),
      Alternative([Symbol.T(Terminal.FIVE)])
    ]
  )
];
