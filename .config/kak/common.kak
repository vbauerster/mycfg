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
alias global bd delete-buffer
alias global f findit
alias global ge git-edit
alias global qa quit
alias global qa! quit!
alias global wqa write-all-quit
alias global wqa! write-all-quit
alias global wq write-quit
alias global wq! write-quit!
alias global u enter-user-mode

## Maps.
map -docstring "space as leader"       global normal <space> <,>
map -docstring "drop all but main sel" global normal q <space>
map -docstring "drop main sel"         global normal Q <a-space>
map -docstring "drop main sel"         global normal <c-q> <a-space>
map -docstring "play recorded macro"   global normal <@> q
map -docstring "record macro"          global normal <a-@> Q
map -docstring "align cusors"          global normal <plus> <&>
map -docstring "copy indentation"      global normal <a-plus> <a-&>
map -docstring "choose register"       global normal <a-r> <">
map -docstring "comment line"          global normal <#>  ': comment-line<ret>'
map -docstring "keys help"             global normal <F1> ': doc keys<ret>'
map -docstring "save buffer"           global normal <F2> ': w<ret>'

map global normal <minus> %{:findit <tab>} -docstring "Quick find"
map global normal <a-minus> %{:broot -gc :gs<ret>} -docstring "Broot git status"
map global normal <down> %{: grep-next-match<ret>} -docstring "Next grep match"
map global normal <left> %{: buffer-previous<ret>} -docstring "Prev buffer"
map global normal <right> %{: buffer-next<ret>} -docstring "Next buffer"
map global normal <up> %{: grep-previous-match<ret>} -docstring "Prev grep match"

map global normal <a-g> ': select-or-add-cursor<ret>' -docstring "add cursor on current word, and jump to the next match"

map global normal <%> <c-s><%>

# https://github.com/mawww/kakoune/wiki/Selections#how-to-make-x-select-lines-downward-and-x-select-lines-upward
map global normal <&> ': extend-line-up %val{count}<ret>'
map global normal x ': extend-line-down %val{count}<ret>'
map global normal X <a-X>
# map -docstring "extend block" global normal <&> <a-x>
# map -docstring "inner block"  global normal <%> <a-X>

map global normal <c-x> ': split<ret>'
map global normal D h<a-d>

# stop c and d from yanking
map global normal d <a-d>
map global normal c <a-c>
map global normal <a-d> d
map global normal <a-c> c

map global normal <a-j> <a-J>
map global normal <a-J> <a-j>

map global normal <c-j> <esc>C<space>     -docstring "C<space>"
map global normal <c-k> <esc><a-C><space> -docstring "<a-C><space>"

map global view e jv         -docstring "scroll ↑"
map global view y kv         -docstring "scroll ↓"
map global view j <esc>4jv   -docstring "4j (sticky)"
map global view k <esc>4kv   -docstring "4k (sticky)"
map global view i <esc><a-i> -docstring "<a-i>"
map global view a <esc><a-a> -docstring "<a-a>"

## Some User
map global user . ': evaluate-selection<ret>' -docstring "source selection"
map global user <%> ': evaluate-buffer<ret>' -docstring "source buffer"
map global user <ret> ': w<ret>' -docstring "save buffer"
map global user <a-u> ': e!<ret>' -docstring "reload buffer"
map global user <space> <:> -docstring "command prompt"
map global user k ': smart-select w; man-selection-with-count<ret>' -docstring "man"
map global user o ': focus ' -docstring "tmux-focus"
map global user = ': format-buffer<ret>' -docstring "format buffer"
# map global user ']'       ': grep-next-match<ret>' -docstring "grep next"
# map global user '['       ': grep-previous-match<ret>' -docstring "grep prev"

declare-user-mode lang-mode
map global user m ': enter-user-mode lang-mode<ret>' -docstring "lang mode"

declare-user-mode tmux-window
map global user w ': enter-user-mode tmux-window<ret>' -docstring "window keymap mode"
map global tmux-window O %{: nop %sh{tmux resize-pane -Z}<ret>} -docstring "Zoom window"
map global tmux-window o %{: nop %sh{tmux last-pane -Z}<ret>} -docstring "Last window"
map global tmux-window e %{: nop %sh{tmux select-layout -E}<ret>} -docstring "Equalize layout"
map global tmux-window t %{: nop %sh{tmux select-layout tiled}<ret>} -docstring "Tiled layout"
map global tmux-window h %{: nop %sh{tmux select-layout even-horizontal}<ret>} -docstring "Even horizontal layout"
map global tmux-window <a-h> %{: nop %sh{tmux select-layout main-horizontal}<ret>} -docstring "Main horizontal layout"
map global tmux-window v %{: nop %sh{tmux select-layout even-vertical}<ret>} -docstring "Even vertical layout"
map global tmux-window <a-v> %{: nop %sh{tmux select-layout main-vertical}<ret>} -docstring "Main vertical layout"
map global tmux-window n %{: nop %sh{tmux next-layout}; enter-user-mode tmux-window<ret>} -docstring "Next layout"
map global tmux-window p %{: nop %sh{tmux previous-layout}; enter-user-mode tmux-window<ret>} -docstring "Previous layout"
map global tmux-window <left> %{: nop %sh{tmux resize-pane -L 2}; enter-user-mode tmux-window<ret>} -docstring "Resize left"
map global tmux-window <right> %{: nop %sh{tmux resize-pane -R 2}; enter-user-mode tmux-window<ret>} -docstring "Resize right"
map global tmux-window <down> %{: nop %sh{tmux resize-pane -D 2}; enter-user-mode tmux-window<ret>} -docstring "Resize down"
map global tmux-window <up> %{: nop %sh{tmux resize-pane -U}; enter-user-mode tmux-window<ret>} -docstring "Resize up"

## Spell
# https://discuss.kakoune.com/t/useful-user-modes/730/4
declare-user-mode spell
map global user  s ': enter-user-mode spell<ret>' -docstring "spell keymap mode"
# map -docstring "next error"      global spell 'n' ': spell-next<ret>'
# map -docstring "replace word"    global spell 's' '_: spell-replace<ret>'
# map -docstring "exit spell mode" global spell 'c' ': spell-clear<ret>'
# map -docstring "spell mode"      global user  'S' ': enter-user-mode spell; spell en-US<ret>'
map global spell r ': spell ru<ret>' -docstring 'RU'
map global spell e ': spell en<ret>' -docstring 'ENG'
map global spell f ': spell-next<ret>_: enter-user-mode spell<ret>' -docstring 'next'
map global spell u ': spell-replace<ret><ret> : enter-user-mode spell<ret>' -docstring 'lucky fix'
map global spell a ': spell-replace<ret>' -docstring 'manual fix'
map global spell c ': spell-clear<ret>' -docstring 'clear'

declare-user-mode grep
map global user / ": enter-user-mode grep<ret>"   -docstring "grep keymap mode"
map global grep l %{: grep '' %val{bufname} -H<left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left><left>} -docstring "Local grep"
map global grep g %{<A-i>w"gy<esc>: grep <C-r>g<ret>: try %{delete-buffer *grep*:<C-r>g}<ret> : try %{rename-buffer *grep*:<C-r>g}<ret> : try %{mark-pattern set <C-r>g}<ret>} -docstring "Grep for word under cursor, persist results"
map global grep i %{:grep -i ''<left>} -docstring 'case insensitive'
# map global grep g %{:grep -i '' -g '*.go'<left><left><left><left><left><left><left><left><left><left><left>} -docstring 'just go'

# https://discuss.kakoune.com/t/rfr-best-way-to-add-a-toggle/580/2
declare-user-mode toggle
map -docstring "toggle"           global normal '=' ': enter-user-mode toggle<ret>'
map -docstring "case"             global toggle '=' '<a-`>'
map -docstring "to spaces"        global toggle <space> <@>
map -docstring "to tabs"          global toggle <tab> <a-@>
map -docstring "require module"   global toggle '!' ': require-module '
map -docstring "jumpclient"       global toggle '*' ': set current jumpclient '
map -docstring "colorscheme"      global toggle 'c' ': enter-user-mode themes<ret>'
map -docstring "buffer settings"  global toggle 'b' ': enter-user-mode buffer-toggle<ret>'
map -docstring "search highlight" global toggle 'h' ': search-highlighting-'
map -docstring "autowrap"         global toggle 'w' ': autowrap-'

declare-user-mode buffer-toggle
map -docstring "set filetype"    global buffer-toggle 'b' ':set buffer filetype '
map -docstring "set tabstop"     global buffer-toggle '<tab>' ':set buffer tabstop '
map -docstring "set indentwidth" global buffer-toggle 'i' ':set buffer indentwidth '

declare-user-mode themes
map -docstring "grayscale-light" global themes 'g' ': colorscheme base16-grayscale-light<ret>'
map -docstring "color-light"     global themes 'c' ': colorscheme base16-tomorrow<ret>'
map -docstring "edit colors"     global themes 'e' %{: e %val{config}<a-!>/colors/}

## Goto
map -docstring "window top"                     global goto 'k'     't'
map -docstring "window bottom"                  global goto 'j'     'b'
map -docstring "buffer bottom"                  global goto 'G'     'j'
map -docstring "extend to line end"             global goto '}'     '<esc><a-:>Gl'
map -docstring "extend to line non-blank"       global goto '{'     '<esc><a-:>;Gi'
map -docstring "extend to line begin"           global goto '='     '<esc><a-:>;Gh'
map -docstring "file (recursive)"               global goto 'f'     '<esc>: smart-select-file; search-file %val{selection}<ret>'
map -docstring "file (non-recursive)"           global goto '<a-f>'  '<esc>gf'
map -docstring "search tag in current file"     global goto '['      '<esc><c-s>: smart-select w; symbol<ret>'
map -docstring "search tag in global tags file" global goto ']'      '<esc><c-s>: smart-select w; ctags-search<ret>'
# map -docstring 'switch to [+] buffer'         global goto '<plus>' '<esc>: switch-to-modified-buffer<ret>'

## System clipboard
declare-user-mode clipboard
map -docstring "clipboard mode"                      global user      'y' ': enter-user-mode clipboard<ret>'
map -docstring "yank to sysclipboard"                global clipboard 'y' '<a-|>pbcopy<ret>'
map -docstring "paste (insert) from sysclipboard"    global clipboard 'P' '!pbpaste<ret>'
map -docstring "paste (append) from sysclipboard"    global clipboard 'p' '<a-!>pbpaste<ret>'
map -docstring "replace selection with sysclipboard" global clipboard 'r' '|pbpaste<ret>'
map -docstring "import from sysclipboard"            global clipboard 'm' ': clipboard-import<ret>'
map -docstring "export to sysclipboard"              global clipboard 'x' ': clipboard-export<ret>'
map -docstring "tmux-clipboard menu"                 global clipboard 't' ': enter-user-mode tmux-clipboard<ret>'
map -docstring "comment and paste"                   global clipboard '#' %{: exec -save-regs '"' <lt>a-s>gixy:<lt>space>comment-line<lt>ret><lt>space><lt>a-p><lt>a-_><ret>}
# map -docstring "dump"                                global clipboard 'd' %{: echo -to-file '%sh(dirname "$kak_buffile")<a-!>/' -- %reg{dquote}}

# https://discuss.kakoune.com/t/clipboard-integration-with-registermodified/1150
hook global RegisterModified '"' %{
    nop %sh{
        tmux setb -b kak -- "$kak_main_reg_dquote"
    }
}

# hook global RegisterModified '"' %{ echo -debug yanked %reg{dquote} }

declare-user-mode tmux-clipboard
map -docstring "yank to new buffer"        global tmux-clipboard y '<a-|>tmux setb -- "$kak_selection"<ret>'
map -docstring "choose-buffer into "" reg" global tmux-clipboard m ': tmux-choose-buffer<ret>'
map -docstring "dump kak buffer"           global tmux-clipboard d %{<a-|>tmux saveb -b kak '%sh(dirname "$kak_buffile")<a-!>/'<left>}
map -docstring "choose-buffer and dump"    global tmux-clipboard D %{<a-|>tmux choose-buffer "saveb -b '%%%%' '%sh(dirname ""$kak_buffile"")<a-!>/'"<left><left>}
# map -docstring "paste (insert) from buffer"     global tmux-clipboard 'P' '!tmux showb<ret>'
# map -docstring "paste (append) from buffer"     global tmux-clipboard 'p' '<a-!>tmux showb<ret>'
# map -docstring "replace selection with buffer"  global tmux-clipboard 'r' '|tmux showb<ret>'

declare-user-mode anchor
map -docstring "anchor mode"                global normal ','       ': enter-user-mode anchor<ret>'
map -docstring "slice by word"              global anchor ','       ': slice-by-word<ret>'
map -docstring "flip cursor and anchor"     global anchor '.'       '<a-;>'
map -docstring "ensure anchor after cursor" global anchor 'h'       '<a-:><a-;>'
map -docstring "ensure cursor after anchor" global anchor 'l'       '<a-:>'
map -docstring "selection hull"             global anchor 'm'       ': selection-hull<ret>'
map -docstring "select cursor and anchor"   global anchor 's'       '<a-S>'
map -docstring "reduce and insert"          global anchor <space>   '<esc>;i'
map -docstring "next selection (centered)"  global anchor 'n'       '<esc>nvv: enter-user-mode anchor<ret>'
map -docstring "prev selection (centered)"  global anchor 'p'       '<esc><a-n>vv: enter-user-mode anchor<ret>'
# map -docstring "anchor mode (lock)"         global normal '<a-,>'   ': enter-user-mode -lock anchor<ret>'

declare-user-mode echo-mode
map -docstring "echo mode"            global user      'e' ': enter-user-mode echo-mode<ret>'
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

declare-user-mode tig
map -docstring "tig buffile history"         global tig h %{: t tig %val{bufname}<ret>}
map -docstring "tig blame"                   global tig b %{: tmux-terminal-window tig blame "+%val{cursor_line}" -- %val{bufname}<ret>}
map -docstring "tig status (for committing)" global tig <space> %{: t tig status<ret>}

# declare-user-mode git
# map -docstring "show gutter"        global git 'g' ': git show-diff<ret>'
# map -docstring "hide gutter"        global git 'G' ': git-hide-diff<ret>'
# map -docstring "status"             global git 's' ': git status<ret>'
# map -docstring "log"                global git 'l' ': git log<ret>'
# map -docstring "commit"             global git 'c' ': git commit<ret>'
# map -docstring "diff"               global git 'd' ': git diff<ret>'
# map -docstring "show blamed commit" global git 'w' ': git-show-blamed-commit<ret>'
# map -docstring "log blame"          global git 'L' ': git-log-lines<ret>'
# map -docstring "tig mode"           global git 't' '<esc>: enter-user-mode tig<ret>'
# map -docstring 'next-hunk'          global git ']' "<esc>: git next-hunk;execute-keys 'vv';enter-user-mode git<ret>"
# map -docstring 'prev-hunk'          global git '[' "<esc>: git prev-hunk;execute-keys 'vv';enter-user-mode git<ret>"
# map -docstring "git mode"           global user 'g' ': enter-user-mode git<ret>'

declare-user-mode git
map global user -docstring "Enable Git keymap mode for next key" g ": enter-user-mode git<ret>"
map global git -docstring "toggle blame gutter" <semicolon> ': git-toggle-blame<ret>'
map global git -docstring "show diff gutter" <tab> ": git show-diff<ret>"
map global git -docstring "jump *git*" <a-g> ': jump *git*<ret>'
map global git -docstring "git - Explore the repository history" g ": repl tig<ret>"
map global git -docstring "git - Explore the buffer history" G ': connect-terminal tig -- "%val{buffile}"<ret>'
map global git -docstring "commit - Record changes to the repository" c ": git commit<ret>"
map global git -docstring "blame - Show what revision and author last modified each line of the current file" b ': connect-terminal tig blame "+%val{cursor_line}" -- "%val{buffile}"<ret>'
map global git -docstring "blame - Show commit" B ': git-show-blamed-commit<ret>'
map global git -docstring "diff - Show changes between HEAD and working tree" d ": git diff<ret>,wO"
map global git -docstring "github - Copy canonical GitHub URL to system clipboard" h ": github-url<ret>"
map global git -docstring "log - Show commit logs for the current file" l ': repl "tig log -- %val{buffile}"<ret>'
map global git -docstring "status - Show the working tree status" u ': repl "tig status"<ret>'
map global git -docstring "status - Show the working tree status" U ': repl "tig status"<ret>,wO'
map global git -docstring "staged - Show staged (cached) changes" t ": git diff --staged<ret>"
map global git -docstring "write - Write and stage the current file" w ": write<ret>: git add<ret>: git update-diff<ret>"
map global git -docstring "next-hunk" <]> "<esc>: git next-hunk;execute-keys 'vv';enter-user-mode git<ret>"
map global git -docstring "prev-hunk" <[> "<esc>: git prev-hunk;execute-keys 'vv';enter-user-mode git<ret>"

# Insert mode
# <c-o>    ; # silent: stop completion
# <c-x>    ; # complete here
# <c-v>    ; # raw insert, use vim binding
# map global insert '<a-c>' '<esc><a-c>'
map global insert '<a-g>' '<esc>:'
map global insert '<a-c>' '<esc>'
map global insert '<a-[>' '<a-;>'
map global insert '<a-#>' '<esc>x_<a-c>' -docstring "uncomment line start"
map global insert '<c-a>' '<esc>I'
map global insert '<c-e>' '<end>'
map global insert '<a-h>' '<a-;>h'
map global insert '<a-l>' '<a-;>l'
map global insert '<c-d>' '<del>'
map global insert '<c-i>' '<esc>: count-insert '
map global insert '<a-u>' '<esc><c-s>b<a-`><c-o>i'
map global insert '<a-O>' '<esc><c-s>O'
map global insert '<a-minus>' '<c-o><c-x>l'
map global insert '<a-r>' '<c-r>"'
map global insert '<c-y>' '<a-;>!pbpaste<ret>'

# Prompt mode
map global prompt -docstring 'Case insensitive search' <a-i> '<home>(?i)<end>'
map global prompt -docstring 'Regex disabled search' <a-x> '<home>\Q<end>\E<left><left>'
map global prompt -docstring 'Paste form default reg' <a-r> '<c-r>"'
map global prompt -docstring 'Expand to the buffer directory' <a-.> '%sh(dirname "$kak_buffile")<a-!>'

# Hooks
# ‾‾‾‾‾

## Editorconfig
## ‾‾‾‾‾‾‾‾‾‾‾‾
# hook global BufOpenFile .* editorconfig-load
# hook global BufNewFile  .* editorconfig-load

## Git
## ‾‾‾
hook global BufOpenFile .* %{
    evaluate-commands -draft %sh{
        cd $(dirname "$kak_buffile")
        if [ $(git rev-parse --git-dir 2>/dev/null) ]; then
            echo "hook buffer -group git-show-diff BufReload .* %{ git show-diff }"
            echo "hook buffer -group git-show-diff BufWritePost .* %{ git show-diff }"
            echo "echo -debug git-show-diff HOOK SET"
        fi
    }
}

# Custom text objects
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
# map global object q '"'           -docstring 'double quote string'
map global object h 'c\s,\s<ret>' -docstring "select between whitespace"

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

# hook -group pairwise global InsertChar \) %{ try %{
#     execute-keys -draft h2H <a-k>\Q())\E<ret>
#     execute-keys <backspace><left>
# }}
# hook -group pairwise global InsertChar \] %{ try %{
#     execute-keys -draft h2H <a-k>\Q[]]\E<ret>
#     execute-keys <backspace><left>
# }}
# hook -group pairwise global InsertChar \} %[ try %[
#     execute-keys -draft h2H <a-k>\Q{}}\E<ret>
#     execute-keys <backspace><left>
# ]]
# hook global InsertChar > %{ try %{
#     execute-keys -draft h2H <a-k>\Q<lt><gt><gt>\E<ret>
#     execute-keys <backspace><left>
# }}

# hook -group pairwise global InsertChar \{ %[ try %[
#     execute-keys -draft H <a-k>\Q{)\E<ret>
#     # execute-keys -save-regs '"' <esc>hdli<space><c-r>"
#     execute-keys <backspace><right><space>{
# ]]
