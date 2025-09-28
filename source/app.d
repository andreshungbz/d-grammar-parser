// Main program

import utility.print : displayProgramInformation, displayGrammar;
import analysis.lexer : Lexer;
import analysis.components.token : Token;
import bnf.symbols : Terminal;

import std.stdio;
import std.string;
import std.conv : to;

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

		// create lexer
		auto lexer = new Lexer(input);

		// iterate tokens until EOF
		Token tok;
		do
		{
			tok = lexer.nextToken();
			writeln("Token(kind: ", tok.kind,
				", lexeme: \"", tok.lexeme, "\"",
				", position: ", tok.startPosition.to!string, ")");
		}
		while (tok.kind != Terminal.EOF);
	}
}
