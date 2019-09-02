# source the plugin manager itself
source "%val{config}/plugins/plug.kak/rc/plug.kak"

plug "andreyorst/plug.kak" noload config %{
    # set-option global plug_always_ensure true
    hook global WinSetOption filetype=plug %{
        remove-highlighter buffer/numbers
        remove-highlighter buffer/matching
        remove-highlighter buffer/wrap
        remove-highlighter buffer/show-whitespaces
    }
}

plug "occivink/kakoune-vertical-selection" config %{
    map global normal '^' ': vertical-selection-up-and-down<ret>'
}

plug "delapouite/kakoune-text-objects" config %{
    # unmap global object '<tab>'
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
    # map global view 'm' '<esc><c-s>: expand<ret>v' -docstring 'smart expand'
    map global view 'm' '<esc>: expand<ret>v' -docstring 'smart expand'
}

plug "delapouite/kakoune-buffers" config %{
    hook global WinDisplay .* info-buffers
    map global user 'b' ': enter-user-mode buffers<ret>'       -docstring 'buffers'
    map global user 'B' ': enter-user-mode -lock buffers<ret>' -docstring 'buffers (lock)'
}

plug "delapouite/kakoune-cd" config %{
    map global cd o '<esc>: print-working-directory<ret>' -docstring 'print working dir'
    map global goto o '<esc>: enter-user-mode cd<ret>'    -docstring 'kakoune-cd'
    alias global pwd print-working-directory
}

plug "andreyorst/smarttab.kak" config %{
    hook global WinSetOption filetype=(rust|markdown|kak|lisp|scheme|sh|perl|yaml) expandtab
    hook global WinSetOption filetype=(makefile) noexpandtab
    hook global WinSetOption filetype=(c|cpp|go) smarttab
} defer smarttab %{
    set-option global softtabstop 4
}

plug "andreyorst/fzf.kak" config %{
    map -docstring 'fzf mode'  global user 'p' ': fzf-mode<ret>'
} defer fzf %{
    set-option global fzf_preview_width '65%'
    set-option global fzf_project_use_tilda true
    declare-option str-list fzf_exclude_files "*.o" "*.bin" "*.obj"
    declare-option str-list fzf_exclude_dirs ".git" ".svn" "vendor" "target"
    evaluate-commands %sh{
        if [ -n "$(command -v fd)" ]; then
            eval "set -- $kak_quoted_opt_fzf_exclude_files $kak_quoted_opt_fzf_exclude_dirs"
            while [ $# -gt 0 ]; do
                exclude="$exclude --exclude '$1'"
                shift
            done
            # echo "echo -debug fzf exclude: $exclude"
            echo "set-option global fzf_file_command %{fd . --no-ignore --type f --follow --hidden $exclude}"
        else
            eval "set -- $kak_quoted_opt_fzf_exclude_files"
            while [ $# -gt 0 ]; do
                exclude="$exclude -name '$1' -o"
                shift
            done
            eval "set -- $kak_quoted_opt_fzf_exclude_dirs"
            while [ $# -gt 1 ]; do
                exclude="$exclude -path '*/$1' -o"
                shift
            done
            exclude="$exclude -path '*/$1'"
            echo "set-option global fzf_file_command %{find . \( $exclude \) -prune -o -type f -follow -print}"
        fi
        [ -n "$(command -v bat)" ] && echo "set-option global fzf_highlight_command bat"
        [ -n "${kak_opt_grepcmd}" ] && echo "set-option global fzf_sk_grep_command %{${kak_opt_grepcmd}}"
    }
}

plug "occivink/kakoune-phantom-selection" config %{
    declare-user-mode phantom
    map -docstring 'phantom-selection add'   global phantom '<plus>'   ": phantom-selection-add-selection<ret>"
    map -docstring 'phantom-selection clear' global phantom '<minus>'  ": phantom-selection-select-all; phantom-selection-clear<ret>"
    map -docstring 'phantom-selection next'  global phantom ')'        ": phantom-selection-iterate-next<ret>"
    map -docstring 'phantom-selection prev'  global phantom '('        ": phantom-selection-iterate-prev<ret>"
    map -docstring 'phantom mode quit'       global phantom ';'        ": phantom-selection-clear<ret>"
    map -docstring 'phantom mode'            global normal '<minus>'   ": enter-user-mode phantom<ret>"
    map -docstring 'phantom mode (lock)'     global normal '<a-minus>' ": enter-user-mode -lock phantom<ret>"
    # can't use <a-;>: see https://github.com/mawww/kakoune/issues/1916
    map global insert '<a-)>' "<esc>: phantom-selection-iterate-next<ret>i"
    map global insert '<a-(>' "<esc>: phantom-selection-iterate-prev<ret>i"
    map global insert '<a-space>' "<esc>: phantom-selection-select-all; phantom-selection-clear<ret>i"
}

plug "andreyorst/kakoune-snippet-collection"

# plug "occivink/kakoune-snippets" branch "auto-discard" config %{
plug "occivink/kakoune-snippets" config %{
    set-option -add global snippets_directories "%opt{plug_install_dir}/kakoune-snippet-collection/snippets"
    set-option global snippets_auto_expand false
    map global insert '<c-e>' "<a-;>: expand-or-jump<ret>"
    # map -docstring 'snippets-info' global user 'i' ': snippets-info<ret>'

    define-command -hidden expand-or-jump %{
        try %{
            snippets-select-next-placeholders
        } catch %{
            snippets-expand-trigger %{
                set-register / "%opt{snippets_triggers_regex}\z"
                execute-keys 'hGhs<ret>'
            }
        } catch %{
            nop
        }
    }
}

plug "occivink/kakoune-find"

plug "occivink/kakoune-sudo-write"

plug "occivink/kakoune-filetree" config %{
    # map global user '<minus>' ': change-directory-current-buffer;filetree<ret>' -docstring 'filetree in current buf dir'
    # map global normal '<a-plus>' ': filetree<ret>' -docstring 'filetree'
}

plug "ul/kak-tree" config %{
    set-option global tree_cmd "kak-tree -c %val{config}/kak-tree.toml"
    declare-user-mode syntax-tree
    map global syntax-tree <space> ': tree-node-sexp<ret>'      -docstring 'tree node sexp'
    map global lang-mode t ': enter-user-mode syntax-tree<ret>' -docstring 'tree select'
    hook global WinSetOption filetype=(go) %{
        map window syntax-tree t ':tree-select- type_declaration<a-b><left>'            -docstring 'type_declaration'
        map window syntax-tree m ':tree-select- method_declaration<a-b><left>'          -docstring 'method_declaration'
        map window syntax-tree f ':tree-select- function_declaration<a-b><left>'        -docstring 'function_declaration'
        map window syntax-tree l ':tree-select- func_literal<a-b><left>'                -docstring 'func_literal'
        map window syntax-tree g ':tree-select- go_statement<a-b><left>'                -docstring 'go_statement'
        map window syntax-tree i ':tree-select- if_statement<a-b><left>'                -docstring 'if_statement'
        map window syntax-tree o ':tree-select- for_statement<a-b><left>'               -docstring 'for_statement'
        map window syntax-tree u ':tree-select- parameter_list<a-b><left>'              -docstring 'parameter_list'
        map window syntax-tree r ':tree-select- return_statement<a-b><left>'            -docstring 'return_statement'
        map window syntax-tree s ':tree-select- expression_switch_statement<a-b><left>' -docstring 'switch statement'
        map window syntax-tree c ':tree-select- expression_case_clause<a-b><left>'      -docstring 'case clause'
    }
}

plug "ul/kak-lsp" do %{
    # cargo install --force --path . --locked
} config %{
    define-command -docstring 'restart lsp server' lsp-restart %{ lsp-stop; lsp-start }
    # set-face global Reference default,rgb:EDF97D
    set-option global lsp_diagnostic_line_error_sign '║'
    set-option global lsp_diagnostic_line_warning_sign '┊'

    # define-command ne -docstring 'go to next error/warning from lsp' %{ lsp-find-error --include-warnings }
    # define-command pe -docstring 'go to previous error/warning from lsp' %{ lsp-find-error --previous --include-warnings }
    # define-command ee -docstring 'go to current error/warning from lsp' %{ lsp-find-error --include-warnings; lsp-find-error --previous --include-warnings }
    map global lsp '<minus>' "<esc>: lsp-disable-window<ret>" -docstring "lsp-disable-window"

    hook global WinSetOption filetype=(go|rust) %{
        set-option window lsp_auto_highlight_references true
        set-option window lsp_hover_anchor false
        set-face window DiagnosticError default+u
        set-face window DiagnosticWarning default+u
        lsp-enable-window
        lsp-auto-signature-help-enable
        # lsp-diagnostic-lines-enable
        # lsp-auto-hover-enable
        # lsp-auto-hover-insert-mode-disable
        map window lsp ']' ': lsp-references-next-match;enter-user-mode lsp<ret>'     -docstring 'lsp-references-next-match'
        map window lsp '[' ': lsp-references-previous-match;enter-user-mode lsp<ret>' -docstring 'lsp-references-previous-match'
        map window lsp 'n' "<esc>: lsp-find-error --include-warnings<ret>" -docstring "find next error or warning"
        map window lsp 'p' "<esc>: lsp-find-error --previous --include-warnings<ret>" -docstring "find previous error or warning"
        map window user 'a' ': enter-user-mode lsp<ret>' -docstring 'LSP mode'
    }

    hook global WinSetOption filetype=(rust) %{
        # bug https://github.com/ul/kak-lsp/issues/217#issuecomment-512793942
        set-option window lsp_server_configuration rust.clippy_preference="on"

        # hook -group lsp buffer BufWritePre .* %{
        #     evaluate-commands %sh{
        #         test -f rustfmt.toml && printf lsp-formatting-sync
        #     }
        # }
        set-register @ 'A;<esc>'
    }

    # hook global WinSetOption filetype=(go) %{
    #     hook -group lsp buffer BufWritePre .* lsp-formatting-sync
    # }

    hook -group lsp global KakEnd .* lsp-exit
}

# plug "https://gitlab.com/Screwtapello/kakoune-state-save.git" noload
plug "danr/kakoune-easymotion" noload

# plug "andreyorst/powerline.kak" noload config %{
#     set-option global powerline_ignore_warnings true
#     set-option global powerline_format 'git bufname smarttab mode_info filetype client session position'
#     # hook -once global WinDisplay .* %{
#     #     powerline-theme github
#     # }
# }

# plug "andreyorst/tagbar.kak" defer tagbar %{
#     set-option global tagbar_sort false
#     set-option global tagbar_size 40
#     set-option global tagbar_display_anon false
# } config %{
#     map global toggle 't' ": tagbar-toggle<ret>" -docstring "toggle tagbar panel"
#     hook global WinSetOption filetype=(c|cpp|rust|go|markdown) %{
#         tagbar-enable
#     }
#     hook global WinSetOption filetype=tagbar %{
#         remove-highlighter buffer/numbers
#         remove-highlighter buffer/matching
#         remove-highlighter buffer/wrap
#         remove-highlighter buffer/show-whitespaces
#     }
# }

plug "delapouite/kakoune-auto-percent" config %{
    map -docstring 'select-complement' global anchor 'p' ': select-complement<ret>'
}
plug "delapouite/kakoune-auto-star"
plug 'delapouite/kakoune-palette'

plug "alexherbo2/auto-pairs.kak" %{
    map -docstring 'auto pairs toggle' global toggle p '<esc>: auto-pairs-toggle<ret>'
    # map global user 's' ': auto-pairs-surround<ret>' -docstring "surround selection"
    # hook global WinSetOption filetype=(c|cpp|rust) %{
    #     auto-pairs-enable
    # }
    # hook global WinCreate .* auto-pairs-enable
}

plug "alexherbo2/distraction-free.kak" config %{
    alias global dt distraction-free-toggle
    map -docstring 'distraction free toggle' global toggle d '<esc>: distraction-free-toggle<ret>'
}

plug "alexherbo2/connect.kak" config %{
    define-command ranger -params .. -file-completion %(connect ranger %arg(@))
    define-command fzf-files -params .. -file-completion %(connect edit $(fd --type file . %arg(@) | fzf))
    map -docstring 'ranger' global user '<minus>' ': ranger<ret>'
}

plug "alexherbo2/word-movement.kak" config %{
    word-movement-map next w
    word-movement-map previous b
    word-movement-map skip e
    map -docstring 'reduce and wm w' global anchor 'w' ';: word-movement-next-word<ret>'
    map -docstring 'reduce and wm b' global anchor 'b' ';: word-movement-previous-word<ret>'
}

plug "alexherbo2/move-line.kak" config %{
    map -docstring 'move line below' global view 'j' '<esc>: move-line-below %val{count}<ret>v'
    map -docstring 'move line above' global view 'k' '<esc>: move-line-above %val{count}<ret>v'
}

plug "alexherbo2/split-object.kak" config %{
    map -docstring "split object" global normal '<a-I>' ': enter-user-mode split-object<ret>'
}

plug "alexherbo2/yank-ring.kak" config %{
    map -docstring 'yank ring' global clipboard 'r' ': yank-ring<ret>'
}

plug "fsub/kakoune-mark.git" domain "gitlab.com" config %{
    set-face global MarkFace1 rgb:000000,rgb:00FF4D
    set-face global MarkFace2 rgb:000000,rgb:F9D3FA
    set-face global MarkFace3 rgb:000000,rgb:A3B3FF
    set-face global MarkFace4 rgb:000000,rgb:BAF2C0
    set-face global MarkFace5 rgb:000000,rgb:FBAEB2
    set-face global MarkFace6 rgb:000000,rgb:FBFF00
    map -docstring 'mark word' global toggle m '<esc>: mark-word<ret>'
    map -docstring 'clear word' global toggle M '<esc>: mark-clear<ret>'
}

# plug "alexherbo2/bc.kak"
# plug "alexherbo2/search-highlighter.kak"

plug "screwtapello/kakoune-inc-dec" domain "gitlab.com" config %{
    map -docstring "decrement selection" global normal '<C-x>' ': inc-dec-modify-numbers - %val{count}<ret>'
    map -docstring "increment selection" global normal '<C-a>' ': inc-dec-modify-numbers + %val{count}<ret>'
}

plug "delapouite/kakoune-select-view" %{
    # map global normal <a-:> ': select-view<ret>' -docstring 'select view'
    map global view w '<esc>: select-view<ret>' -docstring 'select window'
}

plug "eraserhd/kak-ansi"

# source "%val{config}/scripts/bc.kak"
source "%val{config}/scripts/colorscheme-browser.kak"
