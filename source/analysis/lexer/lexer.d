module analysis.lexer.lexer;

import analysis.lexer.token : Token;
import bnf.symbols : Terminal;

class Lexer
{
  // data members
  private string input; // the string to examine for lexemes/tokens
  private size_t position; // tracks where the next input will be read from

  // constructor
  this(string source)
  {
    input = source;
    position = 0;
  }

  // MAIN INTERFACING FUNCTIONS

  /// nextToken consumes the next token in the string input
  Token nextToken()
  {
    skipWhitespace();

    // if at the end of the string input, return the EOF token
    if (position >= input.length)
      return Token(Terminal.EOF, "", position);

    char c = input[position++];
    return Token(Terminal.EOF, c ~ "", position - 1); // temporary
  }

  /// peek shows the next token without consuming it
  Token peek()
  {
    auto currentPosition = position;
    auto token = nextToken();
    position = currentPosition;
    return token;
  }

  // PRIVATE UTILTIY FUNCTIONS

  /// skipWhitespace removes Unicode-aware whitespace characters
  private void skipWhitespace()
  {
    import std.uni : isWhite;

    while (position < input.length && input[position].isWhite)
      position++;
  }
}
