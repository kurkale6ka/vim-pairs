New punctuation text objects
============================

   `ci/`, `di;`, `yi*`, `vi@` ...  
   `ca/`, `da;`, `ya*`, `va@` ...

   ---

   `ciq` (or `""`) changes content inside **ANY** kind of quotes  
   `vaq`, `yiq` ...

   ---

   `ci<space>`, `da<space>` ... modify **ANY** punctuation pair

Supported punctuation signs
---------------------------
`` ` `` `"` `'`  
`!` `$` `%` `^` `&` `*` `_` `-` `+` `=` `:` `;` `@` `~` `#` `|` `\` `,` `.` `?` `/`

### Algorithm:  
Do in order. If a step succeeds skip the rest.

1. _same line_: match under the cursor: act to the right if possible, else to the left
2. _same line_: jump to a match on the left, then act to the right if possible or else repeat
3. _same line and **↓**_: try matching to the right, also past the current line
   if no match till EOF, start from byte one and do the same till initial position of cursor

Examples:
---------

**_`[]` and `|` will represent the cursor_**  

`ciq` or `""`
```
Lorem [] dolor "          " adipisicing elit
Lorem    dolor "|" adipisicing elit
```
---
`da^` or `da<space>`
```
Lorem    dolor "    ^ []  ^     " adipisicing elit
Lorem    dolor "         " adipisicing elit
```
---
`vi@` or `vi<space>`
```
Lorem    dolor @        @        [@]  adipisicing elit
Lorem    dolor @        @---------@   adipisicing elit
```
**Note**: the above is different from what **Vim** would do.  
_explanation_: `'      '      [']` then `ci'` WON'T change anything!

---
`di;` or `di<space>`
```
Lorem  %     %  []  ;            ; elit
Lorem  %     %      ;; elit
```
---
`gUiq`
```
Lorem    dolor  '    val `  X  ' orem       ` adipisicing elit
Lorem    dolor  '    val `  X  ' OREM       ` adipisicing elit
```
---
`yi.` or `yi<space>`
```
Lorem    dolor  sit amet  []   adipisicing elit
incididunt ut labore .dolore. aliqua

Now: dolore is in reg "
```
---
`""`
```
START OF FILE
Lorem    dolor  ' sit amet     '  adipisicing elit
incididunt ut labore et dolore [] magna aliqua.
EOF
```
_Result after searching for a match and wrapping around EOF_:
```
START OF FILE
Lorem    dolor  '|'  adipisicing elit
incididunt ut labore et dolore [] magna aliqua.
EOF
```
