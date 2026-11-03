" Historical filetype alias; new detection uses salt.
" Modified 2026-11-04; Apache-2.0.
if exists('b:current_syntax')
  finish
endif
runtime syntax/salt.vim
let b:current_syntax = 'sls'
