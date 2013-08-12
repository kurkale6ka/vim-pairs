" 1. Use "" instead of ci' or ci" or ci`
" 2. New punctuation text objects: ci/, di;, yi*, ...
"                                  ca/, da;, ya*, ...
" Author: Dimitar Dimitrov (mitkofr@yahoo.fr), kurkale6ka
"
" Latest version at:
" https://github.com/kurkale6ka/vim-quotes

if exists('g:loaded_ptext_objects') || &compatible || v:version < 700
   if &compatible && &verbose
      echo "Punctuation Text Objects is not designed to work in compatible mode."
   elseif v:version < 700
      echo "Punctuation Text Objects needs Vim 7.0 or above to work correctly."
   endif
   finish
endif

let g:loaded_ptext_objects = 1

let s:savecpo = &cpoptions
set cpoptions&vim

let s:quotes = "'`".'"'

function! CIpunct(chars, op)

   let s:op = a:op =~ 'c' ? 'd' : strpart(a:op, 0, 1)
   let s:oprange = strpart(a:op, 1)

   let s:save_cursor  = getpos('.')
   let stop_line      =   line('.')
   let my_changedtick = b:changedtick

   let s:success = 0
   let over = 0
   if match(getline('.'), '['.a:chars.']', col('.') - 1) == col('.') - 1
      let char = getline('.')[col('.') - 1]
      if strlen(substitute(getline('.'), '[^'.char.']', '', 'g')) > 1
         let s:success = 1
         " echo 'Under cursor'
         if s:quotes =~ char
            execute 'normal! di'.char
         else
            if search (char, 'n', line('.'))
               if s:oprange == 'a'
                  execute 'normal!  '.s:op.'f'.char
               else
                  execute 'normal! l'.s:op.'t'.char
               endif
            else
               if s:oprange == 'a'
                  execute 'normal! v'.s:op.'F'.char
               else
                  execute 'normal!  '.s:op.'T'.char
               endif
            endif
         endif
         let over = 1
      endif
   endif

   if !over

      function! s:CIo(lchars)
         if search ('['.a:lchars.']', 'b', line('.'))
            let lchar = getline('.')[col('.') - 1]
            if search (lchar, '', line('.'))
               let s:success = 1
               " echo 'Same line: between chars'
               call setpos('.', s:save_cursor)
               if s:quotes =~ lchar
                  execute 'normal! di'.lchar
               else
                  if s:oprange == 'a'
                     execute 'normal! '.s:op.'F'.lchar.'df'.lchar
                  else
                     execute 'normal! '.s:op.'T'.lchar.'dt'.lchar
                  endif
               endif
               return '1'.lchar
            else
               return '0'.lchar
            endif
         endif
      endfunction

      let chars = a:chars
      let char  = s:CIo(chars)
      while strpart(char, 0, 1) == 0 && strpart(char, 1) != ''
         let chars = substitute(chars, strpart(char, 1), '', '')
         let char  = s:CIo(chars)
      endwhile

      if strpart(char, 0, 1) == 0
         call setpos('.', s:save_cursor)
         let found = 0
         while search ('['.a:chars.']', '', line('w$'))
            let char = getline('.')[col('.') - 1]
            if strlen(substitute(getline('.'), '[^'.char.']', '', 'g')) > 1
               let s:success = 1
               " echo 'After cursor (second half of buffer)'
               if s:quotes =~ char
                  execute 'normal! di'.char
               else
                  if s:oprange == 'a'
                     execute 'normal!  '.s:op.'f'.char
                  else
                     execute 'normal! l'.s:op.'t'.char
                  endif
               endif
               let found = 1
               break
            endif
         endwhile
         if found == 0
            goto
            while search ('['.a:chars.']', '', stop_line)
               let char = getline('.')[col('.') - 1]
               if strlen(substitute(getline('.'), '[^'.char.']', '', 'g')) > 1
                  let s:success = 1
                  " echo 'After cursor (first half of buffer)'
                  if s:quotes =~ char
                     execute 'normal! di'.char
                  else
                     if s:oprange == 'a'
                        execute 'normal!  '.s:op.'f'.char
                     else
                        execute 'normal! l'.s:op.'t'.char
                     endif
                  endif
                  break
               endif
            endwhile
         endif
      endif

   endif

   if s:success == 1 && strpart(a:op, 0, 1) == 'c'
      startinsert
   elseif s:success == 0 || s:success == 1 && my_changedtick == b:changedtick
      if s:op != 'y'
         echohl  ErrorMsg
         echo   'Nothing to do'
         echohl  None
      endif
      call setpos('.', s:save_cursor)
   endif

endfunction

nmap <silent> <plug>PunctCIpunct :<c-u>call CIpunct('"'."'`", 'ci')<cr>
nmap       "" <plug>PunctCIpunct

" for char in [ '!', '$', '%', '^', '&', '*', '_', '-', '+', '=', ':', ';', '@', '~', '#', '<bar>', '<bslash>', ',', '.', '?', '/' ]
for char in [ '!',      '%',      '&', '*', '_', '-', '+', '=', ':', ';', '@',      '#', '<bar>',             ',',      '?', '/' ]
   execute 'nnoremap <silent> ci'.char." :<c-u>call CIpunct('".char."'".", 'ci')<cr>"
   execute 'nnoremap <silent> di'.char." :<c-u>call CIpunct('".char."'".", 'di')<cr>"
   execute 'nnoremap <silent> yi'.char." :<c-u>call CIpunct('".char."'".", 'yi')<cr>"
   " execute 'xnoremap <silent>  i'.char." :<c-u>call CIpunct('".char."'".", 'vi')<cr>"
   execute 'nnoremap <silent> ca'.char." :<c-u>call CIpunct('".char."'".", 'ca')<cr>"
   execute 'nnoremap <silent> da'.char." :<c-u>call CIpunct('".char."'".", 'da')<cr>"
   execute 'nnoremap <silent> ya'.char." :<c-u>call CIpunct('".char."'".", 'ya')<cr>"
   " execute 'xnoremap <silent>  a'.char." :<c-u>call CIpunct('".char."'".", 'va')<cr>"
endfor

let &cpoptions = s:savecpo
unlet s:savecpo
