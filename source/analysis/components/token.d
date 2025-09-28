/// analysis.components.token defines the Token struct that is returned by the lexer
module analysis.components.token;

import bnf.symbols : Terminal;

/// Token holds the terminal kind, the lexeme string, and its start position
struct Token
{
  Terminal kind;
  string lexeme;
  size_t startPosition;
}
