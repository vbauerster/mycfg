## General settings.
# set-option global ui_options ncurses_set_title=false
set-option global ui_options ncurses_status_on_top=true ncurses_assistant=off
set-option global tabstop 4
set-option global indentwidth 4
# keep space around cursor
set-option global scrolloff 2,2
# fix for https://github.com/mawww/kakoune/issues/2020
# also see: https://github.com/mawww/kakoune/blob/master/doc/pages/faq.asciidoc#can-i-disable-auto-indentation-completely-
# set-option global disabled_hooks .*-trim-indent

# Grep
evaluate-commands %sh{
    [ -n "$(command -v rg)" ] && printf "%s\n" "set global grepcmd 'rg -L --with-filename --column'"
}

# Use main client as jumpclient
# set-option global jumpclient client0

colorscheme base16-tomorrow

hook global WinCreate .* %{
    try %{
        # add-highlighter buffer/numbers    number-lines -hlcursor
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

hook global WinSetOption filetype=grep %{
    remove-highlighter buffer/numbers
    remove-highlighter buffer/show-whitespaces
    remove-highlighter buffer/wrap
}

# escape hatch
# https://github.com/mawww/kakoune/wiki/Avoid-the-escape-key
hook global InsertChar \. %{ try %{
    execute-keys -draft hH <a-k>\Q,.\E<ret> d
    execute-keys <esc>
}}

# Aliases
# ‾‾‾‾‾‾‾
alias global u enter-user-mode
alias global h doc

## Maps.
# map -docstring "align cusors"              global normal '='       '&'
# map -docstring "copy indentation"          global normal '<a-=>'   '<a-&>'
map -docstring "clear anchor"              global normal '<minus>' ';'
map -docstring "flip cursor and anchor"    global normal '<a-minus>' '<a-;>'
map -docstring "extend sel to whole lines" global normal '}'       '<a-x>'
map -docstring "crop sel to whole lines"   global normal '<a-}>'   '<a-X>'
map -docstring "extend to surrounding obj" global normal '<plus>'  '}'
map -docstring "extend to inner surr obj"  global normal '<a-plus>' '<a-}>'
map -docstring "extend up"                 global normal '<a-x>'   'J'
map -docstring "extend down"               global normal '<a-X>'   'K'
map -docstring "select whole buffer"       global normal '%'       '<c-s>%'
map -docstring "space as leader"           global normal '<space>' ','
map -docstring "drop all but main sel"     global normal 'q'       '<space>'
map -docstring "drop main selection"       global normal '<c-q>'   '<a-space>'
map -docstring "comment line"              global normal '#'       ': comment-line<ret>'
map -docstring "save buffer"               global normal '<F2>'    ': w<ret>'
# map -docstring "<a-i>"                     global normal '<a-4>'   '<a-i>'
# map -docstring "<a-a>"                     global normal '<a-6>'   '<a-a>'

# map -docstring "choose register"     global normal <esc> <">
# map -docstring "choose register"     global normal <a-space> <">
map -docstring "record macro"        global normal <a-@> <Q>
map -docstring "play recorded macro" global normal <@> <q>

# Avoid escape key
map -docstring "avoid escape key" global normal '<c-g>' '<esc>'
map -docstring "avoid escape key" global prompt '<c-g>' '<esc>'
map -docstring "avoid escape key" global insert '<c-g>' '<esc>'

map global normal '0' ': zero select-or-add-cursor<ret>'
# map global normal <*> ': smart-select word<ret>*'
# map global normal '%' ': select-or-add-cursor<ret>'

map global normal 'J' 'C<space>'
map global normal 'K' '<a-C><space>'

# https://github.com/mawww/kakoune/wiki/Selections#how-to-make-x-select-lines-downward-and-x-select-lines-upward
map global normal x ': extend-line-down %val{count}<ret>'
map global normal X ': extend-line-up %val{count}<ret>'

# stop c and d from yanking
# map global normal d <a-d>
# map global normal c <a-c>
# map global normal <a-d> d
# map global normal <a-c> c

# https://github.com/mawww/kakoune/issues/1791
# map global object Q q -docstring 'single quote string'
map global object q '"' -docstring 'double quote string'
map global view e jv         -docstring "scroll down"
map global view y kv         -docstring "scroll up"
map global view j <esc>3jv   -docstring "3j (sticky)"
map global view k <esc>3kv   -docstring "3k (sticky)"
map global view J <esc>6jv   -docstring "6j (sticky)"
map global view K <esc>6kv   -docstring "6k (sticky)"
map global view i <esc><a-i> -docstring "<a-i>"
map global view a <esc><a-a> -docstring "<a-a>"

## Some User
map -docstring "command prompt"  global user '<space>' ':'
map -docstring "choose register" global user <'> <">
map -docstring "Reload buffer"   global user 'R'       ': e!<ret>'
map -docstring "man"             global user 'k'       ': smart-select w; man-selection-with-count<ret>'
map -docstring "tmux-focus"      global user 'o'       ': tmux-focus '
map -docstring "enter-user-mode" global user 'u'       ':u '
map -docstring "quit!"           global user 'Q'       ':q!<ret>'
map -docstring "grep next"       global user ']'       ': grep-next-match<ret>'
map -docstring "grep prev"       global user '['       ': grep-previous-match<ret>'
map -docstring "format buffer"   global user '='       ': format-buffer<ret>'
map -docstring "tabs to spaces"  global user <@> <@>
map -docstring "spaces to tabs"  global user <a-@> <a-@>
# map -docstring "null reg"        global user '_'       '"_'

## Spell
declare-user-mode spell
map -docstring "next error"      global spell 'n' ': spell-next<ret>'
map -docstring "replace word"    global spell 's' '_: spell-replace<ret>'
map -docstring "exit spell mode" global spell 'c' ': spell-clear<ret>'
map -docstring "spell mode"      global user  'S' ': enter-user-mode spell; spell en-US<ret>'

declare-user-mode search
map -docstring "regex disabled"   global search '/' ': exec /<ret>\Q\E<left><left>'
map -docstring "case insensitive" global search 'i' '/(?i)'
map -docstring "select all"       global search 'a' ': smart-select w<ret>*%s<ret>'
map -docstring "search mode"      global user   '/' ': enter-user-mode search<ret>'

# https://discuss.kakoune.com/t/rfr-best-way-to-add-a-toggle/580/2
declare-user-mode toggle
map -docstring "colorscheme"   global toggle 'c' ': enter-user-mode themes<ret>'
map -docstring "buffer toggle" global toggle 'b' ': enter-user-mode buffer-toggle<ret>'
map -docstring "toggle"        global user 't' ': enter-user-mode toggle<ret>'
# map -docstring 'search highlight' global toggle  's' ': search-highlighting-enable<ret>'

declare-user-mode buffer-toggle
map -docstring "set filetype"    global buffer-toggle 'b' ':set buffer filetype '
map -docstring "set tabstop"     global buffer-toggle '<tab>' ':set buffer tabstop '
map -docstring "set indentwidth" global buffer-toggle 'i' ':set buffer indentwidth '

declare-user-mode themes
map -docstring "grayscale-light" global themes 'g' ': colorscheme base16-grayscale-light<ret>'
map -docstring "color-light"     global themes 'c' ': colorscheme base16-tomorrow<ret>'

## Goto
map -docstring "window top"                     global goto 'k'     't'
map -docstring "window bottom"                  global goto 'j'     'b'
map -docstring "buffer bottom"                  global goto 'G'     'j'
map -docstring "extend to line end"             global goto '}'     '<esc><a-:>Gl'
map -docstring "extend to line begin"           global goto '{'     '<esc><a-:>;Gh'
map -docstring "extend to line non-blank"       global goto '<tab>' '<esc><a-:>;Gi'
map -docstring "file (recursive)"               global goto 'f'     '<esc>: smart-select-file; search-file %val{selection}<ret>'
map -docstring "file (non-recursive)"           global goto '<a-f>'  '<esc>gf'
map -docstring "search tag in current file"     global goto '['      '<esc><c-s>: smart-select w; symbol<ret>'
map -docstring "search tag in global tags file" global goto ']'      '<esc><c-s>: smart-select w; ctags-search<ret>'
# map -docstring 'switch to [+] buffer'         global goto '<plus>' '<esc>: switch-to-modified-buffer<ret>'
unmap global goto t
unmap global goto b

## System clipboard
declare-user-mode clipboard
map -docstring "yank to sysclipboard"                global clipboard 'y' '<a-|>pbcopy<ret>'
map -docstring "paste (insert) from sysclipboard"    global clipboard 'P' '!pbpaste<ret>'
map -docstring "paste (append) from sysclipboard"    global clipboard 'p' '<a-!>pbpaste<ret>'
map -docstring "replace selection with sysclipboard" global clipboard 'r' '|pbpaste<ret>'
map -docstring "import from sysclipboard"            global clipboard 'm' ': clipboard-import<ret>'
map -docstring "export to sysclipboard"              global clipboard 'x' ': clipboard-export<ret>'
map -docstring "tmux-clipboard menu"                 global clipboard 't' ': enter-user-mode tmux-clipboard<ret>'
map -docstring "clipboard mode"                      global user      'y' ': enter-user-mode clipboard<ret>'

declare-user-mode tmux-clipboard
# map -docstring 'yank to tmux buffer'                global tmux-clipboard 'y' '<a-|>tmux setb -b kak "$kak_selection"<ret>'
map -docstring "yank to tmux buffer"                global tmux-clipboard 'y' '<a-|>tmux setb "$kak_selection"<ret>'
map -docstring "paste (insert) from tmux buffer"    global tmux-clipboard 'P' '!tmux showb<ret>'
map -docstring "paste (append) from tmux buffer"    global tmux-clipboard 'p' '<a-!>tmux showb<ret>'
map -docstring "replace selection with tmux buffer" global tmux-clipboard 'r' '|tmux showb<ret>'

declare-user-mode anchor
map -docstring "slice by word"              global anchor ','       ': slice-by-word<ret>'
map -docstring "flip cursor and anchor"     global anchor '.'       '<a-;>'
map -docstring "selection hull"             global anchor 'u'       ': selection-hull<ret>'
map -docstring "ensure anchor after cursor" global anchor 'h'       '<a-:><a-;>'
map -docstring "ensure cursor after anchor" global anchor 'l'       '<a-:>'
map -docstring "select cursor and anchor"   global anchor 's'       '<a-S>'
map -docstring "reduce and insert"          global anchor 'c'       '<esc>;i'
map -docstring "reduce and append"          global anchor 'a'       '<esc>;a'
map -docstring "next selection (centered)"  global anchor 'n'       '<esc>nvv: enter-user-mode anchor<ret>'
map -docstring "prev selection (centered)"  global anchor 'p'       '<esc><a-n>vv: enter-user-mode anchor<ret>'
map -docstring "anchor mode"                global normal ','       ': enter-user-mode anchor<ret>'
# map -docstring "anchor mode (lock)"         global normal '<a-,>'   ': enter-user-mode -lock anchor<ret>'

declare-user-mode echo-mode
map -docstring "opt"                  global echo-mode 'o' ':echo %opt{}<left>'
map -docstring "opt debug"            global echo-mode 'O' ':echo -debug %opt{}<left>'
map -docstring "reg"                  global echo-mode 'r' ':echo %reg{}<left>'
map -docstring "reg debug"            global echo-mode 'R' ':echo -debug %reg{}<left>'
map -docstring "set @ reg"            global echo-mode '@' ':set-register @ ''''<left>'
map -docstring "sh"                   global echo-mode 's' ':echo %sh{}<left>'
map -docstring "sh debug"             global echo-mode 'S' ':echo -debug %sh{}<left>'
map -docstring "val"                  global echo-mode 'v' ':echo %val{}<left>'
map -docstring "val debug"            global echo-mode 'V' ':echo -debug %val{}<left>'
map -docstring "ModeChange debug on"  global echo-mode 'm' ': hook -group echo-mode window ModeChange .* %{ echo -debug ModeChange %val{hook_param} }<ret>'
map -docstring "ModeChange debug off" global echo-mode 'M' ': rmhooks window echo-mode<ret>'
map -docstring "echo mode"            global user      'e' ': enter-user-mode echo-mode<ret>'

declare-user-mode tig
map -docstring "tig buffile history"         global tig 'h' %{: tmux-terminal-window tig %val{bufname}<ret>}
map -docstring "tig blame"                   global tig 'b' %{: tmux-terminal-window tig blame "+%val{cursor_line}" -- %val{bufname}<ret>}
map -docstring "tig status (for committing)" global tig 't' %{: tmux-terminal-window tig status<ret>}

declare-user-mode git
map -docstring "show gutter"        global git 'g' ': git show-diff<ret>'
map -docstring "hide gutter"        global git 'G' ': git-hide-diff<ret>'
map -docstring "status"             global git 's' ': git status<ret>'
map -docstring "blame (toggle)"     global git 'b' ': git-toggle-blame<ret>'
map -docstring "log"                global git 'l' ': git log<ret>'
map -docstring "commit"             global git 'c' ': git commit<ret>'
map -docstring "diff"               global git 'd' ': git diff<ret>'
map -docstring "show blamed commit" global git 'w' ': git-show-blamed-commit<ret>'
map -docstring "log blame"          global git 'L' ': git-log-lines<ret>'
map -docstring "tig mode"           global git 't' '<esc>: enter-user-mode tig<ret>'
map -docstring "git mode"           global user 'g' ': enter-user-mode git<ret>'

declare-user-mode lang-mode
map global user 'm' ': enter-user-mode lang-mode<ret>' -docstring "lang mode"

# Insert mode
# <c-o>    ; # silent: stop completion
# <c-x>    ; # complete here
# <c-v>    ; # raw insert, use vim binding
map global insert '<c-y>' '<a-;>!pbpaste<ret>'
map global insert '<c-a>' '<a-;>'
map global insert '<a-minus>' '<a-;>'
map global insert '<c-e>' '<esc>A'
map global insert '<a-o>' '<c-o><c-x>l'
map global insert '<a-h>' '<a-;>h'
map global insert '<a-l>' '<a-;>l'
map global insert '<a-c>' '<esc><a-c>'
map global insert '<a-d>' '<esc><a-d>'
map global insert '<a-\>' '\n'

# Hooks
# ‾‾‾‾‾

## Editorconfig
## ‾‾‾‾‾‾‾‾‾‾‾‾
# hook global BufOpenFile .* editorconfig-load
# hook global BufNewFile  .* editorconfig-load

## Git
## ‾‾‾
hook global BufOpenFile .* %{
    evaluate-commands %sh{
        if [ $(git rev-parse --show-toplevel 2>/dev/null) ]; then
            echo "hook buffer -group fly-git NormalIdle .* %{ git show-diff }"
            echo "hook buffer -group fly-git InsertIdle .* %{ git show-diff }"
        fi
    }
}

# Custom text objects
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
map global object w 'c\s,\s<ret>' -docstring "select between whitespace"

# Scratch buffer
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

## Delete the `*scratch*' buffer as soon as another is created, but only if it's empty
## ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
# hook global BufCreate '^\*scratch\*$' %{
#     execute-keys -buffer *scratch* '%d'
#     hook -once -always global BufCreate '^(?!\*scratch\*).*$' %{ try %{
#         # throw if the buffer has something other than newlines in the beginning of lines
#         execute-keys -buffer *scratch* '%s\A\n\z<ret>'
#         delete-buffer *scratch*
#     }}
# }

# hook -group pairwise global InsertChar \) %{ try %{
#     execute-keys -draft hH <a-k>\Q()\E<ret>
#     execute-keys '<a-;>h'
# }}
# hook -group pairwise global InsertChar \} %{ try %{
#     execute-keys -draft hH <a-k>\Q{}\E<ret>
#     execute-keys '<a-;>h'
# }}
# hook -group pairwise global InsertChar > %{ try %{
#     execute-keys -draft hH <a-k>\Q<lt><gt>\E<ret>
#     execute-keys '<a-;>h'
# }}
hook -group pairwise global InsertChar \) %{ try %{
    execute-keys -draft h2H <a-k>\Q())\E<ret>
    execute-keys <backspace><left>
}}
hook -group pairwise global InsertChar \] %{ try %{
    execute-keys -draft h2H <a-k>\Q[]]\E<ret>
    execute-keys <backspace><left>
}}
hook -group pairwise global InsertChar > %{ try %{
    execute-keys -draft h2H <a-k>\Q<lt><gt><gt>\E<ret>
    execute-keys <backspace><left>
}}
hook -group pairwise global InsertChar \} %[ try %[
    execute-keys -draft h2H <a-k>\Q{}}\E<ret>
    execute-keys <backspace><left>
]]
# hook -group pairwise global InsertChar \{ %[ try %[
#     execute-keys -draft H <a-k>\Q{)\E<ret>
#     # execute-keys -save-regs '"' <esc>hdli<space><c-r>"
#     execute-keys <backspace><right><space>{
# ]]
