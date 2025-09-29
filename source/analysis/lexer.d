// analysis.lexer implements the lexical analyzer of the program through a Lexer class
module analysis.lexer;

import analysis.components.token : Token;
import bnf.symbols : Terminal;

import std.typecons : Nullable;

/// the Lexer class stores the string data and provides functions for getting the nextToken and peeking it
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

  // INTERFACING FUNCTIONS

  /// Returns all tokens in the input as an array, including errors and EOF
  Token[] tokenizeAll()
  {
    Token[] tokens;
    while (true)
    {
      auto tok = nextToken();
      if (tok.kind == Terminal.EOF)
        break; // stop before appending EOF
      tokens ~= tok;
    }
    return tokens;
  }

  /// nextToken consumes the next token in the string input
  Token nextToken()
  {
    import std.conv : to;

    skipWhitespace();

    // if at the end of the string input, return the EOF token
    if (position >= input.length)
      return Token(Terminal.EOF, "", position);

    // retrieve character
    char c = input[position];

    // if we get a valid keyword terminal, return it
    auto kwTok = lookupKeyword();
    if (!kwTok.isNull)
    {
      position += kwTok.get.lexeme.length;
      return kwTok.get;
    }

    // if we get a valid single-character terminal, return it
    auto singleTok = lookupSingleChar();
    if (!singleTok.isNull)
    {
      position++;
      return singleTok.get;
    }

    // we got neither a valid keyword or valid single-character terminal, so return an error Token
    return Token(Terminal.ERROR, c.to!string, position++);
  }

  // PRIVATE UTILTIY FUNCTIONS

  /// skipWhitespace removes Unicode-aware whitespace characters
  private void skipWhitespace()
  {
    import std.uni : isWhite;

    while (position < input.length && input[position].isWhite)
      position++;
  }

  /// lookupKeyword returns a Token or null using startsWith
  private Nullable!Token lookupKeyword()
  {
    import bnf.symbols : terminalFromString;
    import std.string : startsWith;

    import std.conv : to;

    string[] keywords = ["HI", "BYE", "bar", "line", "fill"];

    foreach (kw; keywords)
    {
      if (input[position .. $].startsWith(kw)) // examine slice from position to end
      {
        auto tok = Token(terminalFromString.get(kw, Terminal.EOF), kw, position);
        return Nullable!Token(tok);
      }
    }

    // not found
    return Nullable!Token.init;
  }

  /// lookupSingleChar returns a Token or null by examining the individual valid characters
  private Nullable!Token lookupSingleChar()
  {
    import bnf.symbols : terminalFromString;

    import std.conv : to;

    char c = input[position];

    // punctuation terminals
    if (c == ';' || c == ',')
      return Nullable!Token(Token(terminalFromString.get(c.to!string, Terminal.EOF), c.to!string, position));

    // X terminals (A-E)
    if (c >= 'A' && c <= 'E')
    {
      return Nullable!Token(Token(terminalFromString.get(c.to!string, Terminal.EOF), c.to!string, position));
    }

    // Y terminals (1-5)
    if (c >= '1' && c <= '5')
    {
      return Nullable!Token(Token(terminalFromString.get(c.to!string, Terminal.EOF), c.to!string, position));
    }

    // not found
    return Nullable!Token.init;
  }
}
