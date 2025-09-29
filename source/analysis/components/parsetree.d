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
private enum int SIBLING_SPACING = 3; // Minimum required spaces between sibling subtrees
private enum int LEVEL_HEIGHT = 3; // Height of one level (node, stem, line, branch stem)

// --- Node Metadata Cache ---
// Structures to hold pre-calculated layout info during traversals.
// These will be calculated and stored in a map since we cannot modify ParseNode directly.
struct LayoutInfo
{
  int width;
  int depth;
  string label; // The combined display string: "<x> (D)"
  int labelLength;
}

private LayoutInfo[ParseNode] layoutCache;

// --- Helper Functions ---

/// Gets the combined display string (e.g., "<x> (D)").
private string getLabel(ParseNode node)
{
  string base = node.symbol.value;

  if (node.children.length == 0 && node.token.lexeme.length > 0)
  {
    immutable skipLexeme = [
      Terminal.HI, Terminal.BYE, Terminal.BAR, Terminal.FILL,
      Terminal.LINE, Terminal.COMMA, Terminal.SEMICOLON
    ];

    if (!canFind(skipLexeme, node.token.kind))
      return base ~ " (" ~ node.token.lexeme ~ ")";
  }
  return base;
}

// --- Traversal 1: Measure Width (Post-order/Bottom-Up) ---
private int measureWidth(ParseNode node)
{
  if (auto cached = node in layoutCache)
  {
    return cached.width;
  }

  string lbl = getLabel(node);
  int lblLen = cast(int) lbl.length;

  if (node.children.length == 0)
  {
    int w = max(lblLen, 1);
    layoutCache[node] = LayoutInfo(w, 0, lbl, lblLen);
    return w;
  }

  int sumWidth = 0;

  // Sum width of children subtrees
  foreach (i, child; node.children)
  {
    int cw = measureWidth(child);
    if (i > 0)
    {
      sumWidth += SIBLING_SPACING;
    }
    sumWidth += cw;
  }

  int w = max(sumWidth, lblLen);

  // Cache the result
  layoutCache[node] = LayoutInfo(w, 0, lbl, lblLen);
  return w;
}

// --- Traversal 2: Measure Depth (Post-order/Bottom-Up) ---
private int measureDepth(ParseNode node)
{
  if (auto cached = node in layoutCache)
  {
    // Only return depth if it was calculated; otherwise, proceed with calculation
    if (cached.depth != 0)
      return cached.depth;
  }

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

  // Update cache with depth
  if (auto cached = node in layoutCache)
  {
    layoutCache[node].depth = d;
  }
  else
  {
    // Should not happen if measureWidth runs first, but for safety:
    layoutCache[node] = LayoutInfo(measureWidth(node), d, getLabel(node), cast(int) getLabel(node)
        .length);
  }
  return d;
}

// --- Traversal 3: Render to Grid (Pre-order/Top-Down) ---

/// Renders the tree onto the grid starting at (startX, y).
/// Returns the width consumed by the current node's subtree.
private int render(ref char[][] grid, ParseNode node, int startX, int y)
{
  auto info = layoutCache[node];
  int w = info.width;
  int lblLen = info.labelLength;
  string lbl = info.label;

  if (w <= 0)
    return 0;

  // 1. Draw Node Label
  int labelX = startX + (w - lblLen) / 2;
  for (int i = 0; i < lblLen; i++)
  {
    if (y < grid.length && labelX + i < grid[0].length)
    {
      grid[y][labelX + i] = lbl[i];
    }
  }

  if (node.children.length == 0)
  {
    return w; // Leaf node, nothing more to draw
  }

  // 2. Draw Connectors and Recurse
  int parentCenter = labelX + (lblLen - 1) / 2;
  int childStart = startX;

  foreach (i, child; node.children)
  {
    if (i > 0)
    {
      childStart += SIBLING_SPACING;
    }

    int cw = layoutCache[child].width;
    int childCenter = childStart + (cw - 1) / 2;

    // Draw vertical stem down from parent
    if (y + 1 < grid.length && parentCenter < grid[0].length)
    {
      grid[y + 1][parentCenter] = '|';
    }

    // Draw horizontal line (y+2) and child stem ('|' at y+3)
    if (y + 2 < grid.length)
    {
      // Draw horizontal line
      for (int pos = min(parentCenter, childCenter); pos <= max(parentCenter, childCenter);
        pos++)
      {
        if (pos < grid[0].length)
          grid[y + 2][pos] = '-';
      }

      // Draw connection points (y+2)
      if (parentCenter < grid[0].length)
        grid[y + 2][parentCenter] = '+';
      if (childCenter < grid[0].length)
        grid[y + 2][childCenter] = '+';
    }

    // Draw child stem (y+3) - this is drawn by the child's render call (Level 1)
    // Wait, the Go code implies a 3-row cycle: Node(y), |(y+1), Line(y+2). 
    // The next node will be at y+3, so we only need to render the line/branch at y+2.

    // Recurse to render the child's subtree
    render(grid, child, childStart, y + LEVEL_HEIGHT);

    // Advance childStart for the next sibling
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

  // Reset cache before starting a fresh run
  layoutCache.clear();

  // Traversal 1 & 2: Measure width and depth for all nodes
  int w = measureWidth(root);
  int h = measureDepth(root) * LEVEL_HEIGHT;

  if (w < 1)
    w = 1;
  if (h < 1)
    h = 1;

  // Prepare the 2D grid
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

  // Traversal 3: Render to the grid
  render(grid, root, 0, 0);

  // Print the grid row by row
  for (int i = 0; i < h; i++)
  {
    string s = cast(string) grid[i];

    // Trim trailing spaces and skip empty lines to save vertical space
    int trimLen = cast(int) s.length;
    while (trimLen > 0 && s[trimLen - 1] == ' ')
    {
      trimLen--;
    }

    if (trimLen > 0)
    {
      writeln(s[0 .. trimLen]);
    }
    // If the line is entirely spaces (e.g., the stem '|' line), keep it.
    // The original Go code skips entirely blank lines, but we need the stem/line
    // rows even if they have no labels.
    else if (i % LEVEL_HEIGHT != 0) // Only print the horizontal and vertical line rows if non-label
    {
      writeln(s);
    }
  }
}
