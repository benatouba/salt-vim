" Modern runtimes detect .sls as salt before plugin ftdetect files run.
" Modified 2026-11-04; Apache-2.0.
" Preserve unrelated filetypes, but recognize Python-rendered Salt sources.
function! s:DetectSalt() abort
  if index(['', 'salt', 'sls'], &l:filetype) < 0
    return
  endif
  if getline(1) =~# '^#!py\%($\|[[:space:]|]\)'
    setlocal filetype=python
  elseif empty(&l:filetype)
    setfiletype salt
  endif
endfunction

augroup salt_vim_detect
  autocmd!
  autocmd BufNewFile,BufRead *.sls,Saltfile call s:DetectSalt()
augroup END
