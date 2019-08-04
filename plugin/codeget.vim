" Get code snippets - main entry point

if exists('g:code_get_enabled')
    finish
endif

nnoremap <buffer> <localleader>cg :call codeGet#GetSnippet()<cr>
nnoremap <buffer> <localleader>co :call codeGet#OpenBuffer()<cr>

let g:code_get_enabled = 1

