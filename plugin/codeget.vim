" Get code snippets - main entry point

if exists('g:code_get_enabled')
    finish
endif

" Preferred window width

if !exists('g:code_get_preferred_window_width')
    let g:code_get_preferred_window_width = 80
endif

nnoremap <leader>cg :call codeGet#GetSnippet()<cr>
nnoremap <leader>co :call codeGet#OpenBuffer()<cr>

vnoremap <leader>cp :<c-u>call codeGet#PutSnippet()<cr>

let g:code_get_enabled = 1

