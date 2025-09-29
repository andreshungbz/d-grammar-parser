module analysis.parser;

import analysis.lexer;
import analysis.components.parsenode;
import analysis.components.token;
import bnf.symbols : Symbol, NonTerminal, Terminal;

class Parser
{
  // data members
  private Token[] tokens; // all lexemes
  private size_t pos = 0; // token array index
  private ParseNode root; // for printing the parse tree
  private string error; // get first error

  private string currentSententialForm = "HI <draw> BYE";
  private string[] derivations;

  private bool firstDerivationPrinted = false;

  // constructor
  this(string source)
  {
    import std.string : strip;

    auto trimmedSource = source.strip();
    auto lexer = new Lexer(trimmedSource);
    tokens = lexer.tokenizeAll();
  }

  // Main entry point
  void parse()
  {
    import std.stdio : writeln;

    // check empty input
    if (tokens.length == 0)
    {
      writeln("[Error] No input tokens to parse.");
      return;
    }
    else
    {
      // Start parsing from <graph>
      root = parseGraph(0, tokens.length - 1);

      // Print all derivations determined
      writeln("\n[Derivations]");
      printDerivations();
      writeln();

      // Report success or error
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
  }

  // PARSING FUNCTIONS FOR RECURSIVE-DESCENT PARSING

  /// <graph> → HI <draw> BYE
  private ParseNode parseGraph(size_t first, size_t last)
  {
    import std.format : format;

    auto node = new ParseNode(Symbol.NT(NonTerminal.GRAPH));

    // record derivation
    derivations ~= "HI <draw> BYE";

    // CHECK HI
    if (tokens.length == 0 || tokens[0].kind != Terminal.HI)
    {
      auto got = tokens.length == 0 ? "EOF" : tokens[0].lexeme;
      error = formatError("<graph>", "HI", got);
      return node;
    }

    // CHECK BYE
    if (tokens.length == 0 || tokens[$ - 1].kind != Terminal.BYE)
    {
      auto got = tokens.length == 0 ? "EOF" : tokens[$ - 1].lexeme;
      error = formatError("<graph>", "BYE", got);

      return node;
    }

    // Add HI terminal node
    auto hiNode = new ParseNode(Symbol.T(tokens[first].kind), tokens[first]);
    node.addChild(hiNode);

    // PARSE <draw>
    auto drawNode = parseDraw(first + 1, last - 1);
    node.addChild(drawNode);
    if (error.length > 0)
      return node;

    // Add BYE terminal node
    auto byeNode = new ParseNode(Symbol.T(tokens[last].kind), tokens[last]);
    node.addChild(byeNode);

    return node;
  }

  /// <draw> --> <action> | <action> ; <draw>
  private ParseNode parseDraw(size_t first, size_t last)
  {
    import std.string : indexOf;

    auto node = new ParseNode(Symbol.NT(NonTerminal.DRAW));

    // CHECK ;
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

    if (hasSemicolon)
    {
      // record derivation <action> ; <draw>
      currentSententialForm = replaceFirst(currentSententialForm, "<draw>", "<action> ; <draw>");
      derivations ~= currentSententialForm;

      // PARSE <action>
      auto actionNode = parseAction(first, semicolonPos - 1);
      node.addChild(actionNode);
      if (error.length > 0)
        return node;

      // Add ; terminal node
      auto semicolonNode = new ParseNode(Symbol.T(Terminal.SEMICOLON), tokens[semicolonPos]);
      node.addChild(semicolonNode);

      // PARSE <draw>
      auto nextDrawNode = parseDraw(semicolonPos + 1, last);
      node.addChild(nextDrawNode);
      if (error.length > 0)
        return node;
    }
    else
    {
      // record derivation <action>
      currentSententialForm = replaceFirst(currentSententialForm, "<draw>", "<action>");
      derivations ~= currentSententialForm;

      // PARSE <action>
      auto actionNode = parseAction(first, last);
      node.addChild(actionNode);
      if (error.length > 0)
        return node;
    }

    return node;
  }

  /// <action> → bar <x><y>,<y> | line <x><y>,<x><y> | fill <x><y>
  private ParseNode parseAction(size_t first, size_t last)
  {
    auto node = new ParseNode(Symbol.NT(NonTerminal.ACTION));

    // check emptiness
    if (first > last)
    {
      error = formatError("<action>", "token range", "empty");
      return node;
    }

    // CHECK {bar line fill}
    auto tok = tokens[first];
    string actionLexeme;
    if (tok.kind == Terminal.BAR || tok.kind == Terminal.LINE || tok.kind == Terminal.FILL)
    {
      actionLexeme = tok.lexeme;

      // Add keyword terminal node for parse tree
      auto keywordNode = new ParseNode(Symbol.T(tok.kind), tok);
      node.addChild(keywordNode);

      // rudimentary comma check only for bar and line
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

    // record correct derivation
    string derivationForm;
    if (actionLexeme == "bar")
      derivationForm = "bar <x><y>,<y>";
    else if (actionLexeme == "line")
      derivationForm = "line <x><y>,<x><y>";
    else // fill
      derivationForm = "fill <x><y>";

    currentSententialForm = replaceFirst(currentSententialForm, "<action>", derivationForm);
    derivations ~= currentSententialForm;

    // advance first token
    size_t posAction = first + 1;

    // PARSE <x><y> (common to all)
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

    if (actionLexeme == "fill") // fill <x><y> already parsed at this point
    {
      return node;
    }
    else if (actionLexeme == "bar") // parsing ,<y> of bar
    {
      // PARSE ,
      if (posAction > last || tokens[posAction].kind != Terminal.COMMA)
      {
        auto got = posAction >= tokens.length ? "EOF" : tokens[posAction].lexeme;
        error = formatError("<action>", "','", got);
        return node;
      }

      // add comma node to the parse tree
      auto commaNode = new ParseNode(Symbol.T(Terminal.COMMA), tokens[posAction]);
      node.addChild(commaNode);

      posAction++; // consume comma

      // PARSE <y>
      auto yNode2 = parseY(posAction);
      node.addChild(yNode2);
      if (error.length > 0)
        return node;
      posAction++;
    }
    else if (actionLexeme == "line") // parsing ,<x><y> of line
    {
      // PARSE ,
      if (posAction > last || tokens[posAction].kind != Terminal.COMMA)
      {
        auto got = posAction >= tokens.length ? "EOF" : tokens[posAction].lexeme;
        error = formatError("<action>", "','", got);
        return node;
      }

      // add comma node to the parse tree
      auto commaNode = new ParseNode(Symbol.T(Terminal.COMMA), tokens[posAction]);
      node.addChild(commaNode);

      posAction++; // consume comma

      // PARSE <x>
      auto xNode2 = parseX(posAction);
      node.addChild(xNode2);
      if (error.length > 0)
        return node;
      posAction++;

      // PARSE <y>
      auto yNode2 = parseY(posAction);
      node.addChild(yNode2);
      if (error.length > 0)
        return node;
      posAction++;
    }

    return node;
  }

  /// <x> → A | B | C | D | E
  private ParseNode parseX(size_t posX)
  {
    // Use the token in the parse tree
    auto node = new ParseNode(Symbol.NT(NonTerminal.X), tokens[posX]);

    if (posX >= tokens.length)
    {
      error = formatError("<x>", "A..E", "EOF");

      return node;
    }

    auto tok = tokens[posX];
    if (tok.kind != Terminal.A && tok.kind != Terminal.B &&
      tok.kind != Terminal.C && tok.kind != Terminal.D &&
      tok.kind != Terminal.E)
    {
      error = formatError("<x>", "A..E", tok.lexeme);
      return node;
    }

    // record derivation for <x>
    currentSententialForm = replaceFirst(currentSententialForm, "<x>", tok.lexeme);
    derivations ~= currentSententialForm;

    return node;
  }

  /// <y> → 1 | 2 | 3 | 4 | 5
  private ParseNode parseY(size_t posY)
  {
    auto node = new ParseNode(Symbol.NT(NonTerminal.Y), tokens[posY]);

    if (posY >= tokens.length)
    {
      error = formatError("<y>", "1..5", "EOF");
      return node;
    }

    auto tok = tokens[posY];
    if (tok.kind != Terminal.ONE && tok.kind != Terminal.TWO &&
      tok.kind != Terminal.THREE && tok.kind != Terminal.FOUR &&
      tok.kind != Terminal.FIVE)
    {
      error = formatError("<y>", "1..5", tok.lexeme);
      return node;
    }

    // record derivation for <y>
    currentSententialForm = replaceFirst(currentSententialForm, "<y>", tok.lexeme);
    derivations ~= currentSententialForm;

    return node;
  }

  // PRIVATE UTILITY FUNCTIONS

  private void printDerivations()
  {
    import std.stdio : writeln;
    import std.format : format;

    size_t derivationCounter = 1;
    foreach (d; derivations)
    {
      auto numStr = format("%02d", derivationCounter);
      derivationCounter++;

      if (!firstDerivationPrinted)
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

  private string replaceFirst(string s, string search, string replacement)
  {
    import std.string : indexOf;

    auto pos = s.indexOf(search);
    if (pos == -1)
      return s; // not found, return original
    return s[0 .. pos] ~ replacement ~ s[pos + search.length .. $];
  }

  private string formatError(string nonterminal, string expected, string got)
  {
    import std.format : format;

    return format("[Error] Derivation of %s failed. Expected %s. Got '%s'",
      nonterminal, expected, got);
  }

  private void printParseTree(ParseNode node, string prefix = "", bool last = true, bool isRoot = true)
  {
    import std.stdio : writeln;
    import std.algorithm.searching : canFind;

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

    // Only print └── / ├── if not root
    if (isRoot)
      writeln(node.symbol.value);
    else
      writeln(prefix, last ? "└── " : "├── ", node.symbol.value, lexemeSuffix);

    string newPrefix = prefix ~ (last ? "    " : "│   ");
    foreach (i, child; node.children)
    {
      printParseTree(child, newPrefix, i == node.children.length - 1, false);
    }
  }
}
