" Conservative, syntax-provider-independent layout. Original; Apache-2.0.
" YAML indentation is data: retain its existing hierarchy, rather than guess
" sibling boundaries. Only standalone Jinja control lines use template depth.
function! s:Tag(text) abort
  " Multiple tags on one line are inline template text, not layout controls.
  if matchend(a:text, '%}') != strlen(substitute(a:text, '\s*$', '', ''))
    return ''
  endif
  return matchstr(a:text, '^\s*{%[-+]\?\s*\zs\w\+\ze\>.*[-+]\?%}\s*$')
endfunction

function! s:Layout(last) abort
  let result = []
  let stack = []
  let scalar = -1
  let comment = 0
  for lnum in range(1, a:last)
    let text = getline(lnum)
    let spaces = indent(lnum)
    let blank = text =~# '^\s*$'
    let floor = empty(stack) ? 0 : stack[-1].indent + shiftwidth()
    let tag = s:Tag(text)
    let literal = scalar >= 0 && (blank || spaces > scalar)
    if !literal
      let scalar = -1
    endif
    " Raw and load_text bodies retain literal whitespace, including apparent
    " controls. Do not change the value of a text-capturing extension.
    let raw = !empty(stack) && index(['raw', 'load_text'], stack[-1].tag) >= 0
    let raw_end = raw && stack[-1].tag ==# 'raw' ? 'endraw' : 'endload'
    let protected = literal || comment || text =~# '^\s*{#' || (raw && tag !=# raw_end)
    let target = spaces
    let level = len(stack)
    let boundary = ''
    if !protected
      if tag =~# '^end' || index(['else', 'elif'], tag) >= 0
        let expected = tag =~# '^end' ? strpart(tag, 3) : 'if'
        if tag ==# 'endload'
          let expected = 'load_'
        endif
        " Do not guess on unmatched/malformed control statements.
        if !empty(stack) && (stack[-1].tag ==# expected
              \ || (expected ==# 'load_' && stack[-1].tag =~# '^load_')
              \ || (tag ==# 'else' && stack[-1].tag ==# 'for'))
          let target = stack[-1].indent
          if tag =~# '^end'
            let boundary = '<'
            call remove(stack, -1)
          endif
        endif
      elseif tag =~# '^\%(if\|for\|macro\|block\|filter\|call\|with\|autoescape\|raw\|load_yaml\|load_json\|load_text\)$'
            \ || (tag ==# 'set' && text !~# '=')
        let target = max([spaces, floor])
        call add(stack, {'tag': tag, 'indent': target})
        let boundary = '>'
      elseif !blank
        let target = spaces
      else
        let previous = prevnonblank(lnum - 1)
        while previous > 0 && !empty(s:Tag(getline(previous)))
          let previous = prevnonblank(previous - 1)
        endwhile
        let target = previous > 0 ? indent(previous) : 0
        if previous > 0 && getline(previous) =~# ':\s*\%(#.*\)\?$'
          let target += shiftwidth()
        endif
      endif
      " With trailing-only whitespace control, leading spaces can become a
      " prefix of the next rendered YAML line. A raw/text closer's prefix is
      " itself captured literal text. Preserve those prefixes exactly.
      if raw || (text =~# '-%}\s*$' && text !~# '^\s*{%-')
        let target = spaces
        if boundary ==# '>'
          let stack[-1].indent = spaces
        endif
      endif
      let level = max([level, len(stack)])
      " Quoted strings/comments cannot introduce YAML block scalars here.
      if text !~# '^\s*\%({%\|#\)' && text =~# '\%(:\s*\|^\s*-\s\+\|^\s*\)[|>][0-9+-]*\s*\%(#.*\)\?$'
        let scalar = spaces
      endif
    endif
    if !literal && !raw
      if comment
        let comment = text !~# '#}'
      elseif text =~# '^\s*{#' && text !~# '#}'
        let comment = 1
      endif
    endif
    " YAML folds retain their structural depth, with Jinja adding a level.
    let yaml = spaces / max([1, shiftwidth()])
    let depth = max([level, yaml])
    call add(result, {'indent': protected ? -1 : target,
          \ 'fold': blank ? -1 : (empty(boundary) ? depth : boundary . depth)})
  endfor
  return result
endfunction

function! salt#layout#Indent() abort
  " Keep a stable structural snapshot across = operations. Reparse on any
  " edit other than the exact whitespace change we just asked Vim to make.
  let lines = getline(1, '$')
  let key = [shiftwidth(), &l:expandtab, &l:tabstop]
  if get(b:, 'salt_indent_lines', []) !=# lines || get(b:, 'salt_indent_key', []) !=# key
    let b:salt_indent_plan = s:Layout(line('$'))
    let b:salt_indent_lines = lines
    let b:salt_indent_key = key
  endif
  let target = b:salt_indent_plan[v:lnum - 1].indent
  if target >= 0
    let prefix = &l:expandtab ? repeat(' ', target)
          \ : repeat("\t", target / &l:tabstop) . repeat(' ', target % &l:tabstop)
    let b:salt_indent_lines[v:lnum - 1] = prefix . substitute(getline(v:lnum), '^\s*', '', '')
  endif
  return target
endfunction

function! salt#layout#Fold(lnum) abort
  " Fold expressions are evaluated repeatedly; parse once per buffer edit.
  let key = [b:changedtick, shiftwidth()]
  if get(b:, 'salt_layout_key', []) !=# key
    let b:salt_layout = s:Layout(line('$'))
    let b:salt_layout_key = key
  endif
  return b:salt_layout[a:lnum - 1].fold
endfunction
