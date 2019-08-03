" Get a filename from a list of lexical items.
" Returns a list with
"   - The filename, if it's a readable file (or '' if not)
"   - An error string, if it can't be found (or '' if no error)

function! codeGet#GetFilename(items)
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

function! codeGet#InsertFile(filename)
    let ftype = codeGet#Filetype(a:filename)

    " Insert the lines in reverse order, so each append goes
    " on the line below the current one
 
    call append(line('.'), ['```'])
    call append(line('.'), readfile(a:filename))
    call append(line('.'), ['```' . ftype])
endfunction


" Get a filetype from a filename, or empty string.
" Adapated from
" https://vi.stackexchange.com/questions/9962/get-filetype-by-extension-or-filename-in-vimscript

function! codeGet#Filetype(filename)
    let ext = fnamemodify(a:filename, ':e')
    let ftlines = split(execute('autocmd filetypedetect'), "\n")
    let matching_lines = filter(ftlines, 'v:val =~ "\*\.".ext')
    let matching = uniq(sort(matching_lines))

    if len(matching) == 1 && matching[0]  =~# 'setf'
        return matchstr(matching[0], '\vsetf\S*\s+\zs\k+')
    endif
    return ''
endfunction


