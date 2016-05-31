if exists("b:current_syntax")
  finish
endif

setlocal iskeyword=48-57,a-z,A-Z,_,$,-

syntax sync fromstart

let pairs = ['()', '[]', '{}']


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


let number = '%(\d+[rR][a-zA-Z0-9_]+%(\.[a-zA-Z0-9_]+)?|\d[0-9_]*%(\.\d+)?)'
execute 'syntax match egNumber /\v<' . number . '>/'
syntax match egRadixPrefix /\v<\d+[rR]/ contained containedin=egNumber


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Identifiers

let identifierStart = '[a-zA-Z$_]'
let identifierMid = '[a-zA-Z$_0-9-]'
let identifierEnd = '[a-zA-Z$_0-9]'
" needs to be wrapped in < > where used
execute "let identifier = '" . identifierStart . '%(-?' . identifierEnd . ")*'"


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Operators

" An operator can be any of these characters:
let opCharacter = '[!#%&*+./:<=>?@\\^|~-]'
let nonOpCharacter = '[^!#%&*+./:<=>?@\\^|~-]'

" or any of these words:
let opWord = '%(as|and|each|in|is|mod|not|of|or|when|where|with)'
let opWordBinary = '%(as|and|each|in|is|mod|of|or|when|where|with)'

" although these are "low priority" for standalone control forms:
let opLowPriority = '%(\=\>|\@?-\>|[=%,;]|each\*?|where|with)'

let operatorBadMinus = '%(' . identifierEnd . '@<=-' . identifierEnd . ')'
let operator = operatorBadMinus . '@!%(' . opCharacter . '+|<' . opWord . '>' . opCharacter . '*)'
let operatorBinary = operatorBadMinus . '@!%(' . opCharacter . '+|<' . opWordBinary . '>' . opCharacter . '*)'

execute 'syntax match egOperator /\v' . operator . '/'

" We don't (necessarily) want to highlight a standalone colon as an operator
execute 'syntax match egControlColon /\v' . operator . '@<!:' . opCharacter . '@!/ contained containedin=egOperator'


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Groups (delimited)

syntax match egGroupDelimiter /\v[(){}[\]]/
for pair in pairs
  execute 'syntax region egGroup matchgroup=egGroupDelimiter '
    \ . 'start=/\v\' . pair[0] . '/ end=/\v\' . pair[1] . '/ contains=@egSyntax'
endfor


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key-token, key-colon, key-indent forms

" needs to be wrapped in < > where used
execute "let symbol = '" . operator . '@!' . identifier . "'"

" key token
let token = '%(' . operator . opCharacter . '@!\S|' . operatorBinary . '@!' . identifier . '|[0-9''"`.({\[])'
execute 'syntax match egStatement /\v<' . symbol . '>\ze%(\s+' . token . ')@=/'

" key:, preceded by a low-priority operator
execute 'syntax match egStatement /\v%(%(^|' . nonOpCharacter . ')' . opLowPriority . '\s*)@<=<' . symbol . '>\ze:@=/'

" key:, preceded by an assignment operator
execute 'syntax match egStatement /\v%(\=\s*)@<=<' . symbol . '>\ze:@=/'

" key:, not preceded by an operator
execute 'syntax match egStatement /\v%(%(^|;)\s*)@<=<' . symbol . '>\ze:@=/'

" key(newline)(indent)(something)
execute 'syntax match egStatement /\v%(^(\s*))@<=<' . symbol . '>\ze%(\s*%(\;\;.*$)?\n\1\s+)@=/'


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Standalone keywords

""" JavaScript

syntax keyword egBoolean true false
syntax keyword egConstant null undefined

" values
syntax keyword egBuiltin arguments Infinity JSON Math NaN Reflect
" functions
syntax keyword egBuiltin decodeURI decodeURIComponent encodeURI encodeURIComponent escape eval
syntax keyword egBuiltin isFinite isNaN parseFloat parseInt unescape
" base objects
syntax keyword egType Boolean Date Function Generator GeneratorFunction Map Number Object
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

for pair in pairs
  execute 'syntax match egFunction '
    \ . '/\v%(%(^|;)%(\s*%(async|gen|macro|method))?\s*)@<=<' . identifier . '>'
    \ . '\ze%(\s*'
    \ . '\' . pair[0] . '%(\' . pair[0] . '.*\' . pair[1] . '|[^' . pair[1] . '])*' . '\' . pair[1]
    \ . '\s*\=\s*$)@=/'
endfor


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Operator-Identifier combinations

execute 'syntax match egDotString /\v%(^|[([{,;]|\s)@<=\.<' . identifier . '>/'

" #foo shorthand (not the same thing as a JS Symbol)
execute 'syntax match egSymbol /\v%(^|[([{,;]|\s)@<=\#<' . identifier . '>/'


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
