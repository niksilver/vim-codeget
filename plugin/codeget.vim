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

    " Get the filename

    let [filename, error_string] = s:GetFilename(items)
    if error_string !=# ''
        echom error_string
        return
    endif

    " Insert the contents of the file

    call s:InsertFile(filename)

endfunction

" Parse a line by breaking it into a list of items.
" An item is any of these things, in order
"   - An = sign
"   - A double quoted string
"   - A single quoted string
"   - A sequence of non-space characters (excluding =)

function! s:ParseIntoItems(line)
    let items = []
    let rest = a:line

    while rest !=# ''
        " Match an = sign
        let [found, items, rest] = s:MatchItems(rest, '\v^\=', items, 0)
        if found
            continue
        endif

        " Match a double quoted string
        let [found, items, rest] = s:MatchItems(rest, '\v^"[^"]*"', items, 1)
        if found
            continue
        endif

        " Match a single quoted string
        let [found, items, rest] = s:MatchItems(rest, '\v^''[^'']*''', items, 1)
        if found
            continue
        endif

        " Match a sequence of non-space, non-= characters, if any
        let [found, items, rest] = s:MatchItems(rest, '\v^[^\t \=]+', items, 0)
        if found
            continue
        endif
    endwhile

    return items
endfunction

" Match some text to a pattern. Return the matching string and the
" rest of the text after the pattern and any spaces.
" Inputs:
"   - The text to match
"   - The pattern, which is assumed to start with '^....'.
"   - A list of items so far
"   - Boolean top 'n' tail. If true, first and last characters are
"     stripped from the match.
" Outputs:
"   - Boolean flag, true if successfully matched
"   - An updated list of items, with the new one (if any) on the end
"   - The rest of text, after removing the item and spaces

function! s:MatchItems(text, pattern, items, topNTail)
    let [match, start, end] = matchstrpos(a:text, a:pattern)
    if start >= 0
        let rest = a:text[end:]
        let rest = substitute(rest, '\v^\s+', '', '')
        if a:topNTail
            let match = substitute(match, '\v^.', '', '')
            let match = substitute(match, '\v.$', '', '')
        endif
        let new_items = a:items + [match]
        return [1, new_items, rest]
    else
        return [0, a:items, a:text]
    endif
endfunction

" Get a filename from a list of lexical items.
" Returns a list with
"   - The filename, if it's a readable file (or '' if not)
"   - An error string, if it can't be found (or '' if no error)

function! s:GetFilename(items)
    if len(a:items) ==# 0
        return ['', 'No filename given']
    endif

    let filename = a:items[0]
    let readable = filereadable(filename)
    if readable
        return [filename, '']
    else
        return ['', 'Can''t read file ''' . filename . '''']
    endif

endfunction

" Insert file below the current line. File is assumed to be readable

function! s:InsertFile(filename)
    let ftype = s:Filetype(a:filename)

    " Insert the lines in reverse order, so each append goes
    " on the line below the current one
 
    call append(line('.'), ['```'])
    call append(line('.'), readfile(a:filename))
    call append(line('.'), ['```' . ftype])
endfunction

" Get a filetype from a filename, or empty string.
" Adapated from
" https://vi.stackexchange.com/questions/9962/get-filetype-by-extension-or-filename-in-vimscript

function! s:Filetype(filename)
    let ext = fnamemodify(a:filename, ':e')
    let ftlines = split(execute('autocmd filetypedetect'), "\n")
    let matching_lines = filter(ftlines, 'v:val =~ "\*\.".ext')
    let matching = uniq(sort(matching_lines))

    if len(matching) == 1 && matching[0]  =~# 'setf'
        return matchstr(matching[0], '\vsetf\S*\s+\zs\k+')
    endif
    return ''
endfunction

let g:code_get_enabled = 1

