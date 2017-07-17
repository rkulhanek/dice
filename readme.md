This is a general dice roller for tabletop RPGs.

## Syntax
Enter dice codes in any of the standard notations.
e.g. ```1d20+5, 2d6, d10 + 2, d17-12``` will all work.

Separate rolls can be entered in the same line by separating them with commas.  So, e.g.  ```1d20+5, 2d6, d10 + 2, d17-12``` will roll all four of those and display the results separately.

If a single roll adds together separate dice codes, it'll display them all separately, then display the total.
```2d6+1d6-5``` will display, e.g. ```7 + 2 - 5 = 14```.  The final value will be highlighted in blue.

Any text that isn't a dice code and doesn't contain any of these characters: ```+- ,``` is a comment, and will be displayed in grey.

So to bring it all together, if you enter
```sword 1d20 + 5, 1d8+2d6 (fire)+2``` will result in something like:
```sword 8 + 5 = 13, 3 + 10 (fire) + 2 = 15```

## Command History
This uses the standard Unix readline library to let you cycle through the command history.  Full documentation for that exists elsewhere, but the most common commands you'll be using are:

```<up>```, ```<down>``` : cycle through previous commands
```<ctrl-r>``` keyword ```<enter>``` : run the last command containing "keyword".  You can cycle through them in reverse order by hitting ```<ctrl-r>``` again before hitting ```<enter>```.

## Dependencies

### Compiler
 * dmd (or another D compiler if you adjust the makefile)

### Libraries
 * readline
 * ncurses
