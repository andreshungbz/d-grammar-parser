/// anaylsis.parser implements the syntax analyzer of the program through a Parser class
/// it performs left-to-right scan and leftmost derivation (LL) using a recursive-descent parsing algorithm
/// the lexemes in each individual nonterminal parsing function are examined by tracking the position in the Token array
/// it also handles derivation printing, error generation (only one), and parse tree generation
module analysis.parser;

import analysis.components.parsenode;
import analysis.components.token;
import analysis.lexer;
import bnf.symbols : Symbol, NonTerminal, Terminal;

class Parser
{
  // data members

  private Token[] tokens; // obtained from the lexical analyzer
  private size_t pos = 0;

  private ParseNode root; // parse tree to be built

  private string[] derivations; // derivations are first collected during parsing, then printed
  private string currentSententialForm = "HI <draw> BYE"; // nonterminal parsing functions manipulate this
  private bool firstDerivationPrinted = false; // just for making non-first derivations exlcude printing <graph>

  private string error; // single error string

  // constructor 
  this(string source)
  {
    import std.string : strip;

    // do lexical analysis and set the Token array
    auto lexer = new Lexer(source.strip());
    tokens = lexer.tokenizeAll();
  }

  // INTERFACING FUNCTIONS

  /// parse() begins the syntax analysis process
  void parse()
  {
    import std.stdio : writeln;

    if (tokens.length == 0) // edge case: no input
    {
      writeln("[Error] Enter an input!");
      return;
    }

    // begin recursive-descent parsing algorithm
    root = parseGraph(0, tokens.length - 1);

    // print derivations
    // in the case of errors, the last derivation printed is the one where the error occurred
    writeln("\n[Derivations]");
    printDerivations();
    writeln();

    // report error if it exists, otherwise print the parse tree
    if (error.length > 0)
    {
      writeln(error);
    }
    else
    {
      writeln("[Parse Tree]");
      printParseTree(root);
      writeln();
    }

  }

  // PARSING FUNCTIONS FOR RECURSIVE-DESCENT PARSING

  /// parseGraph expands the nonterminal <graph>
  /// <graph> --> HI <draw> BYE
  private ParseNode parseGraph(size_t first, size_t last)
  {
    // PARSE TREE NODE - create <graph>
    auto node = new ParseNode(Symbol.NT(NonTerminal.GRAPH));

    // DERIVATION RECORDING - first derivation is always recorded
    derivations ~= "HI <draw> BYE";

    // RULE DETERMINATION - HI and BYE
    if (tokens.length == 0 || tokens[0].kind != Terminal.HI)
    {
      auto got = tokens.length == 0 ? "EOF" : tokens[0].lexeme;
      error = formatError("<graph>", "HI", got);
      return node;
    }
    if (tokens.length == 0 || tokens[$ - 1].kind != Terminal.BYE)
    {
      auto got = tokens.length == 0 ? "EOF" : tokens[$ - 1].lexeme;
      error = formatError("<graph>", "BYE", got);

      return node;
    }

    // PARSE TREE NODE - add HI
    auto hiNode = new ParseNode(Symbol.T(tokens[first].kind), tokens[first]);
    node.addChild(hiNode);

    // RECURSIVE PARSE -  <draw>
    auto drawNode = parseDraw(first + 1, last - 1);
    node.addChild(drawNode);
    if (error.length > 0)
      return node;

    // PARSE TREE NODE - add BYE
    auto byeNode = new ParseNode(Symbol.T(tokens[last].kind), tokens[last]);
    node.addChild(byeNode);

    return node;
  }

  /// parseDraw examples the nonterminal <draw>
  /// <draw> --> <action> | <action> ; <draw>
  private ParseNode parseDraw(size_t first, size_t last)
  {
    // PARSE TREE NODE - create <draw>
    auto node = new ParseNode(Symbol.NT(NonTerminal.DRAW));

    // RULE DETERMINATION - checking ;
    size_t semicolonPos = first;
    bool hasSemicolon = false;
    for (; semicolonPos < last; semicolonPos++)
    {
      if (tokens[semicolonPos].kind == Terminal.SEMICOLON)
      {
        hasSemicolon = true;
        break;
      }
    }

    if (hasSemicolon) // <action> ; <draw>
    {
      // DERIVATION RECORDING - expanding <draw> --> <action> ; <draw>
      currentSententialForm = replaceFirst(currentSententialForm, "<draw>", "<action> ; <draw>");
      derivations ~= currentSententialForm;

      // RECURSIVE PARSE - <action>
      auto actionNode = parseAction(first, semicolonPos - 1);
      node.addChild(actionNode);
      if (error.length > 0)
        return node;

      // PARSE TREE NODE - add ;
      auto semicolonNode = new ParseNode(Symbol.T(Terminal.SEMICOLON), tokens[semicolonPos]);
      node.addChild(semicolonNode);

      // RECURSIVE PARSE - <draw>
      auto nextDrawNode = parseDraw(semicolonPos + 1, last);
      node.addChild(nextDrawNode);
      if (error.length > 0)
        return node;
    }
    else // < action >
    {
      // DERIVATION RECORDING - expanding <draw> --> <action>
      currentSententialForm = replaceFirst(currentSententialForm, "<draw>", "<action>");
      derivations ~= currentSententialForm;

      // RECURSIVE PARSE -  <action>
      auto actionNode = parseAction(first, last);
      node.addChild(actionNode);
      if (error.length > 0)
        return node;
    }

    return node;
  }

  /// parseAction expands the nonterminal <action>
  /// <action> --> bar <x><y>,<y> | line <x><y>,<x><y> | fill <x><y>
  private ParseNode parseAction(size_t first, size_t last)
  {
    // PARSE TREE NODE - create <action>
    auto node = new ParseNode(Symbol.NT(NonTerminal.ACTION));

    if (first > last) // edge case: empty
    {
      error = formatError("<action>", "token range", "{empty}");
      return node;
    }

    auto tok = tokens[first];
    string actionLexeme;

    // RULE DETERMINATION - is one of {bar, line, fill}
    if (tok.kind == Terminal.BAR || tok.kind == Terminal.LINE || tok.kind == Terminal.FILL)
    {
      actionLexeme = tok.lexeme;

      // PARSE TREE NODE - add determined action
      auto keywordNode = new ParseNode(Symbol.T(tok.kind), tok);
      node.addChild(keywordNode);

      // RULE DETERMINATION - checking , for bar and line
      if (actionLexeme == "bar" || actionLexeme == "line")
      {
        bool commaFound = false;
        for (size_t i = first + 1; i <= last; i++)
        {
          if (tokens[i].kind == Terminal.COMMA)
          {
            commaFound = true;
            break;
          }
        }

        if (!commaFound)
        {
          error = formatError("<action>", "','", tokens[last].lexeme);
          return node;
        }
      }
    }
    else
    {
      error = formatError("<action>", "bar, line, fill", tok.lexeme);
      return node;
    }

    // DERIVATION RECORDING - depends on which action determined previously
    string derivationForm;
    if (actionLexeme == "bar") // bar
      derivationForm = "bar <x><y>,<y>";
    else if (actionLexeme == "line") // line
      derivationForm = "line <x><y>,<x><y>";
    else // fill
      derivationForm = "fill <x><y>";
    currentSententialForm = replaceFirst(currentSententialForm, "<action>", derivationForm);
    derivations ~= currentSententialForm;

    size_t posAction = first + 1; // advance past the bar/line/fill token

    // RECURSIVE PARSE - <x><y> (common to all actions)
    auto xNode1 = parseX(posAction);
    node.addChild(xNode1);
    if (error.length > 0)
      return node;
    posAction++;
    auto yNode1 = parseY(posAction);
    node.addChild(yNode1);
    if (error.length > 0)
      return node;
    posAction++;

    if (actionLexeme == "fill") // FILL CONTINUED - finished
    {
      return node;
    }
    else if (actionLexeme == "bar") // BAR CONTINEUD - parsing ,<y>
    {
      // RULE DETERMINATION - checking for ,
      if (posAction > last || tokens[posAction].kind != Terminal.COMMA)
      {
        auto got = posAction >= tokens.length ? "EOF" : tokens[posAction].lexeme;
        error = formatError("<action>", "','", got);
        return node;
      }

      // PARSE TREE NODE - add ,
      auto commaNode = new ParseNode(Symbol.T(Terminal.COMMA), tokens[posAction]);
      node.addChild(commaNode);
      posAction++; // advance past , token

      // RECURSIVE PARSE - <y>
      auto yNode2 = parseY(posAction);
      node.addChild(yNode2);
      if (error.length > 0)
        return node;
      posAction++;
    }
    else if (actionLexeme == "line") // LINE CONTINUED - parsing ,<x><y>
    {
      // RULE DETERMINATION - checking for ,
      if (posAction > last || tokens[posAction].kind != Terminal.COMMA)
      {
        auto got = posAction >= tokens.length ? "EOF" : tokens[posAction].lexeme;
        error = formatError("<action>", "','", got);
        return node;
      }

      // PARSE TREE NODE - add ,
      auto commaNode = new ParseNode(Symbol.T(Terminal.COMMA), tokens[posAction]);
      node.addChild(commaNode);
      posAction++; // advance past , token

      // RECURSIVE PARSE - <x>
      auto xNode2 = parseX(posAction);
      node.addChild(xNode2);
      if (error.length > 0)
        return node;
      posAction++;

      // RECURSIVE PARSE - <y>
      auto yNode2 = parseY(posAction);
      node.addChild(yNode2);
      if (error.length > 0)
        return node;
      posAction++;
    }

    return node;
  }

  /// parseX expands the nonterminal <x>
  /// <x> --> A | B | C | D | E
  private ParseNode parseX(size_t posX)
  {
    // PARSE TREE NODE - create <x>
    auto node = new ParseNode(Symbol.NT(NonTerminal.X), tokens[posX]);

    if (posX >= tokens.length)
    {
      error = formatError("<x>", "A..E", "EOF");
      return node;
    }

    // RULE DETERMINATION - check A..E
    auto tok = tokens[posX];
    if (tok.kind != Terminal.A && tok.kind != Terminal.B &&
      tok.kind != Terminal.C && tok.kind != Terminal.D &&
      tok.kind != Terminal.E)
    {
      error = formatError("<x>", "A..E", tok.lexeme);
      return node;
    }

    // DERIVATION RECORDING - <x>
    currentSententialForm = replaceFirst(currentSententialForm, "<x>", tok.lexeme);
    derivations ~= currentSententialForm;

    return node;
  }

  /// parseY expands the nonterminal <y>
  /// <y> → 1 | 2 | 3 | 4 | 5
  private ParseNode parseY(size_t posY)
  {
    // PARSE TREE NODE - create <y>
    auto node = new ParseNode(Symbol.NT(NonTerminal.Y), tokens[posY]);

    if (posY >= tokens.length) // edge case: end of input
    {
      error = formatError("<y>", "1..5", "EOF");
      return node;
    }

    // RULE DETERMINATION - check 1..5
    auto tok = tokens[posY];
    if (tok.kind != Terminal.ONE && tok.kind != Terminal.TWO &&
      tok.kind != Terminal.THREE && tok.kind != Terminal.FOUR &&
      tok.kind != Terminal.FIVE)
    {
      error = formatError("<y>", "1..5", tok.lexeme);
      return node;
    }

    // DERIVATION RECORDING - <x>
    currentSententialForm = replaceFirst(currentSententialForm, "<y>", tok.lexeme);
    derivations ~= currentSententialForm;

    return node;
  }

  // PRIVATE UTILITY FUNCTIONS

  /// printDerivations loops through derivations data member, printing each numbererd sentential form
  private void printDerivations()
  {
    import std.format : format;
    import std.stdio : writeln;

    size_t derivationCounter = 1;
    foreach (d; derivations)
    {
      auto numStr = format("%02d", derivationCounter++); // for single digits, append 0

      if (!firstDerivationPrinted) // print <graph> only on the first derivation
      {
        writeln(format("%-4s %-10s %-5s %s", numStr, "<graph>", "-->", d));
        firstDerivationPrinted = true;
      }
      else
      {
        writeln(format("%-4s %-10s %-5s %s", numStr, "", "-->", d));
      }
    }
  }

  /// replaceFirst helps to expand a nonterminal in the currentSententialForm once a rule is properly detertmined
  private string replaceFirst(string s, string search, string replacement)
  {
    import std.string : indexOf;

    auto pos = s.indexOf(search);
    if (pos == -1)
      return s; // not found, return original
    return s[0 .. pos] ~ replacement ~ s[pos + search.length .. $];
  }

  /// formatError keeps the error reporting consistent, showing which nonterminal failed, the expected value and the actual value
  private string formatError(string nonterminal, string expected, string got)
  {
    import std.format : format; // use format instead of write so that a string is returned instead of writing directly to stdout

    return format("[Error] Derivation of %s failed. Expected %s. Got '%s'",
      nonterminal, expected, got);
  }

  /// printParseTree recursively constructs a horizontal parse tree for the successful derivation of an input
  /// pre-order depth-first traversal is used
  private void printParseTree(ParseNode node, string prefix = "", bool last = true, bool isRoot = true)
  {
    import std.algorithm.searching : canFind;
    import std.stdio : writeln;

    // don't repeat for keyword and punctuation terminals
    string lexemeSuffix = "";
    if (node.children.length == 0 && node.token.lexeme.length > 0)
    {
      immutable skipLexeme = [
        Terminal.HI,
        Terminal.BYE,
        Terminal.BAR,
        Terminal.FILL,
        Terminal.LINE,
        Terminal.COMMA,
        Terminal.SEMICOLON
      ];

      if (!canFind(skipLexeme, node.token.kind))
        lexemeSuffix = " (" ~ node.token.lexeme ~ ")";
    }

    if (isRoot) // only print └── / ├── if not root
      writeln(node.symbol.value);
    else
      writeln(prefix, last ? "└── " : "├── ", node.symbol.value, lexemeSuffix);

    // construct next prefix then travese each of the node's children recursively
    string newPrefix = prefix ~ (last ? "    " : "│   ");
    foreach (i, child; node.children)
    {
      printParseTree(child, newPrefix, i == node.children.length - 1, false);
    }
  }
}
