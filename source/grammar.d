module grammar;

string[string] rules = [
  "<graph>": "HI <draw> BYE",
  "<draw>": "<action> | <action> ; <draw>",
  "<action>": "bar <x><y>,<y> | line <x><y>,<x><y> | fill <x><y>",
  "<x>": "A | B | C | D | E",
  "<y>": "1 | 2 | 3 | 4 | 5"
];
