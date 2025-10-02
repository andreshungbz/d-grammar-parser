// utility.prind contains printing functions for introdction and grammar
module utility.print;

import std.format;
import std.stdio;

/// displayProgramInformation shows information about the program and project.
void displayProgramInformation()
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
}

/// displayGrammar shows the BNF grammar rules according to the program specifications.
void displayGrammar()
{
  import bnf.grammar : rules;

  writeln("\n[BNF/Context-free Grammar]");
  writeln(format("%-15s %-5s %-50s", "[Non-Terminal]", "-->", "[Derivation]"));

  foreach (rule; rules)
  {
    writeln(format("%-15s %-5s %-50s", cast(string) rule.nonTerminal, "-->", rule.alternativesToString()));
  }

  writeln();
}
