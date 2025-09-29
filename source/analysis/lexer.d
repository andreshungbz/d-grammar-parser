/// analysis.lexer implements the lexical analyzer of the program through a Lexer class
/// it examines lexical units and provides an array of Tokens to the syntax analyzer
/// invalid token errors are later handled by the syntax analyzer
module analysis.lexer;

import analysis.components.token : Token;
import bnf.symbols : Terminal;

import std.typecons : Nullable;

/// the Lexer class stores the string data and provides functions for getting the nextToken and peeking it
class Lexer
{
  // data members
  private string input; // input string
  private size_t position = 0; // position of input string

  // constructor
  this(string source)
  {
    input = source;
  }

  // INTERFACING FUNCTIONS

  /// tokenizeAll returns all tokens in the input as an array, including Terminal.ERROR, but excluding Terminal.EOF
  Token[] tokenizeAll()
  {
    Token[] tokens;
    while (true)
    {
      auto tok = nextToken();
      if (tok.kind == Terminal.EOF)
        break;
      tokens ~= tok;
    }
    return tokens;
  }

  // PRIVATE UTILTIY FUNCTIONS

  /// nextToken consumes the next token in the string input
  private Token nextToken()
  {
    import std.conv : to;

    skipWhitespace(); // clear whitespace

    if (position >= input.length) // end of input string
      return Token(Terminal.EOF, "", position);

    char c = input[position]; // get character to check

    // return keyword terminal if valid
    auto kwTok = lookupKeyword();
    if (!kwTok.isNull)
    {
      position += kwTok.get.lexeme.length;
      return kwTok.get;
    }

    // return single-character terminal if valid
    auto singleTok = lookupSingleChar();
    if (!singleTok.isNull)
    {
      position++;
      return singleTok.get;
    }

    // otherwise return an invalid lexeme
    return Token(Terminal.ERROR, c.to!string, position++);
  }

  /// skipWhitespace removes whitespace characters such as spaces
  private void skipWhitespace()
  {
    import std.uni : isWhite;

    while (position < input.length && input[position].isWhite)
      position++;
  }

  /// lookupKeyword returns a keyword Token or a null value (std.typecons : Nullable)
  private Nullable!Token lookupKeyword()
  {
    import bnf.symbols : terminalFromString;

    import std.conv : to;
    import std.string : startsWith;

    string[] keywords = ["HI", "BYE", "bar", "line", "fill"];
    foreach (kw; keywords)
    {
      // return appropriate Token if valid
      if (input[position .. $].startsWith(kw)) // examine slice from position to end
      {
        auto tok = Token(terminalFromString.get(kw, Terminal.EOF), kw, position);
        return Nullable!Token(tok);
      }
    }

    // otherwise return a null value
    return Nullable!Token.init;
  }

  /// lookupSingleChar returns a single-cahracter Token or a null value (std.typecons : Nullable)
  private Nullable!Token lookupSingleChar()
  {
    import bnf.symbols : terminalFromString;

    import std.conv : to;

    char c = input[position]; // get character to check

    // return appropriate Token if valid
    if (c == ';' || c == ',') // punctuation terminals
      return Nullable!Token(Token(terminalFromString.get(c.to!string, Terminal.EOF), c.to!string, position));
    if (c >= 'A' && c <= 'E') // X terminals (A-E)
      return Nullable!Token(Token(terminalFromString.get(c.to!string, Terminal.EOF), c.to!string, position));
    if (c >= '1' && c <= '5') // Y terminals (1-5)
      return Nullable!Token(Token(terminalFromString.get(c.to!string, Terminal.EOF), c.to!string, position));

    // otherwise return a null value
    return Nullable!Token.init;
  }
}
