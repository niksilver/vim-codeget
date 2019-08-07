" Get a code snippet and insert it into the file

function! codeGet#GetSnippet()
    " Get the filename on the line, or error

    let [filename, error_string] = codeGet#ParseLineForFilename()
    if error_string !=# ''
        echom error_string
        return
    endif

    " Insert the contents of the file

    call codeGet#InsertFile(filename)

endfunction


" Parse the line and return the function needed, or an error

function! codeGet#ParseLineForFilename()
    " Get the contents of the current line and split into words

    let this_line = getline('.')
    let items = codeGet#parse#ParseIntoItems(this_line)

    " Get the filename and possible error

    let [filename, error_string] = codeGet#GetFilename(items)

    return [filename, error_string]
endfunction


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


" Open a buffer with the given file.

function! codeGet#OpenBuffer()
    " Get the filename on the line, or error

    let [filename, error_string] = codeGet#ParseLineForFilename()
    if error_string !=# ''
        echom error_string
        return
    endif

    " See if there is already a buffer for the file,
    " and a window for that buffer.
    " If so, switch to it.

    let file_buf_num = bufnr(filename)
    if file_buf_num !=# -1
        let win_num = bufwinid(file_buf_num)

        if win_num !=# -1
            " Switch to existing window for the file

            call win_gotoid(win_num)
            return
        endif
    endif

    " We couldn't find the buffer or window, so open a new window

    execute "split " . filename

endfunction

