" File:        todo.txt.vim
" Description: Todo.txt filetype detection
" Author:      Leandro Freitas <freitass@gmail.com>
" License:     Vim license
" Website:     http://github.com/freitass/todo.txt-vim
" Version:     0.4

" Export Context Dictionary for unit testing {{{1
function! s:get_SID()
    return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

function! todo#txt#__context__()
    return { 'sid': s:SID, 'scope': s: }
endfunction

" Functions {{{1
function! s:remove_priority()
    :s/^(\w)\s\+//ge
endfunction

function! s:get_current_date()
    return strftime('%Y-%m-%d')
endfunction

function! todo#txt#prepend_date()
    execute 'normal! I' . s:get_current_date() . ' '
endfunction

function! todo#txt#replace_date()
    let current_line = getline('.')
    if (current_line =~ '^\(([a-zA-Z]) \)\?\d\{2,4\}-\d\{2\}-\d\{2\} ') &&
                \ exists('g:todo_existing_date') && g:todo_existing_date == 'n'
        return
    endif
    execute 's/^\(([a-zA-Z]) \)\?\(\d\{2,4\}-\d\{2\}-\d\{2\} \)\?/\1' . s:get_current_date() . ' /'
endfunction

function! todo#txt#mark_as_done()
    call s:remove_priority()
    call todo#txt#prepend_date()
    execute 'normal! Ix '
endfunction

function! todo#txt#mark_all_as_done()
    :g!/^x /:call todo#txt#mark_as_done()
endfunction

function! s:append_to_file(file, lines)
    let l:lines = []

    " Place existing tasks in done.txt at the beggining of the list.
    if filereadable(a:file)
        call extend(l:lines, readfile(a:file))
    endif

    " Append new completed tasks to the list.
    call extend(l:lines, a:lines)

    " Write to file.
    call writefile(l:lines, a:file)
endfunction

function! todo#txt#remove_completed()
    " Check if we can write to done.txt before proceeding.

    let l:target_dir = expand('%:p:h')
    let l:todo_file = expand('%:p')
    " Check for user-defined g:todo_done_filename
    if exists("g:todo_done_filename")
        let l:todo_done_filename = g:todo_done_filename
    elseif expand('%:t') == 'Todo.txt'
        let l:todo_done_filename = 'Done.txt'
    else
        let l:todo_done_filename = 'done.txt'
    endif
    let l:done_file = substitute(substitute(l:todo_file, 'todo.txt$', l:todo_done_filename, ''), 'Todo.txt$', l:todo_done_filename, '')
    if !filewritable(l:done_file) && !filewritable(l:target_dir)
        echoerr "Can't write to file '" . l:todo_done_filename . "'"
        return
    endif

    let l:completed = []
    :g/^x /call add(l:completed, getline(line(".")))|d
    call s:append_to_file(l:done_file, l:completed)
endfunction

function! todo#txt#sort_by_context() range
    execute a:firstline . "," . a:lastline . "sort /\\(^\\| \\)\\zs@[^[:blank:]]\\+/ r"
endfunction

function! todo#txt#sort_by_project() range
    execute a:firstline . "," . a:lastline . "sort /\\(^\\| \\)\\zs+[^[:blank:]]\\+/ r"
endfunction

function! todo#txt#sort_by_date() range
    let l:date_regex = "\\d\\{2,4\\}-\\d\\{2\\}-\\d\\{2\\}"
    execute a:firstline . "," . a:lastline . "sort /" . l:date_regex . "/ r"
    execute a:firstline . "," . a:lastline . "g!/" . l:date_regex . "/m" . a:lastline
endfunction

function! todo#txt#sort_by_due_date() range
    let l:date_regex = "due:\\d\\{2,4\\}-\\d\\{2\\}-\\d\\{2\\}"
    execute a:firstline . "," . a:lastline . "sort /" . l:date_regex . "/ r"
    execute a:firstline . "," . a:lastline . "g!/" . l:date_regex . "/m" . a:lastline
endfunction

" Increment and Decrement The Priority
:set nf=octal,hex,alpha

function! todo#txt#prioritize_increase()
    normal! 0f)h
endfunction

function! todo#txt#prioritize_decrease()
    normal! 0f)h
endfunction

function! todo#txt#prioritize_add(priority)
    " Need to figure out how to only do this if the first visible letter in a line is not (
    :call todo#txt#prioritize_add_action(a:priority)
endfunction

function! todo#txt#prioritize_add_action(priority)
    execute 's/^\(([a-zA-Z]) \)\?/(' . a:priority . ') /'
endfunction


function todo#txt#HasCheckbox()
  let l:current_line = getline(".")
  let l:match = match(l:current_line, '\[.\]:')
  if l:match != -1
    return v:true
  endif
  return v:false
endfunction

function todo#txt#HasPriority()
  let l:current_line = getline(".")
  let l:match = match(l:current_line, '(.) ')
  if l:match >= 0
    return v:true
  endif
  return v:false
endfunction

function todo#txt#HasDuedate()
  let l:current_line = getline(".")
  let l:match = match(l:current_line, 'due:')
  if l:match >= 0
    return v:true
  endif
  return v:false
endfunction

function todo#txt#TogglePriority()
  let l:current_line = getline(".")
  if todo#txt#HasPriority()
    call setline('.', substitute(l:current_line, '\v(\(.\)) ', '', ''))
  elseif todo#txt#HasCheckbox() && !todo#txt#HasPriority()
    call setline('.', substitute(l:current_line, '\v(\[.\]: )', '\1(A) ', ''))
  elseif !todo#txt#HasCheckbox() && !todo#txt#HasPriority()
    call setline('.', substitute(l:current_line, '\v(\w)', '(A) \1', ''))
  endif
endfunction

function todo#txt#ToggleCheckbox()
  let l:current_line = getline(".")
  if todo#txt#HasCheckbox()
    call setline('.', substitute(l:current_line, '\[.\]: ', '', ''))
  else 
    execute 's/\v([-+#] )+(\(.\) )?\s?/\1[ ]: \2'.strftime('%Y-%m-%d').' /'
  endif
endfunction

function todo#txt#TodoCheckoff()
  if !todo#txt#HasCheckbox()
    return
  endif

  let l:current_line = getline(".")
  let l:unchecked = match(l:current_line, '\v\[ \]:')

  if l:unchecked
    echom "unchecked"
    call setline('.', substitute(l:current_line, '\v\[ \]: (\(.\))?\s?', '[x]: '.strftime('%Y-%m-%d').' ', ''))
  else 
    call setline('.', substitute(l:current_line, '\[.\]:', '[ ]:', ''))
  endif

endfunction


function todo#txt#IncreasePriority()
  " if !todo#txt#HasCheckbox() || expand("%:p:t") != "todo.txt"
  "   return
  " end

  if todo#txt#HasPriority()
    " execute('normal todo#txt#mz0t)'."\<c-A>`z")
    normal! 0f)h
  else
    call todo#txt#TogglePriority()
  endif
endfunction

function todo#txt#SetPriority(val)
  if !todo#txt#HasPriority()
    call todo#txt#TogglePriority()
  endif
  execute('normal todo#txt#mz0t)r'.a:val."`z")
endfunction


function todo#txt#SetDuedate(val)
  let l:current_line = getline(".")
  execute('normal todo#txt#mz')
  if !todo#txt#HasDuedate()
    " call setline('.', substitute(l:crrent_line, '\v$', ' due:'.s:get_current_date().' ', ''))
    execute 's/$/ due:'.a:val.'/'
  else
    " execute 's/due:\d\{2,4\}-\d\{2\}-\d\{2\}/due:'.a:val.'/'
    execute 's/due:\d\{2,4\}-\d\{2\}-\d\{2\}/due:'.a:val.'/'
  endif
  execute('normal todo#txt#`z')
endfunction

function todo#txt#DecreasePriority()
  " if !todo#txt#HasCheckbox() || expand("%:p:t") != "todo.txt"
  "   return
  " end

  if matchstr(getline('.'), '(A)') == "(A)"
    call todo#txt#TogglePriority()
  elseif todo#txt#HasPriority()
    " execute('normal todo#txt#mz0t)'."\<c-X>`z")
    normal! 0f)h
  else
    call todo#txt#TogglePriority()
  endif
endfunction


" Modeline {{{1
" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1
