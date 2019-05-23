# source the plugin manager itself
source "%val{config}/plugins/plug.kak/rc/plug.kak"

plug "andreyorst/plug.kak" noload

plug "occivink/kakoune-vertical-selection" config %{
    map global normal '%' ': vertical-selection-up-and-down<ret>'
}

plug "delapouite/kakoune-text-objects" config %{
    unmap global object '<tab>'
    map global object 'P' '<esc>: text-object-indented-paragraph<ret>' -docstring 'indented paragraph'
}

plug "occivink/kakoune-expand" config %{
    set-option global expand_commands %{
        expand-impl %{ execute-keys <a-a>b }
        expand-impl %{ execute-keys <a-a>B }
        expand-impl %{ execute-keys <a-a>r }
        expand-impl %{ execute-keys <a-i>i }
        expand-impl %{ execute-keys <a-i>u }
        expand-impl %{ execute-keys <a-a>u }
        expand-impl %{ execute-keys '<a-:><a-;>k<a-K>^$<ret><a-i>i' } # previous indent level (upward)
        expand-impl %{ execute-keys '<a-:>j<a-K>^$<ret><a-i>i' }      # previous indent level (downward)
    }
    map -docstring 'smart expand' global normal '<a-space>' '<c-s>: expand<ret>'
}

plug "delapouite/kakoune-buffers" config %{
    hook global WinDisplay .* info-buffers
    map -docstring 'buffers'        global user b ': enter-user-mode buffers<ret>'
    map -docstring 'buffers (lock)' global user B ': enter-user-mode -lock buffers<ret>'
}

plug "delapouite/kakoune-cd" config %{
    map global cd <space> '<esc>: print-working-directory<ret>' -docstring 'print working dir'
    map global goto o '<esc>: enter-user-mode cd<ret>' -docstring 'kakoune-cd'
    alias global pwd print-working-directory
}

plug "andreyorst/smarttab.kak" config %{
    set-option global softtabstop 4
    hook global WinSetOption filetype=(rust|markdown|kak|lisp|scheme|sh|perl) expandtab
    hook global WinSetOption filetype=(makefile) noexpandtab
    hook global WinSetOption filetype=(c|cpp|go) smarttab
}

plug "andreyorst/fzf.kak" config %{
    map -docstring 'fzf-mode'  global user 'p' ': fzf-mode<ret>'
    map -docstring 'fzf-ctags' global user 'c' ': enter-user-mode fzf-ctags<ret>'
    set-option global fzf_preview_width '65%'
    unmap global fzf v
    unmap global fzf <a-v>
    map global fzf g ': fzf-vcs<ret>' -docstring 'edit file from vcs repo'
    map global fzf <a-g> ': fzf-vcs-mode<ret>' -docstring 'switch to vcs selection mode'
    evaluate-commands %sh{
        if command -v fd >/dev/null 2>/dev/null; then
            # echo "set-option global fzf_file_command 'fd . --no-ignore --type f --follow'"
            echo "set-option global fzf_file_command %{fd . --type f --follow --exclude .git --exclude .svn --exclude TAGS}"
        fi
        command -v blsd >/dev/null 2>/dev/null && echo "set-option global fzf_cd_command '(echo .. && blsd)'"
        command -v bat >/dev/null 2>/dev/null && echo "set-option global fzf_highlight bat"
        command -v tree >/dev/null 2>/dev/null && echo "set-option global fzf_cd_preview true"
        # [ -n "${kak_opt_grepcmd}" ] && echo "set-option global fzf_sk_grep_command %{${kak_opt_grepcmd}}"
    }
}

plug "occivink/kakoune-phantom-selection" config %{
    # map -docstring 'phantom-selection add'   global user 'm' ': phantom-selection-add-selection<ret>'
    map -docstring 'phantom-selection n'     global anchor ')' ': phantom-selection-iterate-next<ret>'
    map -docstring 'phantom-selection p'     global anchor '(' ': phantom-selection-iterate-prev<ret>'
    map -docstring 'phantom-selection clear' global anchor '<space>' ': phantom-selection-select-all; phantom-selection-clear<ret>'

    map global insert '<a-)>' "<esc>: phantom-selection-iterate-next<ret>"
    map global insert '<a-(>' "<esc>: phantom-selection-iterate-prev<ret>"
}

plug "andreyorst/kakoune-snippet-collection"

plug "occivink/kakoune-snippets" branch "auto-discard" config %{
    set-option -add global snippets_directories "%opt{plug_install_dir}/kakoune-snippet-collection/snippets"
    set-option global snippets_auto_expand false
    # map global normal '<ret>' ":      expand-or-jump-or-key ret<ret>"
    map global insert '<a-n>' "<a-;>: expand-or-jump-or-key a-n<ret>"
    map -docstring 'snippets-info' global user 'i' ': snippets-info<ret>'

    define-command -hidden \
    expand-or-jump-or-key -params 1 %{
        try %{
            snippets-select-next-placeholders
        } catch %{ snippets-expand-trigger %{
            set-register / "%opt{snippets_triggers_regex}\z"
            execute-keys 'hGhs<ret>'
        }} catch %sh{
            printf "%s\n" "execute-keys -with-hooks <$1>"
        }
    }
}

plug "occivink/kakoune-find"

plug "occivink/kakoune-sudo-write"

plug "occivink/kakoune-filetree" config %{
    map global user '<minus>' ': change-directory-current-buffer;filetree<ret>' -docstring 'filetree in current buf dir'
    # map global normal '<a-plus>' ': filetree<ret>' -docstring 'filetree'
}

plug "ul/kak-tree" config %{
    # set global tree_cmd 'kak-tree -c /Users/vbauer/dotfiles/config/kak/kak-tree.toml'
    hook global WinSetOption filetype=(go) %{
        declare-user-mode syntax-tree-children
        map global syntax-tree-children c ': tree-select-children<ret>' -docstring 'children'
        map global syntax-tree-children t ': tree-select-children type_declaration<ret>' -docstring 'type_declaration'
        map global syntax-tree-children m ': tree-select-children method_declaration<ret>' -docstring 'method_declaration'
        map global syntax-tree-children f ': tree-select-children function_declaration<ret>' -docstring 'function_declaration'
        map global syntax-tree-children l ': tree-select-children func_literal<ret>' -docstring 'func_literal'
        map global syntax-tree-children g ': tree-select-children go_statement<ret>' -docstring 'go_statement'
        map global syntax-tree-children b ': tree-select-children block<ret>' -docstring 'block'
        map global syntax-tree-children i ': tree-select-children if_statement<ret>' -docstring 'if_statement'
        map global syntax-tree-children o ': tree-select-children for_statement<ret>' -docstring 'for_statement'
        map global syntax-tree-children u ': tree-select-children parameter_list<ret>' -docstring 'parameter_list'
        map global syntax-tree-children r ': tree-select-children return_statement<ret>' -docstring 'return_statement'
        map global syntax-tree-children <backspace> ': enter-user-mode syntax-tree<ret>' -docstring 'back...'

        declare-user-mode syntax-tree-parent
        map global syntax-tree-parent p ': tree-select-parent-node<ret>' -docstring 'parent_node'
        map global syntax-tree-parent t ': tree-select-parent-node type_declaration<ret>' -docstring 'type_declaration'
        map global syntax-tree-parent m ': tree-select-parent-node method_declaration<ret>' -docstring 'method_declaration'
        map global syntax-tree-parent f ': tree-select-parent-node function_declaration<ret>' -docstring 'function_declaration'
        map global syntax-tree-parent l ': tree-select-parent-node func_literal<ret>' -docstring 'func_literal'
        map global syntax-tree-parent g ': tree-select-parent-node go_statement<ret>' -docstring 'go_statement'
        map global syntax-tree-parent b ': tree-select-parent-node block<ret>' -docstring 'block'
        map global syntax-tree-parent i ': tree-select-parent-node if_statement<ret>' -docstring 'if_statement'
        map global syntax-tree-parent o ': tree-select-parent-node for_statement<ret>' -docstring 'for_statement'
        map global syntax-tree-parent u ': tree-select-parent-node parameter_list<ret>' -docstring 'parameter_list'
        map global syntax-tree-parent r ': tree-select-parent-node return_statement<ret>' -docstring 'return_statement'
        map global syntax-tree-parent <backspace> ': enter-user-mode syntax-tree<ret>' -docstring 'back...'

        declare-user-mode syntax-tree-next
        map global syntax-tree-next ')' ': tree-select-next-node<ret>' -docstring 'next_node'
        map global syntax-tree-next t   ': tree-select-next-node type_declaration<ret>' -docstring 'type_declaration'
        map global syntax-tree-next m   ': tree-select-next-node method_declaration<ret>' -docstring 'method_declaration'
        map global syntax-tree-next f   ': tree-select-next-node function_declaration<ret>' -docstring 'function_declaration'
        map global syntax-tree-next b   ': tree-select-next-node block<ret>' -docstring 'block'
        map global syntax-tree-next i   ': tree-select-next-node if_statement<ret>' -docstring 'if_statement'
        map global syntax-tree-next o   ': tree-select-next-node for_statement<ret>' -docstring 'for_statement'
        map global syntax-tree-next u   ': tree-select-next-node parameter_list<ret>' -docstring 'parameter_list'
        map global syntax-tree-next r   ': tree-select-next-node return_statement<ret>' -docstring 'return_statement'
        map global syntax-tree-next <backspace> ': enter-user-mode syntax-tree<ret>' -docstring 'back...'

        declare-user-mode syntax-tree-prev
        map global syntax-tree-prev '(' ': tree-select-previous-node<ret>' -docstring 'previous_node'
        map global syntax-tree-prev t ': tree-select-previous-node type_declaration<ret>' -docstring 'type_declaration'
        map global syntax-tree-prev m ': tree-select-previous-node method_declaration<ret>' -docstring 'method_declaration'
        map global syntax-tree-prev f ': tree-select-previous-node function_declaration<ret>' -docstring 'function_declaration'
        map global syntax-tree-prev b ': tree-select-previous-node block<ret>' -docstring 'block'
        map global syntax-tree-prev i ': tree-select-previous-node if_statement<ret>' -docstring 'if_statement'
        map global syntax-tree-prev o ': tree-select-previous-node for_statement<ret>' -docstring 'for_statement'
        map global syntax-tree-prev u ': tree-select-previous-node parameter_list<ret>' -docstring 'parameter_list'
        map global syntax-tree-prev r ': tree-select-previous-node return_statement<ret>' -docstring 'return_statement'
        map global syntax-tree-prev <backspace> ': enter-user-mode syntax-tree<ret>' -docstring 'back...'

        declare-user-mode syntax-tree
        map global syntax-tree '(' ': enter-user-mode syntax-tree-prev<ret>' -docstring 'previous_node'
        map global syntax-tree ')' ': enter-user-mode syntax-tree-next<ret>' -docstring 'next_node'
        map global syntax-tree c ': enter-user-mode syntax-tree-children<ret>' -docstring 'children'
        map global syntax-tree p ': enter-user-mode syntax-tree-parent<ret>' -docstring 'parent_node'
        map global syntax-tree t ': tree-node-sexp<ret>' -docstring 'tree-node-sexp'
        map global user t ': enter-user-mode syntax-tree<ret>' -docstring 'tree select'
    }
}

plug "ul/kak-lsp" do %{
    cargo build --release --locked
    cargo install --force --path .
} config %{
    set-face global Reference default,rgb:EDF97D
    set-option global lsp_diagnostic_line_error_sign '║'
    set-option global lsp_diagnostic_line_warning_sign '┊'

    # define-command ne -docstring 'go to next error/warning from lsp' %{ lsp-find-error --include-warnings }
    # define-command pe -docstring 'go to previous error/warning from lsp' %{ lsp-find-error --previous --include-warnings }
    # define-command ee -docstring 'go to current error/warning from lsp' %{ lsp-find-error --include-warnings; lsp-find-error --previous --include-warnings }

    define-command lsp-restart -docstring 'restart lsp server' %{ lsp-stop; lsp-start }

    hook global WinSetOption filetype=(c|cpp|go|rust) %{
        map -docstring 'lsp-references-next-match'     global lsp ']' ': lsp-references-next-match;enter-user-mode lsp<ret>'
        map -docstring 'lsp-references-previous-match' global lsp '[' ': lsp-references-previous-match;enter-user-mode lsp<ret>'
        map -docstring 'LSP mode' window user 'a' ': enter-user-mode lsp<ret>'
        set-option window lsp_auto_highlight_references true
        set-option window lsp_hover_anchor false
        lsp-enable-window
        lsp-auto-signature-help-enable
        set-face window DiagnosticError default+u
        set-face window DiagnosticWarning default+u
        # lsp-diagnostic-lines-enable
        # lsp-auto-hover-enable
        # lsp-auto-hover-insert-mode-disable
        # unmap window lsp &
        # map window lsp <*> ': lsp-highlight-references<ret>' -docstring 'lsp-highlight-references'
    }

    hook global WinSetOption filetype=(rust) %{
        set-option window lsp_server_configuration rust.clippy_preference="on"
        hook -group lsp buffer BufWritePre .* %{
            evaluate-commands %sh{
                test -f rustfmt.toml && printf lsp-formatting-sync
            }
        }
    }

    # hook global WinSetOption filetype=(go) %{
    #     hook -group lsp buffer BufWritePre .* lsp-formatting-sync
    # }

    hook global KakEnd .* lsp-exit
}

# plug "https://gitlab.com/Screwtapello/kakoune-state-save.git" noload
plug "danr/kakoune-easymotion" noload

plug "andreyorst/powerline.kak" noload config %{
    # set-option global powerline_ignore_warnings true
    # set-option global powerline_format 'git bufname smarttab mode_info filetype client session position'
    # hook -once global WinDisplay .* %{
    #     powerline-theme github
    # }
}

plug "andreyorst/tagbar.kak" noload config %{
    # set-option global tagbar_sort false
    # set-option global tagbar_size 40
    # set-option global tagbar_display_anon false
    # map global user 't' ": tagbar-toggle<ret>" -docstring "toggle tagbar panel"
    # hook global WinSetOption filetype=(c|cpp|rust|go|markdown) %{
    #     tagbar-enable
    # }
    # hook global WinSetOption filetype=tagbar %{
    #     remove-highlighter buffer/numbers
    #     remove-highlighter buffer/matching
    #     remove-highlighter buffer/wrap
    #     remove-highlighter buffer/show-whitespaces
    # }
}

plug "delapouite/kakoune-auto-percent" config %{
    map -docstring 'select-complement' global anchor 'p' ': select-complement<ret>'
}
plug "delapouite/kakoune-auto-star"
plug 'delapouite/kakoune-palette'

plug "alexherbo2/auto-pairs.kak" config %{
    # hook global WinSetOption filetype=(c|cpp|go|rust) %{
    #     auto-pairs-enable
    # }
    map global toggle p '<esc>: auto-pairs-toggle<ret>' -docstring 'auto pairs toggle'
}

plug "alexherbo2/distraction-free.kak" config %{
    alias global dt distraction-free-toggle
}

plug "alexherbo2/connect.kak" config %{
    define-command ranger -params .. -file-completion %(connect ranger %arg(@))
    map global normal '<plus>' ' :ranger<ret>'
}

plug "alexherbo2/word-movement.kak" config %{
    word-movement-map next w
    word-movement-map previous b
    word-movement-map skip e
    map -docstring 'reduce and wm w' global anchor 'w' ';: word-movement-next-word<ret>'
    map -docstring 'reduce and wm b' global anchor 'b' ';: word-movement-previous-word<ret>'
}

plug "alexherbo2/split-object.kak" config %{
    map -docstring "split object" global normal '<a-I>' ': enter-user-mode split-object<ret>'
}

plug "alexherbo2/yank-ring.kak" config %{
    map -docstring 'yank ring' global clipboard 'r' ': yank-ring<ret>'
}

plug "fsub/kakoune-mark.git" domain "gitlab.com"

# plug "alexherbo2/bc.kak"
plug "screwtapello/kakoune-inc-dec" domain "gitlab.com" config %{
    map -docstring "decrement selection" global normal '<C-x>' ': inc-dec-modify-numbers - %val{count}<ret>'
    map -docstring "increment selection" global normal '<C-a>' ': inc-dec-modify-numbers + %val{count}<ret>'
}

# source "%val{config}/scripts/bc.kak"
source "%val{config}/scripts/colorscheme-browser.kak"
