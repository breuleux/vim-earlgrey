if exists("b:current_syntax")
  finish
endif

setlocal iskeyword=48-57,a-z,A-Z,_,$,-

syntax sync fromstart

let s:pairs = ['()', '[]', '{}']


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Comments

syntax match egComment /;;.*$/ contains=@Spell


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Constants

syntax region egString start=/\v\z("%("")?)/ skip=/\v\\./ end=/\v\z1/ contains=@Spell

syntax match egInterpolationDelimiter /\v[{}]/ contained
syntax region egInterpolation matchgroup=egInterpolationDelimiter start=/\v\{/ end=/\v\}/ contained contains=@egSyntax
syntax region egStringTemplate start=/\v\z('%('')?)/ skip=/\v\\./ end=/\v\z1/ contains=egInterpolation

syntax match egCodeQuoteDelimiter /\v`/ contained
syntax region egCodeQuote matchgroup=egCodeQuoteDelimiter start=/\v\z(`(``)?)/ skip=/\v\\./ end=/\v\z1/ contains=@egSyntax


let s:number = '%(\d+[rR][a-zA-Z0-9_]+%(\.[a-zA-Z0-9_]+)?|\d[0-9_]*%(\.\d+)?)'
execute 'syntax match egNumber /\v<' . s:number . '>/'
syntax match egRadixPrefix /\v<\d+[rR]/ contained containedin=egNumber


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Identifiers

let s:identifierStart = '[a-zA-Z$_]'
let s:identifierMid = '[a-zA-Z$_0-9-]'
let s:identifierEnd = '[a-zA-Z$_0-9]'
" needs to be wrapped in < > where used
execute "let s:identifier = '" . s:identifierStart . '%(-?' . s:identifierEnd . ")*'"


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Operators

" An operator can be any of these characters:
let s:opCharacter = '[!#%&*+./:<=>?@\\^|~-]'
let s:nonOpCharacter = '[^!#%&*+./:<=>?@\\^|~-]'

" or any of these words:
let s:opWord = '%(as|and|each|in|is|mod|not|of|or|when|where|with)'
let s:opWordBinary = '%(as|and|each|in|is|mod|of|or|when|where|with)'

" although these are "low priority" for standalone control forms:
let s:opLowPriority = '%(\=\>|\@?-\>|[=%,;]|each\*?|where|with)'

let s:operatorBadMinus = '%(' . s:identifierEnd . '@<=-' . s:identifierEnd . ')'
let s:operator = s:operatorBadMinus . '@!%(' . s:opCharacter . '+|<' . s:opWord . '>' . s:opCharacter . '*)'
let s:operatorBinary = s:operatorBadMinus . '@!%(' . s:opCharacter . '+|<' . s:opWordBinary . '>' . s:opCharacter . '*)'

execute 'syntax match egOperator /\v' . s:operator . '/'

" We don't (necessarily) want to highlight a standalone colon as an operator
execute 'syntax match egControlColon /\v' . s:operator . '@<!:' . s:opCharacter . '@!/ contained containedin=egOperator'


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Groups (delimited)

syntax match egGroupDelimiter /\v[(){}[\]]/
for pair in s:pairs
  execute 'syntax region egGroup matchgroup=egGroupDelimiter '
    \ . 'start=/\v\' . pair[0] . '/ end=/\v\' . pair[1] . '/ contains=@egSyntax'
endfor


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key-token, key-colon, key-indent forms

" needs to be wrapped in < > where used
execute "let s:symbol = '" . s:operator . '@!' . s:identifier . "'"

" key token
let s:token = '%(' . s:operator . s:opCharacter . '@!\S|' . s:operatorBinary . '@!' . s:identifier . '|[0-9''"`.({\[])'
execute 'syntax match egStatement /\v<' . s:symbol . '>\ze%(\s+' . s:token . ')@=/'

" key:, preceded by a low-priority operator
execute 'syntax match egStatement /\v%(%(^|' . s:nonOpCharacter . ')' . s:opLowPriority . '\s*)@<=<' . s:symbol . '>\ze:@=/'

" key:, preceded by an assignment operator
execute 'syntax match egStatement /\v%(\=\s*)@<=<' . s:symbol . '>\ze:@=/'

" key:, not preceded by an operator
execute 'syntax match egStatement /\v%(%(^|;)\s*)@<=<' . s:symbol . '>\ze:@=/'

" key(newline)(indent)(something)
execute 'syntax match egStatement /\v%(^(\s*))@<=<' . s:symbol . '>\ze%(\s*%(\;\;.*$)?\n\1\s+)@=/'


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Standalone keywords

""" JavaScript

syntax keyword egBoolean true false
syntax keyword egConstant null undefined

" values
syntax keyword egBuiltin __dirname __filename arguments console exports global
syntax keyword egBuiltin Infinity Intl JSON Math module NaN process Reflect
" functions
syntax keyword egBuiltin clearImmediate clearInterval clearTimeout
syntax keyword egBuiltin decodeURI decodeURIComponent
syntax keyword egBuiltin encodeURI encodeURIComponent escape eval
syntax keyword egBuiltin isFinite isNaN parseFloat parseInt
syntax keyword egBuiltin setImmediate setInterval setTimeout unescape
" base objects
syntax keyword egType Boolean Date Function Map Number Object
syntax keyword egType Promise Proxy RegExp Set String Symbol WeakMap WeakSet
" array objects
syntax keyword egType Array Float32Array Float64Array Int8Array Int16Array Int32Array
syntax keyword egType Uint8Array Uint8ClampedArray Uint16Array Uint32Array
" buffers
syntax keyword egType ArrayBuffer DataView
" error objects
syntax keyword egType Error EvalError RangeError ReferenceError
syntax keyword egType SyntaxError TypeError URIError


""" Earl Grey

" Errors
syntax keyword egType E ENode

" Suggested by Olivier
syntax keyword egKeyword await break chain continue else expr-value match return yield

" Others
syntax keyword egKeyword if pass


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions

for pair in s:pairs
  execute 'syntax match egFunction '
    \ . '/\v%(%(^|;)%(\s*%(async|gen|macro|method))?\s*)@<=<' . s:identifier . '>'
    \ . '\ze%(\s*'
    \ . '\' . pair[0] . '%(\' . pair[0] . '.*\' . pair[1] . '|[^' . pair[1] . '])*' . '\' . pair[1]
    \ . '\s*\=\s*$)@=/'
endfor


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Operator-Identifier combinations

execute 'syntax match egDotString /\v%(^|[([{,;]|\s)@<=\.<' . s:identifier . '>/'

" #foo shorthand (not the same thing as a JS Symbol)
execute 'syntax match egSymbol /\v%(^|[([{,;]|\s)@<=\#<' . s:identifier . '>/'


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Clusters

syntax cluster egSyntax contains=
  \egBoolean,egBuiltin,egCodeQuote,egComment,egConstant,egDotString,
  \egFunction,egGroup,egKeyword,egNumber,egOperator,
  \egStatement,egString,egStringTemplate,egSymbol,egType


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Highlight links

highlight default link egBoolean Boolean
highlight default link egBuiltin Identifier
highlight default link egCodeQuoteDelimiter Delimiter
highlight default link egComment Comment
highlight default link egConstant Constant
highlight default link egDotString Constant
highlight default link egFunction Function
highlight default link egInterpolationDelimiter Delimiter
highlight default link egKeyword Keyword
highlight default link egNumber Number
highlight default link egOperator Operator
highlight default link egRadixPrefix Type
highlight default link egStatement Statement
highlight default link egString String
highlight default link egStringTemplate String
highlight default link egSymbol Identifier
highlight default link egType Type
