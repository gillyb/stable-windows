" Initialization
if exists('stable_windows')
  finish
endif

if v:version < 700
  echoerr 'stable-windows requires vim version >= 700.'
  finish
endif

let stable_windows = 1


""""""""""""""""""""
" Plugin Functions "
""""""""""""""""""""

" Stores an object with the 'cursor state' of the currently open windows
let s:WindowsState = {}

" A list of 'Most recently used file window ids'
let s:MruFileWinId = {}

" Triggered on 'autocmd BufEnter' - When a new file was open
" We add the new window id to the MruFileWinId list
function! s:AddFileToList()
  let winInfo = getwininfo(win_getid())[0]
  if winInfo['quickfix'] == 1
    return
  endif

  let newFile = expand('%:p')
  if newFile != ''
    let newFileWinId = win_getid()

    if newFileWinId != 0
      let s:MruFileWinId[newFile] = newFileWinId
    endif
  endif
endfunction

" Triggered on 'autocmd BufDelete' - When a file is closed and not open in any
" other buffer.
" We remove the file and window id from the MruFileWinId list
function! s:RemoveFileFromList()
  let bufferFile = expand('%:p')
  if has_key(s:MruFileWinId, bufferFile)
    unlet s:MruFileWinId[bufferFile]
  endif
endfunction

" Triggered on 'autocmd WinLeave'
" Remove from the state object window ids that aren't displayed anymore
function! s:RemoveFileListBadEntries()
  let winNumbers = range(1, winnr('$'))
  for winNum in winNumbers
    let winId = win_getid(winNum)
    if winId != 0
      if win_gotoid(winId) == 0
        unlet s:WindowsState[winId]
      endif
    endif
  endfor
endfunction

" Triggered on 'autocmd CursorMoved,CursorMovedI' - Basically whenever the
" cursor in the window moves
" Save the state of the window - This is saved in the object 's:WindowsState'
" in the format: s:WindowsState[<window id>] = [<top visible line number>,
" <current cursor line>]
function! s:SaveWindowState()
  let winInfo = getwininfo(win_getid())[0]
  if winInfo['quickfix'] == 1
    return
  endif

  let prev_ei = &ei  " Remember what the user defined as 'ei'
  set ei=all
  try
    let winId = win_getid()
    if winId != 0
      " saves an array with [<first line in window>, <current cursor line>]
      let s:WindowsState[winId] = [line('w0'), line('.')]
    endif

  finally
    set ei=prev_ei
  endtry
endfunction

" Triggered on 'autocmd WinEnter'
" Get the state of the opened windows and restore them so we wont see any
" scroll moevement in the opened windows.
function! s:RestoreWindowState()
  let prev_ei = &ei  " Remember what the user defined as 'ei'
  set ei=all
  try
    let currWinId = win_getid()
    let winFileName = expand('%:p')

    if has_key(s:MruFileWinId, winFileName) && !has_key(s:WindowsState, currWinId)
      " Get existing scrolled position from open window
      let existingWinId = s:MruFileWinId[winFileName]
      "" TODO: Maybe we should make sure this window still exists

      if has_key(s:WindowsState, existingWinId)

        let topWinLine = s:WindowsState[existingWinId][0]
        execute 'normal! gg'
        if topWinLine >= &scrolloff + 1
          execute 'normal! '.(topWinLine + &scrolloff - 1).'jzt'
        endif

        " Move cursor to the last cursor position (or max position possible)
        let currentCursorPosition = line('.')
        let lastCursorPosition = s:WindowsState[existingWinId][1]
        if currentCursorPosition != lastCursorPosition
          let lastSelectablePosition = line('w$') - &scrolloff
          if lastCursorPosition > lastSelectablePosition
            execute 'normal! '.(lastSelectablePosition - currentCursorPosition).'j'
          else
            execute 'normal! '.(lastCursorPosition - currentCursorPosition).'j'
          endif
        endif

      endif
    endif

    for winId in keys(s:WindowsState)
      if win_gotoid(winId) == 1

        let topWinLine = s:WindowsState[winId][0]
        execute 'normal! gg'
        if topWinLine >= &scrolloff + 1
          execute 'normal! '.(topWinLine + &scrolloff - 1).'jzt'
        endif

        " Move cursor to the last cursor position (or max position possible)
        let currentCursorPosition = line('.')
        let lastCursorPosition = s:WindowsState[winId][1]
        if currentCursorPosition != lastCursorPosition
          let lastSelectablePosition = line('w$') - &scrolloff
          if lastCursorPosition > lastSelectablePosition
            execute 'normal! '.(lastSelectablePosition - currentCursorPosition).'j'
          else
            execute 'normal! '.(lastCursorPosition - currentCursorPosition).'j'
          endif
        endif

      endif
    endfor

    if currWinId != 0
      call win_gotoid(currWinId)
    endif

  finally
    set ei=prev_ei
  endtry
endfunction


" Defining auto commands
augroup stablewindows
  autocmd!
  autocmd CursorMoved,CursorMovedI * call s:SaveWindowState()
  autocmd WinEnter * call s:RestoreWindowState()
  autocmd WinLeave * call s:RemoveFileListBadEntries()
  autocmd BufEnter * call s:AddFileToList()
  autocmd BufDelete * call s:RemoveFileFromList()
augroup END
