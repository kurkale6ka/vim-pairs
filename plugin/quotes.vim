" New punctuation text objects:
"
"    ci/, di;, yi*, vi@ ...
"    ca/, da;, ya*, va@ ...
"
"    ciq (~ "") changes content inside ANY kind of quotes
"    vaq, yiq ...
"
"    ci<space>, da<space> ... modify ANY punctuation object
"
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

function! CIpunct(chars, oprange)

   let s:oprange      = a:oprange
   let s:save_cursor  = getpos('.')

   let s:success = 0
   let over = 0
   let s:single_char = strlen(a:chars) == 1 ? 1 : 0
   let s:pattern = s:single_char ? escape(a:chars, '^.~$') : '['.a:chars.']'

   " Match under cursor... {{{1
   if match(getline('.'), s:pattern, col('.') - 1) == col('.') - 1
      let char = s:single_char ? a:chars : getline('.')[col('.') - 1]
      if strlen(substitute(getline('.'), '[^'.char.']', '', 'g')) > 1
         let s:success = 1
         " ...forming a pair to the right
         if search (escape(char, '^.~$'), 'n', line('.'))
            if s:oprange == 'a'
               execute 'normal!  vf'.char
            else
               execute 'normal! lvt'.char
            endif
         " ...or to the left
         else
            if s:oprange == 'a'
               execute 'normal!  vF'.char
            else
               execute 'normal! hvT'.char
            endif
         endif
         let over = 1
      endif
   endif

   if !over
      " @  X   @ cursor between a pair on the current line {{{1
      function! s:CIo(lchars)
         let pattern = s:single_char ? escape(a:lchars, '^.~$') : '['.a:lchars.']'
         if search (pattern, 'b', line('.'))
            let lchar = s:single_char ? a:lchars : getline('.')[col('.') - 1]
            if search (escape(lchar, '^.~$'), 'n', line('.'))
               let s:success = 1
               if s:oprange == 'a'
                  execute 'normal!  vf'.lchar
               else
                  execute 'normal! lvt'.lchar
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
               if s:oprange == 'a'
                  execute 'normal!  vf'.char
               else
                  execute 'normal! lvt'.char
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
                  if s:oprange == 'a'
                     execute 'normal!  vf'.char
                  else
                     execute 'normal! lvt'.char
                  endif
                  break
               endif
            endwhile
         endif
      endif
   endif " }}}1

   if s:success == 0
      call setpos('.', s:save_cursor)
      echohl ErrorMsg | echo 'Nothing to do' | echohl None
   " ex: ci@ when X @@
   " my_changedtick == ... can't happen because CIpunct doesn't do any changes !
   " elseif my_changedtick == b:changedtick && v:operator != 'y' || mode() != 'v'
      " echohl ErrorMsg | echo 'Nothing to do' | echohl None
   endif

endfunction

for p in ['!','$','%','^','&','*','_','-','+','=',':',';','@','~','#','<bar>','<bslash>',',','.','?','/']
   execute 'onoremap <silent> i'.p." :<c-u>call CIpunct('".p."'".", 'i')<cr>"
   execute 'onoremap <silent> a'.p." :<c-u>call CIpunct('".p."'".", 'a')<cr>"
   execute 'xnoremap <silent> i'.p." :<c-u>call CIpunct('".p."'".", 'i')<cr>"
   execute 'xnoremap <silent> a'.p." :<c-u>call CIpunct('".p."'".", 'a')<cr>"
endfor

onoremap <silent> iq :<c-u>call CIpunct("'`".'"', 'i')<cr>
onoremap <silent> aq :<c-u>call CIpunct("'`".'"', 'a')<cr>
xnoremap <silent> iq :<c-u>call CIpunct("'`".'"', 'i')<cr>
xnoremap <silent> aq :<c-u>call CIpunct("'`".'"', 'a')<cr>

" [-`!"$%^&*_+=:;@~#|\,.?/'] am I including < for instance, from <bar> Vs | ?
onoremap <silent> i<space> :<c-u>call CIpunct('-`!"$%^&*_+=:;@~#<bar><bslash>,.?/'."'", 'i')<cr>
onoremap <silent> a<space> :<c-u>call CIpunct('-`!"$%^&*_+=:;@~#<bar><bslash>,.?/'."'", 'a')<cr>
xnoremap <silent> i<space> :<c-u>call CIpunct('-`!"$%^&*_+=:;@~#<bar><bslash>,.?/'."'", 'i')<cr>
xnoremap <silent> a<space> :<c-u>call CIpunct('-`!"$%^&*_+=:;@~#<bar><bslash>,.?/'."'", 'a')<cr>

nmap <silent> <plug>PunctCIpunct :normal ciq<cr>
nmap       "" <plug>PunctCIpuncta

let &cpoptions = s:savecpo
unlet s:savecpo
