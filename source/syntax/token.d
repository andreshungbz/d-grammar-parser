module syntax.token;

import syntax.symbols;

import std.conv : to;

/// Represents a single token produced by the lexer.
struct Token
{
  Terminal kind;
  string lexeme;
  size_t pos;
}
