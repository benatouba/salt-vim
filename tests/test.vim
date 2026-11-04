set nocompatible
set nomore
let s:root = fnamemodify(expand('<sfile>:p'), ':h:h')
" -u NONE keeps the user's config and after/ directories on runtimepath, where
" personal ftplugins would change the state asserted below.
execute 'set runtimepath=' . fnameescape($VIMRUNTIME)
execute 'set runtimepath^=' . fnameescape(s:root)
filetype plugin indent on
" Select syntax only; external providers' detection/indent is not under test.
if !empty($SALT_VIM_JINJA_PATH)
  execute 'set runtimepath^=' . fnameescape($SALT_VIM_JINJA_PATH)
endif
syntax enable

function! s:Groups(lnum, text) abort
  let column = match(getline(a:lnum), '\V' . escape(a:text, '\')) + 1
  call assert_true(column > 0, 'Missing fixture text: ' . a:text)
  return map(synstack(a:lnum, column), 'synIDattr(v:val, "name")')
endfunction

function! s:Has(lnum, text, group) abort
  call assert_true(index(s:Groups(a:lnum, a:text), a:group) >= 0,
        \ printf('%d %s expected %s, got %s', a:lnum, a:text, a:group, string(s:Groups(a:lnum, a:text))))
endfunction

function! s:NotSalt(lnum, text) abort
  call assert_equal([], filter(s:Groups(a:lnum, a:text), 'v:val =~# "^salt_"'))
endfunction

function! s:Run() abort
  let delimiters = {'existing': {'left': '!'}}
  let g:NERDCustomDelimiters = deepcopy(delimiters)
  let g:jinja_syntax_html = 1
  let old_engine = &regexpengine
  let old_fo = &l:formatoptions
  let old_fold = &l:foldmethod
  let old_indent = &l:indentexpr
  let old_style = [&g:expandtab, &g:shiftwidth, &g:softtabstop]
  execute 'edit ' . fnameescape(s:root . '/tests/fixtures/mixed.sls')
  call assert_equal('salt', &l:filetype)
  call assert_equal('salt', b:current_syntax)
  call assert_equal('# %s', &l:commentstring)
  call assert_equal([1, 2, 2], [&l:expandtab, &l:shiftwidth, &l:softtabstop])
  call assert_equal(old_style, [&g:expandtab, &g:shiftwidth, &g:softtabstop])
  call assert_equal(old_engine, &regexpengine)
  call assert_equal(old_fo, &l:formatoptions)
  call assert_equal(old_fold, &l:foldmethod)
  call assert_equal(old_indent, &l:indentexpr)
  call assert_equal(delimiters, g:NERDCustomDelimiters)
  call assert_equal(1, g:jinja_syntax_html)
  call assert_false(exists('g:main_syntax'))
  call assert_false(exists('*GetYamlIndent'))
  call s:Has(1, '#!', 'salt_renderer')
  call s:Has(2, 'settings', 'jinjaVariable')
  call s:Has(2, 'paths', 'jinjaString')
  call s:Has(3, 'import_yaml', 'salt_jinjaStatement')
  call s:Has(4, 'load_yaml', 'salt_jinjaStatement')
  call s:Has(7, 'include', 'salt_stateInclude')
  call s:Has(10, 'path', 'jinjaVariable')
  call s:Has(12, 'pillar', 'salt_jinjaGlobal')
  call s:Has(13, 'salt', 'salt_jinjaGlobal')
  call s:Has(14, 'require_any', 'salt_stateSpecialArgs')
  call s:Has(16, 'onchanges_any', 'salt_stateSpecialArgs')
  call s:Has(18, 'retry', 'salt_stateSpecialArgs')
  call s:Has(21, 'grains', 'salt_jinjaGlobal')
  call s:NotSalt(22, 'requires')
  call s:NotSalt(23, 'requires')
  call s:Has(24, 'requires', 'salt_stateErrors')
  call s:NotSalt(27, 'require_any')
  call s:Has(30, 'pillar', 'jinjaRaw')
  call s:NotSalt(30, 'pillar')
  call s:Has(32, 'opts', 'salt_jinjaGlobal')
  call s:Has(33, 'config', 'salt_jinjaGlobal')
  " Whitespace control on either delimiter still means a raw block.
  for [lnum, text] in [[37, 'grains'], [41, 'pillar'], [45, 'salt'], [47, 'opts'], [50, 'pillar']]
    call s:Has(lnum, text, 'jinjaRaw')
    call s:NotSalt(lnum, text)
  endfor
  " Template handling resumes after each block, and delimiters that are only
  " comment or string text do not open one.
  call s:Has(52, 'config', 'salt_jinjaGlobal')
  call s:Has(54, 'grains', 'salt_jinjaGlobal')
  call s:Has(55, 'raw', 'jinjaString')
  call s:Has(56, 'sls', 'salt_jinjaGlobal')

  " Filetype changes undo only our options and do not clear others' matches.
  let match_id = matchadd('Error', 'keep-this-match')
  execute b:undo_ftplugin
  call assert_equal(old_style, [&l:expandtab, &l:shiftwidth, &l:softtabstop])
  call assert_equal(&g:commentstring, &commentstring)
  setlocal filetype=text
  enew!
  call assert_true(index(map(getmatches(), 'v:val.id'), match_id) >= 0)
  call matchdelete(match_id)

  " Historical filetype and repeat sourcing share the same guarded defaults.
  setfiletype sls
  call assert_equal('sls', b:current_syntax)
  let undo = b:undo_ftplugin
  runtime ftplugin/sls.vim
  call assert_equal(undo, b:undo_ftplugin)
  unlet g:jinja_syntax_html
  setlocal syntax=OFF
  setlocal syntax=sls
  call assert_false(exists('g:jinja_syntax_html'))
  let g:main_syntax = 'jinja'
  setlocal syntax=OFF
  setlocal syntax=sls
  call assert_equal('jinja', get(g:, 'main_syntax', ''), 'Preserve existing host marker')
  unlet! g:main_syntax

  enew!
  let g:salt_recommended_style = 0
  setlocal shiftwidth=4 softtabstop=4 noexpandtab
  setfiletype salt
  call assert_equal([0, 4, 4], [&l:expandtab, &l:shiftwidth, &l:softtabstop])
  unlet g:salt_recommended_style
  enew!
  let g:filetype_recommended_style = 0
  setlocal shiftwidth=6 softtabstop=6 noexpandtab
  setfiletype salt
  call assert_equal([0, 6, 6], [&l:expandtab, &l:shiftwidth, &l:softtabstop])
  unlet g:filetype_recommended_style

  " Exercise the actual BufRead hooks, including native pre-detection.
  let directory = tempname()
  call mkdir(directory, 'p')
  try
    for [name, lines, expected] in [
          \ ['python.sls', ['#!py', 'def run():', '    return {}'], 'python'],
          \ ['pipeline.sls', ['#!py|yaml', 'def run(): pass'], 'python'],
          \ ['not-python.sls', ['#!python_not_a_renderer', 'key: value'], 'salt'],
          \ ['Saltfile', ['salt:', '  state_top: top.sls'], 'salt'],
          \ ['ordinary.html', ['<p>{{ pillar }}</p>'], 'html'],
          \ ['ordinary.yaml', ['require_any: value'], 'yaml']]
      call writefile(lines, directory . '/' . name)
      execute 'edit! ' . fnameescape(directory . '/' . name)
      call assert_equal(expected, &l:filetype, name)
      if expected ==# 'yaml'
        call s:NotSalt(1, 'require_any')
      endif
    endfor
    enew!
    setlocal filetype=json
    call assert_equal('json', &l:filetype)
    execute 'doautocmd salt_vim_detect BufRead ' . fnameescape(directory . '/python.sls')
    call assert_equal('json', &l:filetype, 'Preserve unrelated filetype')
    execute 'edit! ' . fnameescape(directory . '/new.sls')
    call assert_equal('salt', &l:filetype, 'BufNewFile')
  finally
    enew!
    call delete(directory, 'rf')
  endtry

  " Snippets are inert VS Code JSON data for the user's snippet engine.
  let manifest = json_decode(join(readfile(s:root . '/package.json'), "\n"))
  let entries = manifest.contributes.snippets
  call assert_equal(1, len(entries))
  call assert_equal(['salt', 'sls'], entries[0].language)
  let snippets = json_decode(join(readfile(s:root . '/' . entries[0].path), "\n"))
  let prefixes = []
  for [name, snippet] in items(snippets)
    call assert_true(type(snippet.prefix) == v:t_string && snippet.prefix =~# '^s\w\+$', name)
    call assert_true(type(snippet.body) == v:t_list && !empty(snippet.body), name)
    call add(prefixes, snippet.prefix)
  endfor
  call assert_equal(len(prefixes), len(uniq(sort(copy(prefixes)))), 'Unique snippet prefixes')

  " Forks reported regexp engine failures; force syntax evaluation in each
  " supported engine without the plugin ever selecting one for the user.
  for engine in [0, 1, 2]
    let &regexpengine = engine
    execute 'edit! ' . fnameescape(s:root . '/tests/fixtures/mixed.sls')
    syntax sync fromstart
    for lnum in range(1, line('$'))
      call synstack(lnum, max([1, strlen(getline(lnum))]))
    endfor
    call assert_equal(engine, &regexpengine)
  endfor
  let &regexpengine = old_engine
endfunction

try
  call s:Run()
catch
  call add(v:errors, v:exception . ' at ' . v:throwpoint)
endtry
if !empty(v:errors)
  set verbose=1
  for failure in v:errors
    echomsg failure
  endfor
  cquit 1
endif
qa!
