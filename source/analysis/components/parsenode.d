/// analysis.componens.parsenode defines the ParseNode struct used to generate the parse tree
module analysis.components.parsenode;

import analysis.components.token : Token;
import bnf.symbols : Symbol, Terminal, NonTerminal;

class ParseNode
{
  Symbol symbol;
  Token token;
  ParseNode[] children;

  // constructor
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
