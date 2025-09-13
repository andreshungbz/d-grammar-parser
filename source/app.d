// Main program

import std.stdio;
import std.string;
import grammar;
import print;

void main()
{
	print.introduction();
	print.grammar(grammar.rules);

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
