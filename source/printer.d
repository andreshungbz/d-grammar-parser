// The printer module contains printing functions for introdction, grammar, etc.

module printer;

import std.format;
import std.stdio;

/**
printIntroduction displays information about the program and project.
*/
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

/**
printGrammar displays the BNF grammar rules according to the program specifications.
Params:
  rules = an associative array of string non-terminals to string derivations.
*/
void printGrammar(string[string] rules)
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
