/// analysis.components.parsetree implements printing the vertical parse tree
/// the parse tree is navigated with post-order traveral
module analysis.components.parsetree;

import std.algorithm : map, reduce, max, min;
import std.algorithm.searching : canFind;
import std.array : array, appender;
import std.conv : to;
import std.stdio : writeln, write;
import std.string;

import analysis.components.parsenode : ParseNode;
import bnf.symbols : Symbol, Terminal, NonTerminal;

// constants
private enum int SIBLING_SPACING = 3;
private enum int LEVEL_HEIGHT = 5;
// node layout
struct LayoutInfo
{
  int width;
  int depth;
  string label;
  int labelLength;
  string lexemeValue;
  int lexemeLength;
  int contentWidth;
}

private LayoutInfo[ParseNode] layoutCache;

// helper functions

private string getLabel(ParseNode node)
{
  return node.symbol.value;
}

private string getLexemeValue(ParseNode node)
{
  if (node.children.length == 0 && node.token.lexeme.length > 0)
  {
    immutable skipLexeme = [
      Terminal.HI, Terminal.BYE, Terminal.BAR, Terminal.FILL,
      Terminal.LINE, Terminal.COMMA, Terminal.SEMICOLON
    ];

    if (!canFind(skipLexeme, node.token.kind))
      return node.token.lexeme;
  }
  return null;
}

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

private int render(ref char[][] grid, ParseNode node, int startX, int y)
{
  auto info = layoutCache[node];
  int w = info.width;
  int lblLen = info.labelLength;
  int lexLen = info.lexemeLength;

  if (w <= 0)
    return 0;

  int contentCenter = startX + (w - 1) / 2;

  int labelX = contentCenter - (lblLen - 1) / 2;
  for (int i = 0; i < lblLen; i++)
  {
    if (y < grid.length && labelX + i < grid[0].length)
    {
      grid[y][labelX + i] = info.label[i];
    }
  }

  if (info.lexemeValue !is null || node.children.length > 0)
  {
    if (y + 1 < grid.length && contentCenter < grid[0].length)
    {
      grid[y + 1][contentCenter] = '|';
    }
  }

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
    return w;
  }

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

    if (y + 2 < grid.length)
    {
      for (int pos = min(parentCenter, childCenter); pos <= max(parentCenter, childCenter);
        pos++)
      {
        if (pos < grid[0].length)
          grid[y + 2][pos] = '_';
      }

      if (parentCenter < grid[0].length)
        grid[y + 2][parentCenter] = '*';
      if (childCenter < grid[0].length)
        grid[y + 2][childCenter] = '*';
    }

    if (y + 4 < grid.length && childCenter < grid[0].length)
    {
      grid[y + 4][childCenter] = '|';
    }

    render(grid, child, childStart, y + LEVEL_HEIGHT);

    childStart += cw;
  }

  return w;
}

// main printing function

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

    int lastCharIndex = -1;
    for (int j = 0; j < trimLen; j++)
    {
      if (s[j] != ' ')
      {
        lastCharIndex = j;
      }
    }

    if (lastCharIndex != -1)
    {
      trimLen = lastCharIndex + 1;
      writeln(s[0 .. trimLen]);
    }
  }
}
