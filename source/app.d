// Main program

import std.stdio;
import std.string;
import grammar;
import printer;

void main()
{
	printIntroduction();
	printGrammar(grammar.rules);

	// continually prompt for input
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
