// Main program

import print;
import syntax.grammar;

import std.stdio;
import std.string;

void main()
{
	print.introduction();
	print.grammar(rules);

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
