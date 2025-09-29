module analysis.components.parsetree;

import std.algorithm.searching : canFind;
import std.stdio : writeln, write;
import std.algorithm : map, reduce, max, min;
import std.array : array, appender;
import std.string;
import std.conv : to;

// Re-import necessary components from other modules
import analysis.components.parsenode : ParseNode;
import bnf.symbols : Symbol, Terminal, NonTerminal;

// --- Constants for Tree Layout ---
private enum int SIBLING_SPACING = 3;
// Node(y), LexemeStem/Stem(y+1), HLine(y+2), Lexeme(y+3), ChildStem(y+4)
private enum int LEVEL_HEIGHT = 5;

// --- Node Metadata Cache ---
struct LayoutInfo
{
  int width;
  int depth;
  string label; // Node label (e.g., "<x>", "bar")
  int labelLength;
  string lexemeValue; // Lexeme value (e.g., "(D)", null)
  int lexemeLength;
  int contentWidth; // max(labelLength, lexemeLength)
}

private LayoutInfo[ParseNode] layoutCache;

// --- Helper Functions ---

/// Gets the primary node label (e.g., "<x>", "bar").
private string getLabel(ParseNode node)
{
  return node.symbol.value;
}

/// Gets the lexeme value in parentheses (e.g., "(D)", or null).
private string getLexemeValue(ParseNode node)
{
  if (node.children.length == 0 && node.token.lexeme.length > 0)
  {
    immutable skipLexeme = [
      Terminal.HI, Terminal.BYE, Terminal.BAR, Terminal.FILL,
      Terminal.LINE, Terminal.COMMA, Terminal.SEMICOLON
    ];

    if (!canFind(skipLexeme, node.token.kind))
      return "(" ~ node.token.lexeme ~ ")";
  }
  return null;
}

// --- Traversal 1 & 2: Measure Width and Depth ---
private int measureWidth(ParseNode node)
{
  if (auto cached = node in layoutCache)
  {
    if (cached.width != 0)
      return cached.width;
  }

  string lbl = getLabel(node);
  string lex = getLexemeValue(node);

  int lblLen = cast(int) lbl.length;
  int lexLen = lex is null ? 0 : cast(int) lex.length;
  int contentW = max(lblLen, lexLen);

  int w;
  if (node.children.length == 0)
  {
    // Leaf node needs padding around its widest content for centering and stems
    w = max(contentW + 2, 3);
    layoutCache[node] = LayoutInfo(w, 0, lbl, lblLen, lex, lexLen, contentW);
    return w;
  }

  int sumWidth = 0;

  foreach (i, child; node.children)
  {
    int cw = measureWidth(child);
    if (i > 0)
    {
      sumWidth += SIBLING_SPACING;
    }
    sumWidth += cw;
  }

  // Ensure parent node's width covers its content centered over the children
  w = max(sumWidth, contentW + 2);

  layoutCache[node] = LayoutInfo(w, 0, lbl, lblLen, lex, lexLen, contentW);
  return w;
}

private int measureDepth(ParseNode node)
{
  if (auto cached = node in layoutCache)
  {
    if (cached.depth != 0)
      return cached.depth;
  }

  if (!(node in layoutCache))
    measureWidth(node);

  int maxD = 0;
  foreach (child; node.children)
  {
    int d = measureDepth(child);
    if (d > maxD)
    {
      maxD = d;
    }
  }

  int d = 1 + maxD;

  layoutCache[node].depth = d;
  return d;
}

// --- Traversal 3: Render to Grid (Pre-order/Top-Down) ---

private int render(ref char[][] grid, ParseNode node, int startX, int y)
{
  auto info = layoutCache[node];
  int w = info.width;
  int lblLen = info.labelLength;
  int lexLen = info.lexemeLength;

  if (w <= 0)
    return 0;

  // The center of the content (label/lexeme) within the allocated width
  int contentCenter = startX + (w - 1) / 2;

  // 1. Draw Node Label (y)
  int labelX = contentCenter - (lblLen - 1) / 2;
  for (int i = 0; i < lblLen; i++)
  {
    if (y < grid.length && labelX + i < grid[0].length)
    {
      grid[y][labelX + i] = info.label[i];
    }
  }

  // 2. Draw Vertical Stem (y+1) 
  // Draw this if the node has a lexeme OR if it has children (i.e., it's a non-leaf internal node)
  if (info.lexemeValue !is null || node.children.length > 0) // <-- ADDED node.children.length > 0
  {
    if (y + 1 < grid.length && contentCenter < grid[0].length)
    {
      grid[y + 1][contentCenter] = '|';
    }
  }

  // 3. Draw Lexeme Value (y+3) 
  if (info.lexemeValue !is null)
  {
    int lexX = contentCenter - (lexLen - 1) / 2;

    for (int i = 0; i < lexLen; i++)
    {
      if (y + 3 < grid.length && lexX + i < grid[0].length)
      {
        grid[y + 3][lexX + i] = info.lexemeValue[i];
      }
    }
  }

  if (node.children.length == 0)
  {
    return w; // Leaf node, nothing more to draw
  }

  // 4. Draw Connectors and Recurse
  int parentCenter = contentCenter;
  int childStart = startX;

  for (size_t i = 0; i < node.children.length; i++)
  {
    ParseNode child = node.children[i];

    if (i > 0)
    {
      childStart += SIBLING_SPACING;
    }

    int cw = layoutCache[child].width;
    int childCenter = childStart + (cw - 1) / 2;

    // Draw horizontal line (y+2)
    if (y + 2 < grid.length)
    {
      // Draw horizontal line using UNDERSCORE (_)
      for (int pos = min(parentCenter, childCenter); pos <= max(parentCenter, childCenter);
        pos++)
      {
        if (pos < grid[0].length)
          grid[y + 2][pos] = '_';
      }

      // Draw connection points (y+2) using ASTERISK (*)
      if (parentCenter < grid[0].length)
        grid[y + 2][parentCenter] = '*';
      if (childCenter < grid[0].length)
        grid[y + 2][childCenter] = '*';
    }

    // Draw vertical stem down from horizontal line (y+4) 
    // This is the connection point for the child's entire subtree
    if (y + 4 < grid.length && childCenter < grid[0].length)
    {
      grid[y + 4][childCenter] = '|';
    }

    // Recurse to render the child's subtree, starting at the next full level
    render(grid, child, childStart, y + LEVEL_HEIGHT);

    // Advance childStart for the next sibling's start position
    childStart += cw;
  }

  return w;
}

// --- Main Printing Function ---

void printVerticalTree(ParseNode root)
{
  if (root is null)
  {
    writeln("<empty tree>");
    return;
  }

  layoutCache.clear();

  int w = measureWidth(root);
  int h = measureDepth(root) * LEVEL_HEIGHT;

  if (w < 1)
    w = 1;
  if (h < 1)
    h = 1;

  char[][] grid;
  grid.length = h;
  for (int i = 0; i < h; i++)
  {
    grid[i].length = w;
    for (int j = 0; j < w; j++)
    {
      grid[i][j] = ' ';
    }
  }

  render(grid, root, 0, 0);

  for (int i = 0; i < h; i++)
  {
    string s = cast(string) grid[i];

    int trimLen = cast(int) s.length;

    // Find the index of the last non-space character
    int lastCharIndex = -1;
    for (int j = 0; j < trimLen; j++)
    {
      if (s[j] != ' ')
      {
        lastCharIndex = j;
      }
    }

    // Only print if the line contains any non-space character
    if (lastCharIndex != -1)
    {
      // Set trimLen to one position past the last character found
      trimLen = lastCharIndex + 1;
      writeln(s[0 .. trimLen]);
    }
  }
}
