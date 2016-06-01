setlocal indentexpr=EarlGreyIndent(v:lnum)
setlocal indentkeys=0(,0),0{,0},0[,0],0\,o,O
setlocal shiftwidth=3
setlocal softtabstop=3


function! s:EarlGreySyntaxName(expr)
  if type(a:expr) == type([])
    if type(a:expr[1]) == type('') && a:expr[1] == '.'
      if type(a:expr[0]) != type('') || a:expr[0] != '.'
        throw "Can't use column '.' without line '.'"
      endif
      let [bnum, lnum, cnum, onum] = getpos('.')
    else
      let lnum = a:expr[0]
      let cnum = col([lnum, a:expr[1]])
      if a:expr[1] == '$'
        " We want the last *actual* character
        let cnum -= 1
      endif
    endif
  else
    let [bnum, lnum, cnum, onum] = getpos(a:expr)
  endif
  let syntax_stack = synstack(lnum, cnum)
  if empty(syntax_stack)
    return ''
  endif
  return synIDattr(syntax_stack[-1], 'name')
endfunction


function! s:EarlGreyLineIsComment(lnum)
  let line = getline(a:lnum)
  if match(line, '\v\s*;;') != -1
    return 1
  endif
  return 0
endfunction


function! s:EarlGreyLineWithoutComment(lnum)
  let cnum = col([a:lnum, '$']) - 1
  let line = getline(a:lnum)
  while 1
    if cnum < 1
      return ''
    endif
    if s:EarlGreySyntaxName([a:lnum, cnum]) != 'egComment'
      return line[:cnum - 1]
    endif
    let cnum -= 1
  endwhile
endfunction


function! s:EarlGreyFindPrevCodeLine(lnum)
  let lnum = a:lnum
  while 1
    let lnum = prevnonblank(lnum - 1)
    if lnum == 0
        return 0
    endif
    if s:EarlGreyLineIsComment(lnum)
      continue
    endif
    return lnum
  endwhile
endfunction


function! EarlGreyIndent(lnum)
  if a:lnum == 1
    return 0
  endif
  let prev_lnum = s:EarlGreyFindPrevCodeLine(a:lnum)
  if prev_lnum == 0
    return 0
  endif
  let syntax_name = s:EarlGreySyntaxName('.')
  let prev_indent = indent(prev_lnum)
  " If we're inside a string, keep the indent of the previous line
  if !empty(syntax_name) && syntax_name == 'egString'
    return prev_indent
  endif
  let this_line = s:EarlGreyLineWithoutComment(a:lnum)
  let prev_line = s:EarlGreyLineWithoutComment(prev_lnum)
  let indent_level = 0
  if match(prev_line, '\v%([[({:]|%(%(^|\s+)%([=%,;]|[-=]\>|each\*?|where|with)))\s*$') != -1
    let indent_level += 1
  endif
  " FIXME needs to properly match balanced brackets
  if match(this_line, '\v[)}\]]\s*$') != -1
    let indent_level -= 1
  endif
  return prev_indent + (shiftwidth() * indent_level)
endfunction
