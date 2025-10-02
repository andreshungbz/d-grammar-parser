// app.d contains the main driver program that continuously prompts
// the user for input strings and attempts to show derivations and the
// parse tree according to the program BNF grammar.

import analysis.parser : Parser;
import utility.print : displayProgramInformation, displayGrammar;

import std.stdio;
import std.string;

void main()
{
	displayProgramInformation();

	// main program loop
	while (true)
	{
		displayGrammar();

		write("Enter input ('END' to exit): ");
		string input = strip(readln());

		// exit program on "END"
		if (input == "END")
			break;

		// send the input to the syntax analyzer to attempt parsing
		auto parser = new Parser(input);
		parser.parse();

		// prompt for key before asking for another input
		write("Press [Enter] to continue...");
		readln();
	}
}
