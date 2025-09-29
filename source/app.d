// Main program

import utility.print : displayProgramInformation, displayGrammar;
import analysis.parser : Parser;

import std.stdio;
import std.string;

void main()
{
	displayProgramInformation();
	displayGrammar();

	// program loop
	while (true)
	{
		write("Enter input ('END' to exit): ");
		string input = strip(readln());

		// break condition on "END"
		if (input == "END")
		{
			break;
		}

		auto parser = new Parser(input);
		parser.parse();

		pressAnyKey();
	}
}

void pressAnyKey()
{
	import std.stdio;

	write("Press Enter to continue...");
	readln(); // Waits for the user to press Enter
}
