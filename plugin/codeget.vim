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
    echom 'This line is ''' . this_line . ''''
    let items = s:ParseIntoItems(this_line)
    echom 'Items are ' . string(items)

endfunction

" Parse a line by breaking it into a list of items.
" An item is any of these things
"   - A sequence of non-space characters
"   - A double quoted string
"   - A single quoted string

function! s:ParseIntoItems(line)
    let items = []
    let rest = a:line

    while rest !=# ''
        " Check for a sequence of non-space characters
        let [match, start, end] = matchstrpos(rest, '\v^\S+')
        let items += [match]
        let rest = rest[end:]
        let rest = substitute(rest, '\v\s+', '', '')
        echom "Match = '" . match . "'"
        echom "Start = '" . start . "'"
        echom "End = '" . end . "'"
        echom "Rest = '" . rest . "'"
    endwhile

    return items
endfunction

let g:code_get_enabled = 1

