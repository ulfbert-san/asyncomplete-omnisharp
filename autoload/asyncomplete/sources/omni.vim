if get(g:, 'loaded_autoload_asyncomplete_sources_omni')
  finish
endif
let g:loaded_autoload_asyncomplete_sources_omni = 1
let s:save_cpo = &cpo
set cpo&vim

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

    let l:seen = {}
    let l:filtered = []

    " Filter duplicate entries out
    for item in l:matches
        if type(item) == type({})
            if has_key(item, 'word')
                let word = item['word']

                if has_key(item, 'kind')
                    let item['kind'] = toupper(item['kind'])
                endif

                if !has_key(l:seen, word)
                    let seen[word] = 1
                    call add(l:filtered, item)
                endif
            endif
        else
            if !has_key(l:seen, item)
                let seen[item] = 1
                call add(l:filtered, item)
            endif
        endif
    endfor

    call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol + 1, l:filtered)

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

let &cpo = s:save_cpo
unlet s:save_cpo
