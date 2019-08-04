" Get code snippets - main entry point

if exists('g:code_get_enabled')
    finish
endif

nnoremap <buffer> <localleader>cg
    \ :call codeGet#CodeGetGetSnippet()<cr>

let g:code_get_enabled = 1

