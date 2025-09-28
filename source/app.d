// Main program

import utility.print : displayProgramInformation, displayGrammar;

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
	}
}
