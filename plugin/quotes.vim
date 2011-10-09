" Use "" instead of ci' or ci" or ci`
"
" Author: Dimitar Dimitrov (mitkofr@yahoo.fr), kurkale6ka
"
" Latest version at:
" https://github.com/kurkale6ka/vim-quotes
"
" todo: '               '      X     "              "
"       currently results in:
"       '|'            "              "
"       which is in accordance with the algorithm defined below.
"       What one would prefer though is:
"       '               '            "|"

if exists('g:loaded_quotes') || &compatible || v:version < 700

   if &compatible && &verbose
      echo "Quotes is not designed to work in compatible mode."
   elseif v:version < 700
      echo "Quotes needs Vim 7.0 or above to work correctly."
   endif

   finish
endif

let g:loaded_quotes = 1

let s:savecpo = &cpoptions
set cpoptions&vim

function! CI_quotes()

   let my_changedtick = b:changedtick
   let save_cursor    = getpos(".")
   let stop_line      = line('.')

   " 1. In this first section, all calculations are done without quitting the
   "    current line.
   if !search ('["' . "'`]", 'cn', line('.'))
      let nb_quotes    = 0
      let nb_qquotes   = 0
      let nb_backticks = 0
   else
      let nb_quotes    = strlen(substitute(getline('.'), "[^']", '', 'g'))
      let nb_qquotes   = strlen(substitute(getline('.'), '[^"]', '', 'g'))
      let nb_backticks = strlen(substitute(getline('.'), '[^`]', '', 'g'))
   endif

   if nb_quotes >= 2 && nb_qquotes < 2 && nb_backticks < 2 &&
      \search ("'", 'cn', line('.'))

      normal! ci'
   elseif nb_quotes >= 2 && nb_qquotes < 2 && nb_backticks < 2
      let nb_quotes = 0
   endif

   if nb_quotes < 2 && nb_qquotes >= 2 && nb_backticks < 2 &&
      \search ('"', 'cn', line('.'))

      normal! ci"
   elseif nb_quotes < 2 && nb_qquotes >= 2 && nb_backticks < 2
      let nb_qquotes = 0
   endif

   if nb_quotes < 2 && nb_qquotes < 2 && nb_backticks >= 2 &&
      \search ('`', 'cn', line('.'))

      normal! ci`
   elseif nb_quotes < 2 && nb_qquotes < 2 && nb_backticks >= 2
      let nb_backticks = 0
   endif

   if (nb_quotes  >= 2 && nb_qquotes   >= 2) ||
     \(nb_quotes  >= 2 && nb_backticks >= 2) ||
     \(nb_qquotes >= 2 && nb_backticks >= 2)

      " Algorithm: go to the previous quote, then look forward for a matching
      "            one. If there isn't one, repeat these two operations until
      "            success (3 times maximum for our 3 kind of quotes).
      call search ('["' . "'`]", 'cb', line('.'))
      let quote_under_cursor = matchstr(getline('.'), "['".'"`]', col('.') - 1)

      if search (quote_under_cursor, 'n', line('.'))

         " There are edge cases if setpos is commented out. ex:
         " '       1            '      X      ' will result in:
         " '|'             '                     instead of:
         " '                    '|'
         "
         " But with setpos, the following won't do anything because the cursor
         " would eventually return to the backtick and ci' isn't correct there:
         " '       '        "       ` (cursor on the backtick)
         " call setpos('.', save_cursor)
         execute 'normal! ci' . quote_under_cursor
      else
         for i in range(3)

            call search ('["' . "'`]", 'b', line('.'))
            let quote_under_cursor =
               \matchstr(getline('.'), "['".'"`]', col('.') - 1)

            if search (quote_under_cursor, 'n', line('.'))

               " same as above
               " call setpos('.', save_cursor)
               execute 'normal! ci' . quote_under_cursor
               break
            endif
         endfor

      endif

   " 2. In this second section, since there aren't pairs of quotes on the
   "    current line, we explore the whole screen till we find one.
   elseif nb_quotes < 2 && nb_qquotes < 2 && nb_backticks < 2

      " Look for quotes from the cursor line to the bottom of the screen
      while nb_quotes < 2 && nb_qquotes < 2 && nb_backticks < 2

         normal! $

         if !search ('["'."'`]", '', line('w$'))
            break
         else
            let nb_quotes    = strlen(substitute(getline('.'), "[^']", '', 'g'))
            let nb_qquotes   = strlen(substitute(getline('.'), '[^"]', '', 'g'))
            let nb_backticks = strlen(substitute(getline('.'), '[^`]', '', 'g'))
         endif

      endwhile

      " Look for quotes from the top of the screen to the cursor line
      if nb_quotes < 2 && nb_qquotes < 2 && nb_backticks < 2

         execute line('w0')
         normal! 0

         let nb_quotes    = strlen(substitute(getline('.'), "[^']", '', 'g'))
         let nb_qquotes   = strlen(substitute(getline('.'), '[^"]', '', 'g'))
         let nb_backticks = strlen(substitute(getline('.'), '[^`]', '', 'g'))

         while nb_quotes < 2 && nb_qquotes < 2 && nb_backticks < 2

            normal! $

            if !search ('["'."'`]", '', stop_line)
               break
            else
               let nb_quotes    = strlen(substitute(getline('.'), "[^']", '', 'g'))
               let nb_qquotes   = strlen(substitute(getline('.'), '[^"]', '', 'g'))
               let nb_backticks = strlen(substitute(getline('.'), '[^`]', '', 'g'))
            endif

         endwhile
      endif

      " We are at BOF. If the is a single pair of quotes, we can directly ci it.
      if      nb_quotes >= 2 && nb_qquotes <  2 && nb_backticks <  2

         normal! ci'

      elseif  nb_quotes <  2 && nb_qquotes >= 2 && nb_backticks <  2

         normal! ci"

      elseif  nb_quotes <  2 && nb_qquotes <  2 && nb_backticks >= 2

         normal! ci`

      " If all pairs are present, we can ci the quote under the cursor
      elseif  nb_quotes >= 2 && nb_qquotes >= 2 && nb_backticks >= 2

         let quote_under_cursor = matchstr(getline('.'), "['".'"`]', col('.') - 1)
         execute 'normal! ci' . quote_under_cursor

      " If there are two pairs of quotes only, we have to find the quote that is
      " part of a pair that comes first!
      elseif (nb_quotes  >= 2 && nb_qquotes   >= 2) ||
            \(nb_quotes  >= 2 && nb_backticks >= 2) ||
            \(nb_qquotes >= 2 && nb_backticks >= 2)

         while 1

            let quote_under_cursor =
               \matchstr(getline('.'), "['".'"`]', col('.') - 1)

            if  (nb_quotes    >= 2 && "'" == quote_under_cursor) ||
               \(nb_qquotes   >= 2 && '"' == quote_under_cursor) ||
               \(nb_backticks >= 2 && '`' == quote_under_cursor)

               execute 'normal! ci' . quote_under_cursor
               break
            else
               call search ('["' . "'`]", '', line('.'))
            endif

         endwhile

      endif
   endif

   if my_changedtick == b:changedtick &&
      \nb_quotes < 2 && nb_qquotes < 2 && nb_backticks < 2

      echohl  ErrorMsg
      echo   'Nothing to do'
      echohl  None

      call setpos('.', save_cursor)
   else
      normal! l
      startinsert
   endif

endfunction

nmap <silent> <plug>QuotesCIQuotes :<c-u>call CI_quotes()<cr>
nmap       "" <plug>QuotesCIQuotes

let &cpoptions = s:savecpo
unlet s:savecpo
