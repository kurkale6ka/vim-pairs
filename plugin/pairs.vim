" New punctuation text objects:
"
"    ci/, di;, yi*, vi@ ...
"    ca/, da;, ya*, va@ ...
"
"    ciq (or "") changes content inside ANY kind of quotes
"    vaq, yiq ...
"
"    ci<space>, da<space> ... modify ANY punctuation object
"
" Author: Dimitar Dimitrov (mitkofr@yahoo.fr), kurkale6ka
"
" Latest version at:
" https://github.com/kurkale6ka/vim-pairs
"
" TODO: Fix @@ and stopinsert if nothing to do after cix !!!

if exists('g:loaded_ptext_objects') || &compatible || v:version < 700
   if &compatible && &verbose
      echo "Punctuation Text Objects is not designed to work in compatible mode."
   elseif v:version < 700
      echo "Punctuation Text Objects needs Vim 7.0 or above to work correctly."
   endif
   finish
endif

let g:loaded_ptext_objects = 1

let s:savecpo   = &cpoptions
let s:savemagic = &magic
set cpoptions&vim magic

function! Process_ppair(chars, oprange)

   let s:save_cursor = getpos('.')
   let s:chars       = a:chars
   let s:oprange     = a:oprange
   let s:success     = 0
   let s:single_char = strlen(s:chars) == 1 ? 1 : 0
   let s:pattern     = s:single_char ? escape(s:chars, '^.~$') : '['.s:chars.']'

   " Match under cursor... {{{1
   if match(getline('.'), s:pattern, col('.') - 1) == col('.') - 1
      let char = s:single_char ? s:chars : getline('.')[col('.') - 1]
      if strlen(substitute(getline('.'), '[^'.char.']', '', 'g')) > 1
         let s:success = 1
         " ...forming a pair to the right
         let [l, c] = searchpos (escape(char, '^.~$'), 'n', line('.'))
         if c != 0
            if s:oprange == 'a'
               execute 'normal!  vf'.char
            " @@ case
            elseif c > s:save_cursor[2] + 1
               execute 'normal! lvt'.char
            endif
         " ...or to the left
         else
            if s:oprange == 'a'
               execute 'normal! vF'.char
            else
               let [l, c] = searchpos (escape(char, '^.~$'), 'nb', line('.'))
               if c < s:save_cursor[2] - 1
                  execute 'normal! hvT'.char
               endif
            endif
         endif
      endif
   endif

   if !s:success
      " @  X   @ cursor between a pair on the current line {{{1
      function! s:Process_ippair(lchars)
         let pattern = s:single_char ? escape(a:lchars, '^.~$') : '['.a:lchars.']'
         " Look for first match to the left...
         if search (pattern, 'b', line('.'))
            let lchar = s:single_char ? a:lchars : getline('.')[col('.') - 1]
            " ...and check for a closing one to the right
            if search (escape(lchar, '^.~$'), 'n', line('.'))
               let s:success = 1
               if s:oprange == 'a'
                  execute 'normal!  vf'.lchar
               else
                  execute 'normal! lvt'.lchar
               endif
            endif
            return lchar
         endif
      endfunction

      let chars = s:chars
      let char  = s:Process_ippair(chars)
      if !s:single_char
         while !s:success && char != ''
            let chars = substitute(chars, char, '', 'g')
            let char  = s:Process_ippair(chars)
         endwhile
      endif

      if !s:success
         " X  @   @ cursor before a pair {{{1
         function! s:Process_oppair(stop_line)
            while search (s:pattern, '', a:stop_line)
               let char = s:single_char ? s:chars : getline('.')[col('.') - 1]
               if strlen(substitute(getline('.'), '[^'.char.']', '', 'g')) > 1
                  let s:success = 1
                  if s:oprange == 'a'
                     execute 'normal! vf'.char
                  else
                     " @@ case
                     let [l, c] = searchpos (escape(char, '^.~$'), 'n', line('.'))
                     if c > col('.') + 1
                        execute 'normal! lvt'.char
                     else
                        " This is a pseudo solution as ideally I wanna cancel
                        " the omap which the return below fails to do (l.139: same)
                        call setpos('.', s:save_cursor)
                        " return "\<esc>"
                     endif
                  endif
                  break
               endif
            endwhile
         endfunction

         call setpos('.', s:save_cursor)
         " ↓ look for a match after the cursor, also past the current line
         call s:Process_oppair(line('w$'))
         if !s:success
            goto
            " ↻ match after the cursor past the EOF
            call s:Process_oppair(s:save_cursor[1])
         endif
      endif
   endif " }}}1

   if !s:success
      call setpos('.', s:save_cursor)
      echohl ErrorMsg | echo 'Nothing to do' | echohl None
      " return "\<esc>"
   " ex: ci@ when X @@
   " my_changedtick == ... can't happen because Process_ppair doesn't do any changes !
   " elseif my_changedtick == b:changedtick && v:operator != 'y' || mode() != 'v'
      " echohl ErrorMsg | echo 'Nothing to do' | echohl None
   endif

endfunction

for p in ['!','$','%','^','&','*','_','-','+','=',':',';','@','~','#','<bar>','<bslash>',',','.','?','/']
   execute 'onoremap <silent> i'.p." :<c-u>call Process_ppair('".p."'".", 'i')<cr>"
   execute 'onoremap <silent> a'.p." :<c-u>call Process_ppair('".p."'".", 'a')<cr>"
   execute 'xnoremap <silent> i'.p." :<c-u>call Process_ppair('".p."'".", 'i')<cr>"
   execute 'xnoremap <silent> a'.p." :<c-u>call Process_ppair('".p."'".", 'a')<cr>"
endfor

onoremap <silent> <plug>PunctPairsIQuotes :<c-u>call Process_ppair("'`".'"', 'i')<cr>
onoremap <silent> <plug>PunctPairsAQuotes :<c-u>call Process_ppair("'`".'"', 'a')<cr>
xnoremap <silent> <plug>PunctPairsIQuotes :<c-u>call Process_ppair("'`".'"', 'i')<cr>
xnoremap <silent> <plug>PunctPairsAQuotes :<c-u>call Process_ppair("'`".'"', 'a')<cr>
omap     <silent> iq                      <plug>PunctPairsIQuotes
omap     <silent> aq                      <plug>PunctPairsAQuotes
xmap     <silent> iq                      <plug>PunctPairsIQuotes
xmap     <silent> aq                      <plug>PunctPairsAQuotes

" Add (){}[]<> ? Would be awkward for cases like: ("...")
onoremap <silent> <plug>PunctPairsIAll :<c-u>call Process_ppair('-`!"$%^&*_+=:;@~#<bar><bslash>,.?/'."'", 'i')<cr>
onoremap <silent> <plug>PunctPairsAAll :<c-u>call Process_ppair('-`!"$%^&*_+=:;@~#<bar><bslash>,.?/'."'", 'a')<cr>
xnoremap <silent> <plug>PunctPairsIAll :<c-u>call Process_ppair('-`!"$%^&*_+=:;@~#<bar><bslash>,.?/'."'", 'i')<cr>
xnoremap <silent> <plug>PunctPairsAAll :<c-u>call Process_ppair('-`!"$%^&*_+=:;@~#<bar><bslash>,.?/'."'", 'a')<cr>
omap     <silent> i<space>             <plug>PunctPairsIAll
omap     <silent> a<space>             <plug>PunctPairsAAll
xmap     <silent> i<space>             <plug>PunctPairsIAll
xmap     <silent> a<space>             <plug>PunctPairsAAll

nnoremap <silent> <plug>PunctPairsQuotes :normal ciq<cr>
nmap     <silent> ""                     <plug>PunctPairsQuotesa

let &cpoptions = s:savecpo
let &magic     = s:savemagic
unlet s:savecpo s:savemagic
