" Get code snippets - main entry point

if exists('g:code_get_enabled')
    finish
endif

nnoremap <buffer> <localleader>cg
    \ :call <SID>CodeGetGetSnippet()<cr>

" Get a code snippet and insert it into the file

function! s:CodeGetGetSnippet()
    " Get the contents of the current line and split into words

    let this_line = getline('.')
    let items = codeGet#parse#ParseIntoItems(this_line)

    " Get the filename

    let [filename, error_string] = codeGet#GetFilename(items)
    if error_string !=# ''
        echom error_string
        return
    endif

    " Insert the contents of the file

    call codeGet#InsertFile(filename)

endfunction

let g:code_get_enabled = 1

