" Salt buffer defaults. Modified 2026-11-04; Apache-2.0.
if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

setlocal comments=:# commentstring=#\ %s autoindent
let b:undo_ftplugin = 'setlocal comments< commentstring< autoindent<'

if get(g:, 'salt_recommended_style', get(g:, 'filetype_recommended_style', 1))
  setlocal expandtab shiftwidth=2 softtabstop=2
  let b:undo_ftplugin .= ' expandtab< shiftwidth< softtabstop<'
endif

if get(g:, 'salt_indent', 0)
  setlocal indentexpr=salt#layout#Indent()
  setlocal indentkeys=o,O,0{,},!^F
  let b:undo_ftplugin .= ' | setlocal indentexpr< indentkeys< | unlet! b:salt_indent_lines b:salt_indent_plan b:salt_indent_key'
endif

if get(g:, 'salt_folds', 0)
  setlocal foldmethod=expr foldexpr=salt#layout#Fold(v:lnum)
  let b:undo_ftplugin .= ' | setlocal foldmethod< foldexpr< | unlet! b:salt_layout b:salt_layout_key'
endif
