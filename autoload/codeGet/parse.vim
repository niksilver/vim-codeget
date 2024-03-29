" Parse a line by breaking it into a list of items.
" An item is any of these things, in order
"   - An = sign
"   - A double quoted string
"   - A single quoted string
"   - A sequence of non-space characters (excluding =)

function! codeGet#parse#ParseIntoItems(line)
    let items = []
    let rest = a:line

    while rest !=# ''
        " Match an = sign
        let [found, items, rest] =
            \ codeGet#parse#MatchItems(rest, '\v^\=', items, 0)
        if found
            continue
        endif

        " Match a double quoted string
        let [found, items, rest] =
            \ codeGet#parse#MatchItems(rest, '\v^"[^"]*"', items, 1)
        if found
            continue
        endif

        " Match a single quoted string
        let [found, items, rest] =
            \ codeGet#parse#MatchItems(rest, '\v^''[^'']*''', items, 1)
        if found
            continue
        endif

        " Match a sequence of non-space, non-= characters, if any
        let [found, items, rest] =
            \ codeGet#parse#MatchItems(rest, '\v^[^\t \=]+', items, 0)
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

function! codeGet#parse#MatchItems(text, pattern, items, topNTail)
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


