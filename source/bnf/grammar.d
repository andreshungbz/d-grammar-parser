/// bnf.grammar defines the grammar rules according to the program specifications
module bnf.grammar;

import bnf.symbols : Terminal, NonTerminal, Symbol;
import bnf.rule : Rule, Alternative;

Rule[] rules = [
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
