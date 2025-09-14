// Main program

import syntax.grammar;
import utility.print;

import std.stdio;
import std.string;

void main()
{
	utility.print.introduction();
	utility.print.grammar(rules);

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
