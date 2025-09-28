module analysis.lexer.token;

import bnf.symbols : Terminal;

/// Token holds the kind of terminal, the lexeme, and the position
struct Token
{
  Terminal kind;
  string lexeme;
  size_t pos;
}
