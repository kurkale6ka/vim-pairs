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

for p in ['!','$','%','^','&','*','_','-','+','=',':',';','@','~','#','<bar>','<bslash>',',','.','?','/']
   execute 'onoremap <silent> i'.p." :<c-u>call pairs#process('".p."'".", 'i')<cr>"
   execute 'onoremap <silent> a'.p." :<c-u>call pairs#process('".p."'".", 'a')<cr>"
   execute 'xnoremap <silent> i'.p." :<c-u>call pairs#process('".p."'".", 'i')<cr>"
   execute 'xnoremap <silent> a'.p." :<c-u>call pairs#process('".p."'".", 'a')<cr>"
endfor

onoremap <silent> <plug>PunctPairsIQuotes :<c-u>call pairs#process("'`".'"', 'i')<cr>
onoremap <silent> <plug>PunctPairsAQuotes :<c-u>call pairs#process("'`".'"', 'a')<cr>
xnoremap <silent> <plug>PunctPairsIQuotes :<c-u>call pairs#process("'`".'"', 'i')<cr>
xnoremap <silent> <plug>PunctPairsAQuotes :<c-u>call pairs#process("'`".'"', 'a')<cr>
omap     <silent> iq                      <plug>PunctPairsIQuotes
omap     <silent> aq                      <plug>PunctPairsAQuotes
xmap     <silent> iq                      <plug>PunctPairsIQuotes
xmap     <silent> aq                      <plug>PunctPairsAQuotes

" Add (){}[]<> ? Would be awkward for cases like: ("...")
onoremap <silent> <plug>PunctPairsIAll :<c-u>call pairs#process('-`!"$%^&*_+=:;@~#<bar><bslash>,.?/'."'", 'i')<cr>
onoremap <silent> <plug>PunctPairsAAll :<c-u>call pairs#process('-`!"$%^&*_+=:;@~#<bar><bslash>,.?/'."'", 'a')<cr>
xnoremap <silent> <plug>PunctPairsIAll :<c-u>call pairs#process('-`!"$%^&*_+=:;@~#<bar><bslash>,.?/'."'", 'i')<cr>
xnoremap <silent> <plug>PunctPairsAAll :<c-u>call pairs#process('-`!"$%^&*_+=:;@~#<bar><bslash>,.?/'."'", 'a')<cr>
omap     <silent> i<space>             <plug>PunctPairsIAll
omap     <silent> a<space>             <plug>PunctPairsAAll
xmap     <silent> i<space>             <plug>PunctPairsIAll
xmap     <silent> a<space>             <plug>PunctPairsAAll

nnoremap <silent> <plug>PunctPairsQuotes :normal ciq<cr>
nmap     <silent> ""                     <plug>PunctPairsQuotesa

let &cpoptions = s:savecpo
let &magic     = s:savemagic
unlet s:savecpo s:savemagic
