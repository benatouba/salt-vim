" Salt state syntax, community continuation of saltstack/salt-vim.
" Original Salt highlighting: Seth House. Modified 2026-11-04.
" SPDX-License-Identifier: Apache-2.0
if exists('b:current_syntax')
  finish
endif

runtime syntax/yaml.vim
unlet! b:current_syntax

" Use one Jinja provider, not every provider on runtimepath. Older Glench
" versions infer an HTML host (or recursively load Salt) unless disabled.
let s:had_html = exists('g:jinja_syntax_html')
let s:saved_html = get(g:, 'jinja_syntax_html', 0)
let s:had_main = exists('g:main_syntax')
let s:saved_main = get(g:, 'main_syntax', '')
if !s:had_main
  let g:main_syntax = 'yaml'
endif
try
  let g:jinja_syntax_html = 0
  runtime syntax/jinja.vim
finally
  if s:had_html
    let g:jinja_syntax_html = s:saved_html
  else
    unlet! g:jinja_syntax_html
  endif
  if s:had_main
    let g:main_syntax = s:saved_main
  else
    unlet! g:main_syntax
  endif
endtry

" Template blocks can span YAML scalars; providers differ in sync defaults.
if get(g:, 'salt_syntax_sync_fromstart', 1)
  syntax sync fromstart
else
  syntax sync minlines=200
endif

" Runtime, HiPhish and Glench raw regions reject whitespace control, so trimmed
" blocks fall through to tag and variable highlighting. Extending the provider's
" own group keeps its exclusions working and stays correct if it is fixed later.
syn region jinjaRaw matchgroup=jinjaRawDelim start="{%[-+]\?\s*raw\s*[-+]\?%}" end="{%[-+]\?\s*endraw\s*[-+]\?%}" containedin=ALLBUT,jinjaTagBlock,jinjaVarBlock,jinjaString,jinjaComment

" Salt's renderer extensions and injected globals are not generic Jinja.
syn keyword salt_jinjaStatement load_yaml endload import_yaml load_json import_json load_text import_text contained containedin=jinjaTagBlock
syn keyword salt_jinjaGlobal salt pillar grains opts config saltenv sls tpldir tplfile tpldot contained containedin=jinjaVarBlock,jinjaTagBlock,jinjaNested
syn match salt_renderer /\%^#!.*/

" These are highlighting hints, not state validation. Keep them in YAML keys,
" never plain values, comments, Jinja strings or raw template text.
syn keyword salt_stateInclude include extend exclude contained containedin=yamlBlockMappingKey
syn keyword salt_stateSpecialArgs name names check_cmd creates fire_event listen listen_in onchanges onchanges_any onchanges_in onfail onfail_any onfail_all onfail_in onfail_stop onlyif order parallel prereq prereq_in prerequired reload_grains reload_modules reload_pillar require require_any require_in retry runas runas_password saltenv umask unless use use_in watch watch_any watch_in contained containedin=yamlBlockMappingKey
syn keyword salt_stateErrors requires requires_any requires_in watches watches_any watches_in includes extends reload_pillars contained containedin=yamlBlockMappingKey

hi def link salt_jinjaStatement Statement
hi def link salt_jinjaGlobal Special
hi def link salt_renderer PreProc
hi def link salt_stateInclude Include
hi def link salt_stateSpecialArgs Special
hi def link salt_stateErrors Error

let b:current_syntax = 'salt'
