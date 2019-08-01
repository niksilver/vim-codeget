" Get code snippets - main entry point

if exists('g:code_get_enabled')
    finish
endif

nnoremap <buffer> <localleader>cg
    \ :call <SID>CodeGetGetSnippet()<cr>

function! s:CodeGetGetSnippet()
    echom "Getting snippet"
endfunction

let g:code_get_enabled = 1

