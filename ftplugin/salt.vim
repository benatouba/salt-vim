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

" No indentexpr, folding, mappings, match IDs, global options or autocmds.
" YAML-only indentation is not a reliable mixed YAML/Jinja indenter.
