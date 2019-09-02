## General settings.
set-option global ui_options ncurses_status_on_top=true ncurses_assistant=off
set-option global tabstop 4
set-option global indentwidth 4
# keep space around cursor
set-option global scrolloff 2,2
# fix for https://github.com/mawww/kakoune/issues/2020
# also see: https://github.com/mawww/kakoune/blob/master/doc/pages/faq.asciidoc#can-i-disable-auto-indentation-completely-
# set-option global disabled_hooks .*-trim-indent

# Grep
# try %{ set global grepcmd 'ag --filename --column --ignore tags --ignore build --ignore buildDebug' }
evaluate-commands %sh{
    [ -n "$(command -v rg)" ] && printf "%s\n" "set-option global grepcmd 'rg -L --with-filename --column'"
}

# Use main client as jumpclient
set-option global jumpclient client0

# colorscheme github-custom
# colorscheme tomorrow-night-mod
# colorscheme gruvbox
colorscheme base16-tomorrow

hook global WinCreate .* %{
    try %{
        add-highlighter buffer/numbers    number-lines -hlcursor -separator ' '
        add-highlighter buffer/matching   show-matching
        add-highlighter buffer/show-whitespaces show-whitespaces -tab '›' -tabpad '⋅' -spc ' ' -nbsp '⍽'
        add-highlighter buffer/wrap       wrap -word -indent -marker ↪
        add-highlighter buffer/VisibleWords regex \b(?:FIXME|TODO|XXX)\b 0:default+rb
    }

    # show-trailing-whitespace-enable; face window TrailingWhitespace default,red
    # enable tab complete in insert mode
    tab-completion-enable
    search-highlighting-enable
}

# escape hatch
# https://github.com/mawww/kakoune/wiki/Avoid-the-escape-key
hook global InsertChar \. %{ try %{
    exec -draft hH <a-k>,\.<ret> d
    exec <esc>
}}

# Aliases
# ‾‾‾‾‾‾‾
alias global u enter-user-mode
alias global h doc

## Maps.
map -docstring 'select whole buffer'         global normal '%'       '<c-s>%'
map -docstring 'space as leader'             global normal '<space>' ','
map -docstring 'drop all but main selection' global normal 'q'       '<space>'
map -docstring 'drop main selection'         global normal '<c-q>'   '<a-space>'
map -docstring 'toggle case'                 global normal '~'       '<a-`>'
map -docstring 'comment line'                global normal '#'       ': comment-line<ret>'
map -docstring 'comment block'               global normal '<a-#>'   ': comment-block<ret>'
map -docstring 'save buffer'                 global normal '<F2>'    ': w<ret>'

# Avoid escape key
map -docstring "avoid escape key"            global normal '<c-g>' '<esc>'
map -docstring "avoid escape key"            global prompt '<c-g>' '<esc>'
map -docstring "avoid escape key"            global insert '<c-g>' '<esc>'

# map global normal '<minus>' ';'
# map global normal '<a-minus>' '<a-;>'

# swap g and u
# map global normal g u
# map global normal u g
# map global normal G U
# map global normal U G

map global normal '<plus>' '5j'
map global normal '<a-plus>' '5k'
# map global normal '<a-space>' 'vv'

# https://github.com/mawww/kakoune/wiki/Selections#how-to-make-x-select-lines-downward-and-x-select-lines-upward
map global normal x ': extend-line-down %val{count}<ret>'
map global normal X ': extend-line-up %val{count}<ret>'

# stop c and d from yanking
# map global normal d <a-d>
# map global normal c <a-c>
# map global normal <a-d> ''
# map global normal <a-c> ''

map global normal <'> <">
map global normal <"> <q>

# https://github.com/mawww/kakoune/issues/1791
# map global object q Q -docstring 'double quote string'
# map global object Q q -docstring 'single quote string'
# map global view u t -docstring 'same as t'
map global view e jv
map global view y kv
# map global view d '<esc>5jv'
# map global view u '<esc>5kv'

## Some User
map -docstring 'command prompt'    global user '<space>' ':'
map -docstring 'Reload buffer'     global user 'R'       ': e!<ret>'
map -docstring 'man'               global user 'k'       ': smart-select word; man-selection-with-count<ret>'
map -docstring 'selection hull'    global user 'h'       ': hull<ret>'
map -docstring 'tmux-focus'        global user 'o'       ': tmux-focus '
map -docstring 'enter-user-mode'   global user 'u'       ':u '
map -docstring 'quit!'             global user 'Q'       ':q!<ret>'
map -docstring 'grep next'         global user ']'       ': grep-next-match<ret>'
map -docstring 'grep prev'         global user '['       ': grep-previous-match<ret>'

map global normal '0' ': zero select-or-add-cursor<ret>'
# map global normal <*> ': smart-select word<ret>*'
# map global normal '%' ': select-or-add-cursor<ret>'

## Spell
declare-user-mode spell
map -docstring "next error"      global spell 'n' ': spell-next<ret>'
map -docstring "replace word"    global spell 's' '_: spell-replace<ret>'
map -docstring "exit spell mode" global spell 'c' ': spell-clear<ret>'
map -docstring "spell mode"      global user  'S' ': enter-user-mode spell; spell en-US<ret>'

declare-user-mode search
map -docstring 'regex disabled'   global search '/' ': exec /<ret>\Q\E<left><left>'
map -docstring 'case insensitive' global search 'i' '/(?i)'
map -docstring 'select all'       global search 'a' ': smart-select word<ret>*%s<ret>'
map -docstring 'search mode'      global user   '/' ': enter-user-mode search<ret>'

# https://discuss.kakoune.com/t/rfr-best-way-to-add-a-toggle/580/2
declare-user-mode toggle
map -docstring 'toggle' global user 't' ': enter-user-mode toggle<ret>'
map -docstring 'colorscheme' global toggle 'c' ': enter-user-mode themes<ret>'
# map -docstring 'search highlight' global toggle  's' ': search-highlighting-enable<ret>'

declare-user-mode themes
map -docstring 'grayscale-light' global themes 'g' ': colorscheme base16-grayscale-light<ret>'
map -docstring 'color-light' global themes 'c' ': colorscheme base16-tomorrow<ret>'

## Goto
map -docstring 'line end'                       global goto 'u'      'l'
map -docstring 'switch to [+] buffer'           global goto '<plus>' '<esc>: switch-to-modified-buffer<ret>'
map -docstring "file (non-recursive)"           global goto '<a-f>' '<esc>gf'
map -docstring "file (recursive)"               global goto 'f'     '<esc>: smart-select WORD; search-file %val{selection}<ret>'
map -docstring "search tag in current file"     global goto '['     '<esc><c-s>: smart-select word; symbol<ret>'
map -docstring "search tag in global tags file" global goto ']'     '<esc><c-s>: smart-select word; ctags-search<ret>'

## System clipboard
declare-user-mode clipboard
map -docstring 'yank to sysclipboard'                global clipboard 'y' '<a-|>pbcopy<ret>'
map -docstring 'paste (insert) from sysclipboard'    global clipboard 'P' '!pbpaste<ret>'
map -docstring 'paste (append) from sysclipboard'    global clipboard 'p' '<a-!>pbpaste<ret>'
map -docstring 'replace selection with sysclipboard' global clipboard 'r' '|pbpaste<ret>'
map -docstring 'import from sysclipboard'            global clipboard 'i' ': clipboard-import<ret>'
map -docstring 'export to sysclipboard'              global clipboard 'e' ': clipboard-export<ret>'
map -docstring 'tmux-clipboard menu'                 global clipboard 't' ': enter-user-mode tmux-clipboard<ret>'
map -docstring 'clipboard mode'                      global user      'y' ': enter-user-mode clipboard<ret>'

declare-user-mode tmux-clipboard
# map -docstring 'yank to tmux buffer'                global tmux-clipboard 'y' '<a-|>tmux setb -b kak "$kak_selection"<ret>'
map -docstring 'yank to tmux buffer'                global tmux-clipboard 'y' '<a-|>tmux setb "$kak_selection"<ret>'
map -docstring 'paste (insert) from tmux buffer'    global tmux-clipboard 'P' '!tmux showb<ret>'
map -docstring 'paste (append) from tmux buffer'    global tmux-clipboard 'p' '<a-!>tmux showb<ret>'
map -docstring 'replace selection with tmux buffer' global tmux-clipboard 'r' '|tmux showb<ret>'

declare-user-mode anchor
# map -docstring 'reduce to cursor'           global anchor '.'       ';'
# map -docstring 'reduce to anchor'           global anchor ';'       '<a-;>;'
map -docstring 'flip cursor and anchor'     global anchor '.'       '<a-;>'
map -docstring 'ensure anchor after cursor' global anchor 'h'       '<a-:><a-;>'
map -docstring 'ensure cursor after anchor' global anchor 'u'       '<a-:>'
map -docstring 'select cursor and anchor'   global anchor 's'       '<a-S>'
map -docstring 'reduce and insert'          global anchor 'i'       '<esc>;i'
map -docstring 'reduce and append'          global anchor 'a'       '<esc>;a'
map -docstring 'slice by word'              global anchor ','       ': slice-by-camel<ret>'
map -docstring 'shift selection left'       global anchor '<lt>'    ': shift-selection-left;enter-user-mode anchor<ret>'
map -docstring 'shift selection right'      global anchor '<gt>'    ': shift-selection-right;enter-user-mode anchor<ret>'
map -docstring 'shrink selection'           global anchor '<minus>' ': shrink-selection<ret>'
map -docstring 'enlarge selection'          global anchor '<plus>'  ': enlarge-selection<ret>'
map -docstring 'anchor mode'                global normal ','       ': enter-user-mode anchor<ret>'
map -docstring 'anchor mode (lock)'         global normal '<a-,>'   ': enter-user-mode -lock anchor<ret>'

declare-user-mode echo-mode
map -docstring 'opt'                  global echo-mode 'o' ':echo %opt{}<left>'
map -docstring 'opt debug'            global echo-mode 'O' ':echo -debug %opt{}<left>'
map -docstring 'reg'                  global echo-mode 'r' ':echo %reg{}<left>'
map -docstring 'reg debug'            global echo-mode 'R' ':echo -debug %reg{}<left>'
map -docstring 'set @ reg'            global echo-mode '@' ':set-register @ ''''<left>'
map -docstring 'sh'                   global echo-mode 's' ':echo %sh{}<left>'
map -docstring 'sh debug'             global echo-mode 'S' ':echo -debug %sh{}<left>'
map -docstring 'val'                  global echo-mode 'v' ':echo %val{}<left>'
map -docstring 'val debug'            global echo-mode 'V' ':echo -debug %val{}<left>'
map -docstring 'ModeChange debug on'  global echo-mode 'm' ': hook -group echo-mode window ModeChange .* %{ echo -debug ModeChange %val{hook_param} }<ret>'
map -docstring 'ModeChange debug off' global echo-mode 'M' ': rmhooks window echo-mode<ret>'
map -docstring 'echo mode'            global user      'e' ': enter-user-mode echo-mode<ret>'

declare-user-mode tig
map global tig 'h' %{: tmux-terminal-window tig %val{buffile}<ret>} -docstring "tig buffile history"
map global tig 'b' %{: tmux-terminal-window tig blame "+%val{cursor_line}" -- %val{buffile}<ret>} -docstring "tig blame"
map global tig 't' %{: tmux-terminal-window tig status<ret>} -docstring "tig status (for committing)"

declare-user-mode git
map global git 'g' ': git show-diff<ret>'            -docstring 'show gutter'
map global git 'G' ': git-hide-diff<ret>'            -docstring 'hide gutter'
map global git 's' ': git status<ret>'               -docstring 'status'
map global git 'b' ': git-toggle-blame<ret>'         -docstring 'blame (toggle)'
map global git 'l' ': git log<ret>'                  -docstring 'log'
map global git 'c' ': git commit<ret>'               -docstring 'commit'
map global git 'd' ': git diff<ret>'                 -docstring 'diff'
map global git 'w' ': git-show-blamed-commit<ret>'   -docstring 'show blamed commit'
map global git 'L' ': git-log-lines<ret>'            -docstring 'log blame'
map global git 't' '<esc>: enter-user-mode tig<ret>' -docstring 'tig mode'
map global user 'g' ': enter-user-mode git<ret>' -docstring 'git mode'

declare-user-mode lang-mode
map global user 'm' ': enter-user-mode lang-mode<ret>' -docstring 'lang mode'

# Insert mode
# <c-o>    ; # silent: stop completion
# <c-x>    ; # complete here
# <c-v>    ; # raw insert, use vim binding
map global insert '<c-y>' '<a-;>!pbpaste<ret>'
map global insert '<a-g>' '<a-;>'

# https://github.com/mawww/kakoune/wiki/Selections#how-to-make-word-keys-discern-camelcase-or-snake_case-parts
# define-command -hidden select-prev-word-part %{
#   exec <a-/>[A-Z][a-z]+|[A-Z]+|[a-z]+<ret>
# }
# define-command -hidden select-next-word-part %{
#   exec /[A-Z][a-z]+|[A-Z]+|[a-z]+<ret>
# }
# define-command -hidden extend-prev-word-part %{
#   exec <a-?>[A-Z][a-z]+|[A-Z]+|[a-z]+<ret>
# }
# define-command -hidden extend-next-word-part %{
#   exec ?[A-Z][a-z]+|[A-Z]+|[a-z]+<ret>
# }

# Scratch buffer
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

## Delete the `*scratch*' buffer as soon as another is created, but only if it's empty
## ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
hook global BufCreate '^\*scratch\*$' %{
    execute-keys -buffer *scratch* '%d'
    hook -once -always global BufCreate '^(?!\*scratch\*).*$' %{ try %{
        # throw if the buffer has something other than newlines in the beginning of lines
        execute-keys -buffer *scratch* '%s\A\n\z<ret>'
        delete-buffer *scratch*
    }}
}
