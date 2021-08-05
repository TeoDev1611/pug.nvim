" Author:  TeoDev ( malehurtadoreyes@gmail.com ) 
" URL:     https://github.com/TeoDev1611/pug.nvim
" Version: 1.0
" License: MIT
" ---------------------------------------------------------------------
let s:TYPE = {
      \   'string':  type(''),
      \   'list':    type([]),
      \   'dict':    type({}),
      \   'funcref': type(function('call'))
      \ }

function! pug#begin()
  let s:lazy = { 'ft': {}, 'map': {}, 'cmd': {} }
  let s:repos = {}

  if exists('#Pug')
    augroup Pug
      autocmd!
    augroup END
    augroup! Pug
  endif

  call s:setup_command()
endfunction

function! pug#end()
  for [l:name, l:cmds] in items(s:lazy.cmd)
    for l:cmd in l:cmds
      execute printf("command! -nargs=* -range -bang %s packadd %s | call s:do_cmd('%s', \"<bang>\", <line1>, <line2>, <q-args>)", l:cmd, l:name, l:cmd)
    endfor
  endfor

  for [l:name, l:maps] in items(s:lazy.map)
    for l:map in l:maps
      for [l:mode, l:map_prefix, l:key_prefix] in
            \ [['i', '<C-O>', ''], ['n', '', ''], ['v', '', 'gv'], ['o', '', '']]
        execute printf(
        \ '%snoremap <silent> %s %s:<C-U>packadd %s<bar>call <SID>do_map(%s, %s, "%s")<CR>',
        \  l:mode, l:map, l:map_prefix, l:name, string(l:map), l:mode != 'i', l:key_prefix)
      endfor
    endfor
  endfor

  runtime! OPT ftdetect/**/*.vim
  runtime! OPT after/ftdetect/**/*.vim

  for [name, fts] in items(s:lazy.ft)
    augroup Pug
      execute printf('autocmd FileType %s packadd %s', fts, name)
    augroup END
  endfor
endfunction

function! pug#add(repo, ...) abort
  let l:opts = get(a:000, 0, {})
  let l:name = substitute(a:repo, '^.*/', '', '')

  " `for` and `on` implies optional
  if has_key(l:opts, 'for') || has_key(l:opts, 'on')
    let l:opts['type'] = 'opt'
  endif

  if has_key(l:opts, 'for')
    let l:ft = type(l:opts.for) == s:TYPE.list ? join(l:opts.for, ',') : l:opts.for
    let s:lazy.ft[l:name] = l:ft
  endif

  if has_key(l:opts, 'on')
    for l:cmd in s:to_a(l:opts.on)
      if l:cmd =~? '^<Plug>.\+'
        if empty(mapcheck(l:cmd)) && empty(mapcheck(l:cmd, 'i'))
          call s:assoc(s:lazy.map, l:name, l:cmd)
        endif
      elseif cmd =~# '^[A-Z]'
        if exists(":".l:cmd) != 2
          call s:assoc(s:lazy.cmd, l:name, l:cmd)
        endif
      else
        call s:err('Invalid `on` option: '.cmd.
              \ '. Should start with an uppercase letter or `<Plug>`.')
      endif
    endfor
  endif

  let s:repos[a:repo] = l:opts
endfunction

function! pug#has_plugin(plugin)
  return index(s:get_plugin_list(), a:plugin) != -1
endfunction

function! s:assoc(dict, key, val)
  let a:dict[a:key] = add(get(a:dict, a:key, []), a:val)
endfunction

function! s:to_a(v)
  return type(a:v) == s:TYPE.list ? a:v : [a:v]
endfunction

function! s:err(msg)
  echohl ErrorMsg
  echom '[pug] '.a:msg
  echohl None
endfunction

function! s:do_cmd(cmd, bang, start, end, args)
  exec printf('%s%s%s %s', (a:start == a:end ? '' : (a:start.','.a:end)), a:cmd, a:bang, a:args)
endfunction

function! s:do_map(map, with_prefix, prefix)
  let extra = ''
  while 1
    let c = getchar(0)
    if c == 0
      break
    endif
    let l:extra .= nr2char(c)
  endwhile

  if a:with_prefix
    let prefix = v:count ? v:count : ''
    let prefix .= '"'.v:register.a:prefix
    if mode(1) == 'no'
      if v:operator == 'c'
        let prefix = "\<esc>" . prefix
      endif
      let prefix .= v:operator
    endif
    call feedkeys(prefix, 'n')
  endif
  call feedkeys(substitute(a:map, '^<Plug>', "\<Plug>", '') . extra)
endfunction

function! s:setup_command()
  command! -bar -nargs=+ Pug call pug#add(<args>)

  command! -bar PugInstall call s:init_pug() | call packager#install() 
  command! -bar PugUpdate call s:init_pug() | call packager#update('', {'do': 'call packager#status()'})
  command! -bar PugClean call s:init_pug() | call packager#clean()
  command! -bar PugStatus call s:init_pug() | call packager#status()
  command! -bar -nargs=1 -complete=customlist,s:plugin_dir_complete PugDisable call s:disable_plugin(<q-args>)
endfunction

function! s:init_pug()
  if &compatible
    set nocompatible
  endif

  packadd vim-packager 

  call packager#init()
  for [repo, opts] in items(s:repos)
    call packager#add(repo, opts)
  endfor
endfunction

function s:disable_plugin(plugin_dir, ...) abort
  if !isdirectory(a:plugin_dir)
    s:err(a:plugin_dir . 'not exists.')
    return
  endif
  let l:dst_dir = substitute(a:plugin_dir, '/start/\ze[^/]\+$', '/opt/', '')
  if isdirectory(l:dst_dir)
    s:err(l:dst_dir . 'exists.')
    return
  endif
  call rename(a:plugin_dir, l:dst_dir)
endfunction

function! s:plugin_dir_complete(A, L, P)
  let l:pat = 'pack/minpac/start/*'
  let l:plugin_list = filter(globpath(&packpath, l:pat, 0, 1), {-> isdirectory(v:val)})
  return filter(l:plugin_list, 'v:val =~ "'. a:A .'"')
endfunction

function! s:get_plugin_list()
  if exists("s:plugin_list")
    return s:plugin_list
  endif
  let l:pat = 'pack/*/*/*'
  let s:plugin_list = filter(globpath(&packpath, l:pat, 0, 1), {-> isdirectory(v:val)})
  call map(s:plugin_list, {-> substitute(v:val, '^.*[/\\]', '', '')})
  return s:plugin_list
endfunction
