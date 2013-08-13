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

   let s:op      = strpart(a:op, 0, 1) == 'c' ? 'd' : strpart(a:op, 0, 1)
   let s:oprange = strpart(a:op, 1)

   let s:save_cursor  = getpos('.')
   let my_changedtick = b:changedtick

   let s:success = 0
   let over = 0
   let s:single_char = strlen(a:chars) == 1 ? 1 : 0
   let s:pattern = s:single_char ? escape(a:chars, '^$~.') : '['.a:chars.']'
   " Match under cursor {{{1
   if match(getline('.'), s:pattern, col('.') - 1) == col('.') - 1
      let char = s:single_char ? a:chars : getline('.')[col('.') - 1]
      if strlen(substitute(getline('.'), '[^'.char.']', '', 'g')) > 1
         let s:success = 1
         if stridx(s:quotes, char) != -1
            execute 'normal! di'.char
         else
            if search (escape(char, '^$~.'), 'n', line('.'))
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
      " @  X   @ cursor between a pair on the current line {{{1
      function! s:CIo(lchars)
         let pattern = s:single_char ? escape(a:lchars, '^$~.') : '['.a:lchars.']'
         if search (pattern, 'b', line('.'))
            let lchar = s:single_char ? a:lchars : getline('.')[col('.') - 1]
            if search (escape(lchar, '^$~.'), 'n', line('.'))
               let s:success = 1
               if stridx(s:quotes, lchar) != -1
                  call setpos('.', s:save_cursor)
                  execute 'normal! di'.lchar
               else
                  if s:oprange == 'a'
                     execute 'normal!  '.s:op.'f'.lchar
                  else
                     execute 'normal! l'.s:op.'t'.lchar
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
      if !s:single_char
         while strpart(char, 0, 1) == 0 && strpart(char, 1) != ''
            let chars = substitute(chars, strpart(char, 1), '', 'g')
            let char  = s:CIo(chars)
         endwhile
      endif

      " X  @   @ ↓ look for a match after the cursor, also past the current line {{{1
      " Quotes: choose the closest one to the left, forming a pair
      if strpart(char, 0, 1) == 0
         call setpos('.', s:save_cursor)
         let found = 0
         while search (s:pattern, '', line('w$'))
            let char = s:single_char ? a:chars : getline('.')[col('.') - 1]
            if strlen(substitute(getline('.'), '[^'.char.']', '', 'g')) > 1
               let s:success = 1
               if stridx(s:quotes, char) != -1
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
         " X  @   @ ↻ look for a match after the cursor past the EOF {{{1
         if found == 0
            goto
            while search (s:pattern, '', s:save_cursor[1])
               let char = s:single_char ? a:chars : getline('.')[col('.') - 1]
               if strlen(substitute(getline('.'), '[^'.char.']', '', 'g')) > 1
                  let s:success = 1
                  if stridx(s:quotes, char) != -1
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
   endif " }}}1

   if s:success == 1 && strpart(a:op, 0, 1) == 'c'
      startinsert
   elseif s:success == 0 || s:success == 1 && my_changedtick == b:changedtick
      if s:op != 'y'
         echohl ErrorMsg | echo 'Nothing to do' | echohl None
      endif
      call setpos('.', s:save_cursor)
   endif

endfunction

nmap <silent> <plug>PunctCIpunct :<c-u>call CIpunct("'`".'"', 'ci')<cr>
nmap       "" <plug>PunctCIpunct

for p in ['!','$','%','^','&','*','_','-','+','=',':',';','@','~','#','\|','<bslash>',',','.','?','/']
   execute 'nnoremap <silent> ci'.p." :<c-u>call CIpunct('".p."'".", 'ci')<cr>"
   execute 'nnoremap <silent> di'.p." :<c-u>call CIpunct('".p."'".", 'di')<cr>"
   execute 'nnoremap <silent> yi'.p." :<c-u>call CIpunct('".p."'".", 'yi')<cr>"
   " execute 'xnoremap <silent>  i'.p." :<c-u>call CIpunct('".p."'".", 'vi')<cr>"
   execute 'nnoremap <silent> ca'.p." :<c-u>call CIpunct('".p."'".", 'ca')<cr>"
   execute 'nnoremap <silent> da'.p." :<c-u>call CIpunct('".p."'".", 'da')<cr>"
   execute 'nnoremap <silent> ya'.p." :<c-u>call CIpunct('".p."'".", 'ya')<cr>"
   " execute 'xnoremap <silent>  a'.p." :<c-u>call CIpunct('".p."'".", 'va')<cr>"
endfor

let &cpoptions = s:savecpo
unlet s:savecpo
