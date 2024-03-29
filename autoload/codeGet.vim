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
    call codeGet#InsertLines(ftype, readfile(a:filename))
endfunction


" Insert lines below the current line.
" Inputs:
"   - Filetype (for appending after the ``` header)
"   - Lines to be pasted.

function! codeGet#InsertLines(ftype, lines)
    " Insert the lines in reverse order, so each append goes
    " on the line below the current one
 
    call append(line('.'), ['```'])
    call append(line('.'), a:lines)
    call append(line('.'), ['```' . a:ftype])
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
            " Switch to existing window for the file, but make sure
            " we save this as the destination window to return to.

            let g:code_get_destination_window = win_getid()
            call win_gotoid(win_num)
            return
        endif
    endif

    " We couldn't find the buffer or window, so open a new window
    " aiming for the preferred window width, but make sure
    " we save this as the desination window to return to.

    let g:code_get_destination_window = win_getid()
    let split_command = codeGet#GetSplitCommand()

    execute split_command . ' ' . filename

endfunction


" How should we split the window? "vsplit" or "split". We aim for whichever
" will leave us closest to the preferred window width.

function! codeGet#GetSplitCommand()
    let width = winwidth(0)
    let pref = g:code_get_preferred_window_width

    let h_score = pref - width
    if h_score < 0
        let h_score = -2 * h_score
    endif

    let v_score = pref - (width / 2)
    if v_score < 0
        let v_score = -2 * v_score
    endif

    if v_score < h_score
        return 'vsplit'
    else
        return 'split'
endfunction


" Put a snippet back into the original design doc.

function! codeGet#PutSnippet()
    " Get the snippet (while preserving the register we use)
    " and its filetype

    let saved_register = @"
    normal! '<y'>
    let snippet = split(@", "\n")
    let @" = saved_register

    let ftype = &filetype

    " Switch to the destination window (if possible) and paste the snippet

    if !exists('g:code_get_destination_window')
        echom 'No destination window to paste into'
        return
    endif
    
    let switch_successful = win_gotoid(g:code_get_destination_window)
    if !switch_successful
        echom 'Destination window has disappeared'
        return
    endif

    call codeGet#InsertLines(ftype, snippet)
endfunction

