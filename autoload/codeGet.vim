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

    " See if there is already a buffer for the file

    call codeGet#BufferForFile(filename)

    " Either switch to the existing buffer or open a new one

endfunction

" Get the buffer for a given file, if any.

function! codeGet#BufferForFile(filename)
    let exp_filename = expand(a:filename . ':p')
    echom "Looking for filename '" . exp_filename . "'"

    " Get the output of :buffers as a list of strings (one per output line)

    let buffers_as_lines = split(execute(':buffers'), "\n")

    " Find the buffer number for the file. Format of buffer lines is:
    " <whitespace> buffer_number <symbols & wspace> "buffer name" <other_stuff>

    for buffer_line in buffers_as_lines
        let buffer_num = matchlist(buffer_line, '\v([0-9]+)')[1]
        let exp_buffer_name = expand('#' . buffer_num . ':p')
        echom "Discovered buffer '" . exp_buffer_name . "'"
        if exp_filename ==# exp_buffer_name
            echom "Found a buffer for '" . exp_filename . "'"
            return 'Dummy value'
        endif
    endfor

    echom "Didn't find buffer for file '" . exp_filename . "'"
    return 'Dummy failure'
endfunction!


