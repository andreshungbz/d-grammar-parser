module language.token;

import language.symbols;

import std.conv : to;

/** 
 * Token holds the kind of terminal, the lexeme, and the position
 */
struct Token
{
  Terminal kind;
  string lexeme;
  size_t pos;
}
