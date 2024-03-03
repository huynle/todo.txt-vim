" function! HasCheckbox()
"   let l:current_line = getline(".")
"   let l:match = match(l:current_line, '\[.\]:')
"   if l:match != -1
"     return v:true
"   endif
"   return v:false
" endfunction
"
" function! HasPriority()
"   let l:current_line = getline(".")
"   let l:match = match(l:current_line, '(.) ')
"   if l:match >= 0
"     return v:true
"   endif
"   return v:false
" endfunction
"
" function! HasDuedate()
"   let l:current_line = getline(".")
"   let l:match = match(l:current_line, 'due:')
"   if l:match >= 0
"     return v:true
"   endif
"   return v:false
" endfunction
"
" function! TogglePriority()
"   let l:current_line = getline(".")
"   if HasPriority()
"     call setline('.', substitute(l:current_line, '\v(\(.\)) ', '', ''))
"   elseif HasCheckbox() && !HasPriority()
"     call setline('.', substitute(l:current_line, '\v(\[.\]: )', '\1(B) ', ''))
"   elseif !HasCheckbox() && !HasPriority()
"     call setline('.', substitute(l:current_line, '\v(\w)', '(B) \1', ''))
"   endif
" endfunction
"
" function! ToggleCheckbox()
"   let l:current_line = getline(".")
"   if HasCheckbox()
"     call setline('.', substitute(l:current_line, '\[.\]: ', '', ''))
"   else 
"     execute 's/\v([-+#] )+(\(.\) )?\s?/\1[ ]: \2'.strftime('%Y-%m-%d').' /'
"   endif
" endfunction
"
" function! TodoCheckoff()
"   if !HasCheckbox()
"     return
"   endif
"
"   let l:current_line = getline(".")
"   let l:unchecked = match(l:current_line, '\v\[ \]:')
"
"   if l:unchecked
"     echom "unchecked"
"     call setline('.', substitute(l:current_line, '\v\[ \]: (\(.\))?\s?', '[x]: '.strftime('%Y-%m-%d').' ', ''))
"   else 
"     call setline('.', substitute(l:current_line, '\[.\]:', '[ ]:', ''))
"   endif
"
" endfunction
"
"
" function! IncreasePriority()
"   if !HasCheckbox() || expand("%:p:t") != "todo.txt"
"     return
"   end
"
"   if HasPriority()
"     execute('normal! mz0t)'."\<c-A>`z")
"   else
"     call TogglePriority()
"   endif
" endfunction
"
" function! SetPriority(val)
"   if !HasPriority()
"     call TogglePriority()
"   endif
"   execute('normal! mz0t)r'.a:val."`z")
" endfunction
"
"
" function! s:get_current_date()
"     return strftime('%Y-%m-%d')
" endfunction
"
" function! SetDuedate(val)
"   let l:current_line = getline(".")
"   execute('normal! mz')
"   if !HasDuedate()
"     " call setline('.', substitute(l:crrent_line, '\v$', ' due:'.s:get_current_date().' ', ''))
"     execute 's/$/ due:'.a:val.'/'
"   else
"     " execute 's/due:\d\{2,4\}-\d\{2\}-\d\{2\}/due:'.a:val.'/'
"     execute 's/due:\d\{2,4\}-\d\{2\}-\d\{2\}/due:'.a:val.'/'
"   endif
"   execute('normal! `z')
" endfunction
"
" function! DecreasePriority()
"   if !HasCheckbox() || expand("%:p:t") != "todo.txt"
"     return
"   end
"
"   if HasPriority()
"     execute('normal! mz0t)'."\<c-X>`z")
"   else
"     call TogglePriority()
"   endif
" endfunction


augroup CustomTODO
  autocmd!
  " wanted to enabled nrformat+=alpha, in order to increment
  autocmd CursorMoved,CursorMovedI * if todo#txt#HasPriority() | :setl nf+=alpha | else | :setl nf-=alpha | endif
  " autocmd InsertLeave * if matchstr(getline('.'), 'due:"\zs[^"]\+\ze"') | :setl nf+=alpha | else | :setl nf-=alpha |endif
augroup END

" " nnoremap <silent> T :85vsplit $TODO_DIR/todo.txt<CR>
" " nnoremap <silent> <leader>tt :85vsplit $TODO_DIR/todo.txt<CR>
" nnoremap <silent> <localleader>t<localleader> :call todo#txt#ToggleCheckbox()<CR>
" nnoremap <silent> <localleader>td :call todo#txt#TodoCheckoff()<CR>
" nnoremap <silent> + :call todo#txt#IncreasePriority()<CR>
" nnoremap <silent> _ :call todo#txt#DecreasePriority()<CR>
" nnoremap <silent> <localleader>t1 :call todo#txt#SetPriority("A")<CR>
" nnoremap <silent> <localleader>t2 :call todo#txt#SetPriority("B")<CR>
" nnoremap <silent> <localleader>t3 :call todo#txt#SetPriority("C")<CR>
" nnoremap <silent> <localleader>t4 :call todo#txt#SetPriority("D")<CR>
" nnoremap <silent> <localleader>t0 :call todo#txt#TogglePriority()<CR>
" nnoremap <silent> <localleader>tr :call todo#txt#SetDuedate(v:lua.get_due_date(input("due: ")))<CR>
