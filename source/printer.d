// The printer module contains printing functions for introdction, grammar, etc.

module printer;

import std.format;
import std.stdio;

// grammar
string[string] rules = [
  "<graph>": "HI <draw> BYE",
  "<draw>": "<action> | <action> ; <draw>",
  "<action>": "bar <x><y>,<y> | line <x><y>,<x><y> | fill <x><y>",
  "<x>": "A | B | C | D | E",
  "<y>": "1 | 2 | 3 | 4 | 5"
];

/// printIntroduction displays informatino about the program and project.
void printIntroduction()
{
  string[string] programIntroEntries = [
    "[d-grammar-parser]": "Simple lexical/syntax analyzer written in D",
    "[GitHub]": "https://github.com/andreshungbz/d-grammar-parser"
  ];

  foreach (entry, description; programIntroEntries)
  {
    writeln(format("%-20s %-50s", entry, description));
  }

  writeln();
}

/// printGrammar displays the BNF grammar rules according to the program specifications.
void printGrammar()
{
  // print headers
  writefln("[BNF/Context-free Grammar]");
  writeln(format("%-15s %-5s %-50s", "[Non-Terminal]", "-->", "[Derivation]"));

  // print rules
  foreach (nonTerminal, derivation; rules)
  {
    writeln(format("%-15s %-5s %-50s", nonTerminal, "-->", derivation));
  }

  writeln();
}
