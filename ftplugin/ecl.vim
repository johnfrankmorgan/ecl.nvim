setlocal shiftwidth=2
setlocal softtabstop=2
setlocal commentstring=//\ %s
setlocal complete+=k

let ecl_dictionary = expand('<sfile>:p:h:h') . '/completion/ecl.txt'
execute printf('setlocal dictionary+=%s', ecl_dictionary)

command! -nargs=? EclSyntaxCheck lua require('ecl.syntax').check('<args>')
command! -nargs=? EclRun lua require('ecl.runner').run('<args>')
command! -nargs=0 EclCloseResults bufdo! if exists('b:ecl_results') | bwipeout! | endif
