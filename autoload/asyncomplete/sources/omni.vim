if get(g:, 'loaded_autoload_asyncomplete_sources_omni')
  finish
endif
let g:loaded_autoload_asyncomplete_sources_omni = 1
let s:save_cpo = &cpo
set cpo&vim

function! asyncomplete#sources#omni#get_source_options(opts) abort
  return extend({
        \ 'refresh_pattern': '\%(\k\|\.\)',
        \ 'config': {
        \   'show_source_kind': 1
        \ }
        \}, a:opts)
endfunction

function! asyncomplete#sources#omni#completor(opt, ctx) abort
  try
    let l:col = a:ctx['col']
    let l:typed = a:ctx['typed']

    let l:startcol = s:safe_omnifunc(1, '')
    if l:startcol < 0
      return
    elseif l:startcol > l:col
      let l:startcol = l:col
    endif
    let l:base = l:typed[l:startcol : l:col]
    let l:matches = s:safe_omnifunc(0, l:base)
    if a:opt['config']['show_source_kind']
      let l:matches = map(copy(l:matches), function('s:append_kind'))
    endif
    call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol + 1, l:matches)
  catch
    call asyncomplete#log('omni', 'error', v:exception)
  endtry
endfunction


function! s:safe_omnifunc(...) abort
  let cursor = getpos('.')
  try
    if &omnifunc == 'v:lua.vim.lsp.omnifunc'
      return v:lua.vim.lsp.omnifunc(a:1, a:2)
    else
      return call(&omnifunc, a:000)
    endif
  finally
    call setpos('.', cursor)
  endtry
endfunction

function! s:append_kind(key, val) abort
  if type(a:val) == v:t_string
    return { 'word': a:val, 'kind': 'o' }
  endif

  let a:val['kind'] = 'o'
  return a:val
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
