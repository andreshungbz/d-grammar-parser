import std.format;
import std.stdio;

string programPrefix = "[d-grammar-parser]";

/// printIntroduction displays informatino about the program and project.
void printIntroduction()
{
	string[][] programIntroEntries = [
		["[d-grammar-parser]", "Simple lexical/syntax analyzer written in D"],
		["[CMPS3111-P1-25S1]", "Programming Languages - Program 1"],
		[
			"[Group Members]",
			"Andres Hung, Amir Gonzalez, Renee Banner, Joseph Koop, Adolfo Dueñas"
		],
		["[Due Date]", "October 2, 2025"]
	];

	foreach (string[] entry; programIntroEntries)
	{
		writeln(format("%-20s %-50s", entry[0], entry[1]));
	}

	writeln();
}

/// printGrammar displays the BNF grammar rules according to the program specifications.
void printGrammar()
{
	string[] headers = ["[Non-Terminal]", "-->", "[Derivation]"];
	string[][] rules = [
		["<graph>", "-->", "HI <draw> BYE"],
		["<draw>", "-->", "<action> | <action> ; <draw>"],
		["<action>", "-->", "bar <x><y>,<y> | line <x><y>,<x><y> | fill <x><y>"],
		["<x>", "-->", "A | B | C | D | E"],
		["<y>", "-->", "1 | 2 | 3 | 4 | 5"]
	];

	writefln("[BNF/Context-free Grammar]"); // print headers
	writeln(format("%-15s %-5s %-50s", headers[0], headers[1], headers[2]));

	// print rules
	foreach (string[] rule; rules)
	{
		writeln(format("%-15s %-5s %-50s", rule[0], rule[1], rule[2]));
	}

	writeln();
}

void main()
{
	printIntroduction();
	printGrammar();
}
