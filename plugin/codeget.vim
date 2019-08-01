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
        " Match a sequence of non-space characters, if any
        let [match, rest] = s:MatchItems(rest, '\v^\S+')
        let items += [match]
        echom 'Rest is "' . rest '"'
    endwhile

    return items
endfunction

" Match some text to a pattern. Return the matching string and the
" rest of the text after the pattern and any spaces.
" The pattern is assumed to start with '^....'.

function! s:MatchItems(text, pattern)
    let [match, start, end] = matchstrpos(a:text, a:pattern)
    let rest = a:text[end:]
    let rest = substitute(rest, '\v\s+', '', '')
    return [match, rest]
endfunction

let g:code_get_enabled = 1

