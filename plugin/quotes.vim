" 1. Use "" instead of ci' or ci" or ci`
" 2. New puctuation objects: ci/, di;, ci*
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

let s:quotes = "'`".'"'

function! CIpunct(chars)

   let s:save_cursor  = getpos('.')
   let stop_line      =   line('.')
   let my_changedtick = b:changedtick

   let over = 0
   if match(getline('.'), '['.a:chars.']', col('.') - 1) == col('.') - 1
      let char = getline('.')[col('.') - 1]
      if strlen(substitute(getline('.'), '[^'.char.']', '', 'g')) > 1
         echo 'Under cursor'
         if s:quotes =~ char
            execute 'normal! di'.char
         else
            " execute 'normal! vt'.char.'<cr>'
         endif
         let over = 1
      endif
   endif

   if !over

      function! s:CIo(lchars)
         if search ('['.a:lchars.']', 'b', line('.'))
            let lchar = getline('.')[col('.') - 1]
            if search (lchar, '', line('.'))
               echo 'Same line: between chars'
               call setpos('.', s:save_cursor)
               if s:quotes =~ lchar
                  execute 'normal! di'.lchar
               else
                  " execute 'normal! T'.lchar.'vt'.lchar.'<cr>'
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
               echo 'After cursor (second half of buffer)'
               if s:quotes =~ char
                  execute 'normal! di'.char
               else
                  " return 'execute normal! lvt'.char.'<cr>'
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
                  echo 'After cursor (first half of buffer)'
                  if s:quotes =~ char
                     execute 'normal! di'.char
                  else
                     " execute 'normal! dt'.char.'h'
                  endif
                  break
               endif
            endwhile
         endif
      endif

   endif

   if my_changedtick == b:changedtick
      echohl  ErrorMsg
      echo   'Nothing to do'
      echohl  None
      call setpos('.', s:save_cursor)
   else
      startinsert
   endif

endfunction

nmap <silent> <plug>PunctCIpunct :<c-u>call CIpunct('"'."'`")<cr>
nmap       "" <plug>PunctCIpunct

" for char in [ '_', '.', ':', ',', ';', '<bar>', '/', '<bslash>', '*', '+' ]
"    " execute 'xnoremap i' . char . ' :<c-u>silent!normal!T' . char . 'vt' . char . '<cr>'
"    execute 'onoremap i'.char." :<c-u>call CIpunct('".char."')<cr>"
"    " execute 'xnoremap a' . char . ' :<c-u>silent!normal!F' . char . 'vf' . char . '<cr>'
"    " execute 'onoremap a' . char . ' :normal va' . char . '<cr>'
" endfor

let &cpoptions = s:savecpo
unlet s:savecpo
