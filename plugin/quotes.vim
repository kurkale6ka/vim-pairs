" Use "" instead of ci" or ci'
"
" Author: Dimitar Dimitrov (mitkofr@yahoo.fr), kurkale6ka
"
" Latest version at:
" http://github.com/kurkale6ka/vimfiles/blob/master/plugin/quotes.vim
"
" todo: highlight the matched quotes before changing them
" todo: add support for backticks

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

function! s:ChangeTextQuotes (changedtick, quote, text)

   " Beyond EOL
   if col('.') >= col('$')

      call search(a:quote, 'cbW', line('.'))
   endif

   execute 'normal! di' . a:quote

   if a:changedtick != b:changedtick

      if empty(a:text)

         let my_text = input('Text: ')

      elseif 'no_text' == a:text

         let my_text = ''
      else
         let my_text = a:text
      endif

      execute 'normal! i' . my_text . "\<esc>"

      return my_text
   endif

endfunction

function! CI_quotes (text)

   let my_changedtick = b:changedtick

   let save_cursor = getpos(".")

   let stop_line = line('.') - 1

   " Look for quotes from the cursor line to the bottom of the screen
   " todo: put into a function the code between '---'s
   " ---
   let nb_quotes  = strlen(substitute(getline('.'), "[^']", '', 'g'))
   let nb_qquotes = strlen(substitute(getline('.'), '[^"]', '', 'g'))

   while nb_quotes < 2 && nb_qquotes < 2

      normal! $

      if 0 == search ('["'."']", '', line('w$'))

         break
      else
         let nb_quotes  = strlen(substitute(getline('.'), "[^']", '', 'g'))
         let nb_qquotes = strlen(substitute(getline('.'), '[^"]', '', 'g'))
      endif

   endwhile
   " ---

   " Look for quotes from the top of the screen to the cursor line
   if nb_quotes < 2 && nb_qquotes < 2 && 1 != line('$')

      execute line('w0')

      " ---
      let nb_quotes  = strlen(substitute(getline('.'), "[^']", '', 'g'))
      let nb_qquotes = strlen(substitute(getline('.'), '[^"]', '', 'g'))

      while nb_quotes < 2 && nb_qquotes < 2

         normal! $

         if 0 == search ('["'."']", '', stop_line)

            break
         else
            let nb_quotes  = strlen(substitute(getline('.'), "[^']", '', 'g'))
            let nb_qquotes = strlen(substitute(getline('.'), '[^"]', '', 'g'))
         endif

      endwhile
      " ---
   endif

   if nb_quotes >= 2 && nb_qquotes >= 2

      " If before the first quote or double quote...
      if !search ('["' . "']", 'cbW', line('.'))

         " ...go to the first one
         call search ('["' . "']", 'cW', line('.'))
      endif

      if "'" == matchstr(getline('.'), "['".'"]', col('.') - 1)

         let quote_under_cursor = "'"
         let anti_quote         = '"'
      else
         let quote_under_cursor = '"'
         let anti_quote         = "'"
      endif

      " Not at EOL
      if col('.') + 1 != col('$')

         call setpos('.', save_cursor)

         let at_eol = 0
      else
         let at_eol = 1
      endif

      if empty(a:text)

         let my_text = input('Text: ')

      elseif 'no_text' == a:text

         let my_text = ''
      else
         let my_text = a:text
      endif

      if at_eol || !at_eol && search (quote_under_cursor, 'cnW', line('.'))

         execute 'normal! ci' . quote_under_cursor . my_text . "\<esc>"
      else
         execute 'normal! ci' . anti_quote         . my_text . "\<esc>"
      endif

   elseif nb_quotes >= 2

      let my_text = s:ChangeTextQuotes (my_changedtick, "'", a:text)

   elseif nb_qquotes >= 2

      let my_text = s:ChangeTextQuotes (my_changedtick, '"', a:text)
   endif

   if my_changedtick == b:changedtick

      echohl  ErrorMsg
      echo   'Nothing to do'
      echohl  None

      call setpos('.', save_cursor)
   else
      if empty(my_text)

         let my_text = 'no_text'

         normal! l

         startinsert
      endif

      " Repeat
      let virtualedit_bak = &virtualedit
      set virtualedit=

      silent! call repeat#set(":call CI_quotes('" . my_text . "')\<cr>")

      let &virtualedit = virtualedit_bak
   endif

endfunction

nmap <silent> <plug>QuotesCIQuotes :<c-u>call CI_quotes('')<cr>
nmap       "" <plug>QuotesCIQuotes

let &cpoptions = s:savecpo
unlet s:savecpo
