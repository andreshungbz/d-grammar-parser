// The print module contains printing functions for introdction, grammar, etc.

module print;

import std.format;
import std.stdio;
import syntax.grammar;

/**
 * Displays information about the program and project.
 */
void introduction()
{
  import std.typecons : tuple;

  auto programIntroEntries = [
    tuple("[d-grammar-parser]", "Simple lexical/syntax analyzer written in D"),
    tuple("[GitHub]", "https://github.com/andreshungbz/d-grammar-parser")
  ];

  foreach (entry; programIntroEntries)
  {
    writeln(format("%-20s %-50s", entry[0], entry[1]));
  }

  writeln();
}

/**
* Displays the BNF grammar rules according to the program specifications.
* Params:
*   rules = an array of Rule structs
*/
void grammar(Rule[] rules)
{
  import std.algorithm : joiner, map;
  import std.conv : to;

  // print headers
  writefln("[BNF/Context-free Grammar]");
  writeln(format("%-15s %-5s %-50s", "[Non-Terminal]", "-->", "[Derivation]"));

  // print each rule
  foreach (rule; rules)
  {
    // create a string of alternatives separated by |
    string alternatives = rule.alternatives
      .map!(p => p.toString)
      .joiner(" | ")
      .to!string;

    writeln(format("%-15s %-5s %-50s", rule.nonTerminal, "-->", alternatives));
  }

  writeln();
}
