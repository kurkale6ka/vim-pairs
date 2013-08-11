" Use "" instead of ci' or ci" or ci`
"
" Author: Dimitar Dimitrov (mitkofr@yahoo.fr), kurkale6ka
"
" Latest version at:
" https://github.com/kurkale6ka/vim-quotes

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

let s:save_cursor = getpos('.')

function! s:CIo(lchars)
   if search ('['.a:lchars.']', 'b', line('.'))
      let lchar = getline('.')[col('.') - 1]
      if search (lchar, '', line('.'))
         call setpos('.', s:save_cursor)
         execute 'normal! ci'.lchar
         echo 'Same line: between chars'
         return '1'.lchar
      else
         return '0'.lchar
      endif
   endif
endfunction

function! CIpunct(chars)

   let my_changedtick = b:changedtick
   let stop_line      = line('.')

   if match(getline('.'), '['.a:chars.']', col('.') - 1) == col('.') - 1
      let char = getline('.')[col('.') - 1]
      if strlen(substitute(getline('.'), '[^'.char.']', '', 'g')) > 1
         execute 'normal! ci'.char
         echo 'Under cursor'
      endif
   else
      let chars = a:chars
      let char = s:CIo(chars)
      while strpart(char, 0, 1) == 0 && strpart(char, 1) != ''
         let chars = substitute(chars, strpart(char, 1), '', '')
         let char = s:CIo(chars)
      endwhile
      if strpart(char, 0, 1) == 0
         let found = 0
         while search ('['.a:chars.']', '', line('w$'))
            let char = getline('.')[col('.') - 1]
            if strlen(substitute(getline('.'), '[^'.char.']', '', 'g')) > 1
               execute 'normal! ci'.char
               echo 'After cursor (second half of buffer)'
               let found = 1
               break
            endif
         endwhile
         if found == 0
            goto
            while search ('['.a:chars.']', '', stop_line)
               let char = getline('.')[col('.') - 1]
               if strlen(substitute(getline('.'), '[^'.char.']', '', 'g')) > 1
                  execute 'normal! ci'.char
                  echo 'After cursor (first half of buffer)'
                  break
               endif
            endwhile
         endif
      endif
   endif

   " There are edge cases if setpos is commented out:
   " '       1            '      X      ' will result in:
   " '|'             '                    instead of:
   " '                    '|'
   "
   " But with setpos, the following won't do anything because the cursor
   " would eventually return to the backtick and ci' isn't correct there:
   " '       '        "       ` (cursor on the backtick)

   if my_changedtick == b:changedtick

      echohl  ErrorMsg
      echo   'Nothing to do'
      echohl  None

      call setpos('.', s:save_cursor)
   else
      normal! l
      startinsert
   endif

endfunction

nmap <silent> <plug>PunctCIpunct :<c-u>call CIpunct('"'."'`")<cr>
nmap       "" <plug>PunctCIpunct

let &cpoptions = s:savecpo
unlet s:savecpo
