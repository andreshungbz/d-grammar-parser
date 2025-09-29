module analysis.components.parsenode;

import analysis.components.token : Token;
import bnf.symbols : Symbol, Terminal, NonTerminal;

class ParseNode
{
  Symbol symbol;
  Token token;
  ParseNode[] children;

  this(Symbol symbol, Token token = Token.init)
  {
    this.symbol = symbol;
    this.token = token;
  }

  void addChild(ParseNode child)
  {
    children ~= child;
  }
}
