# bootstrap the plugin manager
evaluate-commands %sh{
    plugins="$HOME/.config/kak/plugins"
    mkdir -p $plugins
    [ ! -e "$plugins/plug.kak" ] && \
        git clone -q https://github.com/andreyorst/plug.kak.git "$plugins/plug.kak"
    printf "%s\n" "source '$plugins/plug.kak/rc/plug.kak'"
}

plug "andreyorst/plug.kak" noload config %{
    set-option global plug_always_ensure true
    hook global WinSetOption filetype=plug %{
        remove-highlighter buffer/numbers
        remove-highlighter buffer/matching
        remove-highlighter buffer/wrap
        remove-highlighter buffer/show-whitespaces
    }
}

plug "alexherbo2/prelude.kak"

plug "alexherbo2/manual-indent.kak" config %{
    hook global WinCreate .* %{
      manual-indent-enable
    }
    hook global WinSetOption filetype=.* %{
      manual-indent-remove-filetype-hooks
    }
}

plug "alexherbo2/terminal-mode.kak" config %{
    map global user t ': enter-user-mode terminal<ret>' -docstring 'Terminal'
    # map global user t ': enter-user-mode tmux<ret>' -docstring 'tmux'
}

plug "alexherbo2/connect.kak" config %{
    map global normal <c-t> ': connect-terminal<ret>'

    # https://github.com/robertmeta/kakfiles/blob/1659f1a9358a2728ab5419427634ded7d79ea976/kakrc#L219
    # define-command connect-vertical %{
    #     alias global terminal tmux-terminal-vertical
    # }
    # define-command connect-horizontal %{
    #     alias global terminal tmux-terminal-horizontal
    # }
    # def nnn -params .. -file-completion %(connect-terminal nnn %arg(@)) -docstring "Open with nnn"
    # def broot -params .. -file-completion %(connect-terminal broot %arg(@)) -docstring "Open with broot"
    def ranger -params .. -file-completion %(connect-terminal ranger %arg(@)) -docstring "Open with ranger"
    require-module connect-lf
    require-module connect-nnn
    require-module connect-broot
}

plug "alexherbo2/auto-pairs.kak" config %{
    map -docstring "auto-pairs toggles" global toggle <(> ': auto-pairs-'
}

plug "alexherbo2/surround.kak" config %{
    map -docstring "surround"        global view o '<esc>: enter-user-mode surround<ret>'
    # map -docstring "surround insert" global view O '<esc>: surround-enter-insert-mode<ret>'
}

plug "alexherbo2/move-line.kak" config %{
    map -docstring 'move line below' global normal '<a-down>' ': move-line-below<ret>'
    map -docstring 'move line above' global normal '<a-up>'   ': move-line-above<ret>'
}

plug "alexherbo2/out-of-view.kak" config %{
    # default: '%val{bufname} %val{cursor_line}:%val{cursor_char_column} {{context_info}} {{mode_info}} - %val{client}@[%val{session}]'
    set-option global modelinefmt '%opt{out_of_view_status_line} {{mode_info}} %val{bufname} %val{cursor_line}:%val{cursor_char_column} {{context_info}} %val{client}@[%val{session}]'
}

plug "alexherbo2/split-object.kak" config %{
    map -docstring "split object" global normal <a-I> ': enter-user-mode split-object<ret>'
    map -docstring "split object" global view u '<esc>: enter-user-mode split-object<ret>'
}

plug "occivink/kakoune-sudo-write"

plug "occivink/kakoune-find"

plug "occivink/kakoune-vertical-selection" config %{
    # map global normal '^' ': vertical-selection-up-and-down<ret>' -docstring "vertical-selection-up-and-down"
    map global object 'y' '<esc>: text-object-vertical<ret>' -docstring 'vertical selection'
}

plug "Delapouite/kakoune-text-objects" config %{
    # unmap 'vertical selection'
    unmap global object 'v'
}

plug "occivink/kakoune-expand" config %{
    set-option global expand_commands %{
        expand-impl %{ execute-keys <a-i>b }
        expand-impl %{ execute-keys <a-i>B }
        expand-impl %{ execute-keys <a-a>b }
        expand-impl %{ execute-keys <a-a>B }
        expand-impl %{ execute-keys <a-a>r }
        expand-impl %{ execute-keys <a-i>i }
        expand-impl %{ execute-keys <a-i>u }
        expand-impl %{ execute-keys <a-a>u }
        expand-impl %{ execute-keys '<a-:><a-;>k<a-K>^$<ret><a-i>i' } # previous indent level (upward)
        expand-impl %{ execute-keys '<a-:>j<a-K>^$<ret><a-i>i' }      # previous indent level (downward)
    }
    # map global view u '<esc><c-s>: expand<ret>v' -docstring 'smart expand'
    map global normal '0' ': zero expand<ret>' -docstring "smart expand"
}

plug "Delapouite/kakoune-buffers" config %{
    hook global WinDisplay .* info-buffers
    map global buffers <space> ':b<space>'             -docstring 'buffer select'
    map global user u ': enter-user-mode buffers<ret>' -docstring 'buffers'
    # map global buffers '<space>' ': info-buffers<ret>'   -docstring 'info'
}

plug "occivink/kakoune-buffer-switcher" config %{
    alias global bs buffer-switcher
}

plug "Delapouite/kakoune-cd" config %{
    map global cd o '<esc>: print-working-directory<ret>' -docstring 'print working dir'
    map global goto o '<esc>: enter-user-mode cd<ret>'    -docstring 'kakoune-cd'
    alias global pwd print-working-directory
}

plug "andreyorst/smarttab.kak" config %{
    hook global WinSetOption filetype=(rust|markdown|kak|lisp|scheme|sh|perl|yaml) expandtab
    hook global WinSetOption filetype=(makefile|go) noexpandtab
    hook global WinSetOption filetype=(c|cpp) smarttab
} defer smarttab %{
    set-option global softtabstop 4
    set-option global smarttab_expandtab_mode_name   '⋅t⋅'
    set-option global smarttab_noexpandtab_mode_name '→t→'
    set-option global smarttab_smarttab_mode_name    '→t⋅'
}

plug "andreyorst/fzf.kak" config %{
    map -docstring 'fzf mode'  global user 'p' ': fzf-mode<ret>'
} defer fzf %{
    set-option global fzf_preview_width '65%'
    set-option global fzf_project_use_tilda true
    declare-option str-list fzf_exclude_files "*.o" "*.bin" "*.obj"
    declare-option str-list fzf_exclude_dirs ".git" ".svn" "vendor" "target"
    set-option global fzf_file_command %sh{
        if [ -n "$(command -v fd)" ]; then
            eval "set -- $kak_quoted_opt_fzf_exclude_files $kak_quoted_opt_fzf_exclude_dirs"
            while [ $# -gt 0 ]; do
                exclude="$exclude --exclude '$1'"
                shift
            done
            cmd="fd . --no-ignore --type f --follow --hidden $exclude"
        else
            eval "set -- $kak_quoted_opt_fzf_exclude_files"
            while [ $# -gt 0 ]; do
                exclude="$exclude -name '$1' -o"
                shift
            done
            eval "set -- $kak_quoted_opt_fzf_exclude_dirs"
            while [ $# -gt 0 ]; do
                exclude="$exclude -path '*/$1' -o"
                shift
            done
            cmd="find . \( ${exclude% -o} \) -prune -o -type f -follow -print"
        fi
        echo "$cmd"
    }
    evaluate-commands %sh{
        [ -n "$(command -v bat)" ] && echo "set-option global fzf_highlight_command bat"
        [ -n "${kak_opt_grepcmd}" ] && echo "set-option global fzf_sk_grep_command %{${kak_opt_grepcmd}}"
    }
}

plug "occivink/kakoune-phantom-selection" config %~
    declare-user-mode phantom
    map -docstring 'phantom next'          global phantom 'n'       ': phantom-selection-iterate-next<ret>'
    map -docstring 'phantom prev'          global phantom 'p'       ': phantom-selection-iterate-prev<ret>'
    map -docstring 'phantom next (sticky)' global phantom '<a-n>'   ': phantom-selection-iterate-next;enter-user-mode phantom<ret>'
    map -docstring 'phantom prev (sticky)' global phantom '<a-p>'   ': phantom-selection-iterate-prev;enter-user-mode phantom<ret>'
    map -docstring 'clear'                 global phantom ';'       ': phantom-selection-select-all; phantom-selection-clear<ret>'
    map -docstring 'clear!'                global phantom '<ret>'   ': phantom-selection-clear<ret>'
    map -docstring 'phantom mode'          global insert  '<a-n>'   '<a-;>: enter-user-mode phantom<ret>'
    # map -docstring 'phantom mode'          global normal  '<c-n>'   ': enter-user-mode phantom<ret>'
~

# https://discuss.kakoune.com/t/easy-way-to-loop-through-phantom-selections/908
# plug "occivink/kakoune-phantom-selection" config %~
#     define-command -hidden -override -docstring "Creates a phantom group of selections" \
#     phantom-group %{
#         phantom-selection-add-selection
#         map buffer normal <tab>   ': phantom-selection-iterate-next<ret>'
#         map buffer insert <tab>   '<esc>: phantom-selection-iterate-next<ret>i'
#         map buffer normal <s-tab> ': phantom-selection-iterate-prev<ret>'
#         map buffer insert <s-tab> '<esc>: phantom-selection-iterate-prev<ret>i'
#         map buffer normal <c-g>   ': phantom-ungroup<ret>'
#         map buffer insert <c-g>   '<esc>: phantom-ungroup<ret>i'
#     }
#     define-command -hidden -override -docstring "Removes a phantom group of selections" \
#     phantom-ungroup %{
#         phantom-selection-select-all
#         phantom-selection-clear
#         unmap buffer normal <tab>   ': phantom-selection-iterate-next<ret>'
#         map   buffer insert <tab>   '<tab>'
#         unmap buffer normal <s-tab> ': phantom-selection-iterate-prev<ret>'
#         unmap buffer insert <s-tab> '<esc>: phantom-selection-iterate-prev<ret>i'
#         unmap buffer normal <c-g>   ': phantom-ungroup<ret>'
#         unmap buffer insert <c-g>   '<esc>: phantom-ungroup<ret>i'
#     }
#     map global normal <c-g>  ': phantom-group<ret><space>'
#     map global insert <c-g>  '<esc>: phantom-group<ret><space>i'
# ~

plug "andreyorst/kakoune-snippet-collection"

plug "occivink/kakoune-snippets" config %{
    set-option -add global snippets_directories "%opt{plug_install_dir}/kakoune-snippet-collection/snippets"
    set-option global snippets_auto_expand false
    map global insert '<a-e>' '<a-;>: expand-or-jump<ret>'
    map -docstring 'snippets-' global toggle 's' ': snippets-'

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

plug "andreyorst/tagbar.kak" domain gitlab.com defer tagbar %{
    set-option global tagbar_sort false
    set-option global tagbar_size 40
    set-option global tagbar_display_anon false
    set-option global tagbar_powerline_format ""
} config %{
    map -docstring "tagbar toggles"      global toggle 't' ': tagbar-'
    # declare-user-mode tagbar
    # map -docstring "toggle tagbar panel" global tagbar 't' ': tagbar-toggle<ret>'
    # map -docstring "tagbar focus"        global tagbar 'o' ': tmux-focus tagbarclient<ret>'
    # map -docstring "tagbar user mode"    global user   't' ': enter-user-mode tagbar<ret>'
    # hook global WinSetOption filetype=(c|cpp|rust|markdown) %{
    #     tagbar-enable
    # }
    hook global WinSetOption filetype=tagbar %{
        remove-highlighter buffer/numbers
        remove-highlighter buffer/matching
        remove-highlighter buffer/wrap
        remove-highlighter buffer/show-whitespaces
    }
}

plug "Delapouite/kakoune-auto-percent" config %{
    map -docstring "select-complement" global toggle m ': select-complement<ret>'
}

plug 'Delapouite/kakoune-palette'

plug "Delapouite/kakoune-mirror" config %{
    map global normal "'" ': enter-user-mode mirror<ret>'
    map global normal '"' ': enter-user-mode -lock mirror<ret>'
}

plug "screwtapello/kakoune-inc-dec" domain "gitlab.com" config %{
    map -docstring "increment number" global toggle <plus> ': inc-dec-modify-numbers + %val{count}; enter-user-mode toggle<ret>'
    map -docstring "decrement number" global toggle <minus> ': inc-dec-modify-numbers - %val{count}; enter-user-mode toggle<ret>'
}

plug "fsub/kakoune-mark" domain "gitlab.com" config %{
    set-face global MarkFace1 rgb:000000,rgb:00FF4D
    set-face global MarkFace2 rgb:000000,rgb:F9D3FA
    set-face global MarkFace3 rgb:000000,rgb:A3B3FF
    set-face global MarkFace4 rgb:000000,rgb:BAF2C0
    set-face global MarkFace5 rgb:000000,rgb:FBAEB2
    set-face global MarkFace6 rgb:000000,rgb:FBFF00
    map global user "'" %{: mark-word<ret>} -docstring "Mark word with highlight"
    map global user '"' %{: mark-clear<ret>} -docstring "Remove word marking"
}

plug "Screwtapello/kakoune-state-save" domain gitlab.com

plug "eraserhd/kak-ansi"

plug "TeddyDD/kakoune-selenized" domain "github.com" theme
plug "Delapouite/kakoune-colors" domain "github.com" theme
plug "robertmeta/nofrils-kakoune" domain "github.com" theme
plug "ftonneau/beryl.kak" domain "github.com" theme

plug "andreyorst/langmap.kak" defer langmap %{
    declare-option -docstring 'English key layout for Programming Dvorak keyboards' \
    str-list langmap_us_programming_dvorak 'en' %{$~&%[7{5}3(1=9*0)2+4]6!8#`\|;:,<.>pPyYfFgGcCrRlL/?@^aAoOeEuUiIdDhHtTnNsS-_'"qQjJkKxXbBmMwWvVzZ}
    #                                           %{ёЁ1!2"3№4;5%6:7?8*9(0)-_=+\/йЙцЦуУкКеЕнНгГшШщЩзЗхХъЪфФыЫвВаАпПрРоОлЛдДжЖэЭяЯчЧсСмМиИтТьЬбБюЮ.,}
    set-option global langmap_default %opt{langmap_us_programming_dvorak}
    set-option global langmap %opt{langmap_ru_jcuken}

    map -docstring "toggle layout" global insert '<c-l>' '<a-;>: toggle-langmap<ret>'
    # map -docstring "toggle layout (C-\)" global normal '' ':      toggle-langmap<ret>'
    # map -docstring "toggle layout (C-\)" global prompt '' '<a-;>: toggle-langmap prompt<ret>'
}

plug "jbomanson/search-doc.kak" config %{
    require-module search-doc
    alias global h search-doc
}

plug "andreyorst/kaktree" defer kaktree %{
    map global user 'f' ": kaktree-toggle<ret>" -docstring "toggle filetree panel"
    # set-option global kaktree_show_help false
    # set-option global kaktree_split vertical
    # set-option global kaktree_size 30%
    set-option global kaktree_double_click_duration '0.5'
    set-option global kaktree_indentation 1
} config %{
    hook global WinSetOption filetype=kaktree %{
        remove-highlighter buffer/numbers
        remove-highlighter buffer/matching
        remove-highlighter buffer/wrap
        remove-highlighter buffer/show-whitespaces
    }
    kaktree-enable
}

plug "ul/kak-tree" config %{
    # set-option global tree_cmd "kak-tree -c %val{config}/kak-tree.toml"
    declare-user-mode syntax-tree
    map global syntax-tree <space> ': tree-node-sexp<ret>'      -docstring 'tree node sexp'
    hook global WinSetOption filetype=(go) %{
        map window lang-mode t ': enter-user-mode syntax-tree<ret>' -docstring 'tree select'
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
        map window syntax-tree c ':tree-select- expression_case<a-b><left>'             -docstring 'expression_case'
        map window syntax-tree C ':tree-select- communication_case<a-b><left>'          -docstring 'communication_case'
    }
    hook global WinSetOption filetype=(rust) %{
        map window lang-mode t ': enter-user-mode syntax-tree<ret>' -docstring 'tree select'
        map window syntax-tree f ':tree-select- function_item<a-b><left>'        -docstring 'function_item'
        map window syntax-tree s ':tree-select- scoped_identifier<a-b><left>'    -docstring 'scoped_identifier'
    }

    # https://github.com/ul/kak-tree/issues/12
    try %{
        decl range-specs tree_first
        decl range-specs tree_next
        decl range-specs tree_prev
        decl range-specs tree_parent
        decl range-specs tree_children
    }
    def dyntree %{
        rmhooks window tree
        try %{
            addhl window/ ranges tree_children
            addhl window/ ranges tree_first
            addhl window/ ranges tree_prev
            addhl window/ ranges tree_next
            addhl window/ ranges tree_parent
        }
        hook -group tree window NormalIdle .* %{
            set window tree_children %val{timestamp}
            set window tree_first %val{timestamp}
            set window tree_prev %val{timestamp}
            set window tree_next %val{timestamp}
            set window tree_parent %val{timestamp}
            eval -draft -itersel %{ try %{
                tree-select-next-node
                set -add window tree_next "%val{selection_desc}|default+b"
            }}
            eval -draft -itersel %{ try %{
                tree-select-previous-node
                set -add window tree_prev "%val{selection_desc}|default+i"
            }}
            eval -draft -itersel %{ try %{
                tree-select-parent-node
                set -add window tree_parent "%val{selection_desc}|default,rgb:DBFFDB"
            }}
            eval -draft -itersel %{ try %{
                tree-select-children
                eval -draft -itersel %{
                    set -add window tree_children "%val{selection_desc}|default+u"
                }
            }}
            eval -draft -itersel %{ try %{
                tree-select-first
                set -add window tree_first "%val{selection_desc}|default,red"
            }}
        }
    }
}

# https://github.com/ul/kak-lsp/wiki/Usage-with-plug.kak
plug "ul/kak-lsp" config %{
    set-option global lsp_diagnostic_line_error_sign '║'
    set-option global lsp_diagnostic_line_warning_sign '┊'

    define-command lsp-restart -docstring 'restart lsp server' %{ lsp-stop; lsp-start }
    hook global WinSetOption filetype=(go|rust) %{
        set-option window lsp_auto_highlight_references true
        set-option window lsp_hover_anchor true
        set-face window DiagnosticError default+u
        set-face window DiagnosticWarning default+u
        echo -debug "Enabling LSP for filtetype %opt{filetype}"
        lsp-enable-window
        lsp-auto-signature-help-enable
        # lsp-diagnostic-lines-enable
        # lsp-auto-hover-enable
        # lsp-auto-hover-insert-mode-disable
        map -docstring "lsp-goto-next-match"         window lsp ']' '<esc>: lsp-goto-next-match;enter-user-mode lsp<ret>'    
        map -docstring "lsp-goto-previous-match"     window lsp '[' '<esc>: lsp-goto-previous-match;enter-user-mode lsp<ret>'
        map -docstring "find next error/warning"     window lsp 'n' '<esc>: lsp-find-error --include-warnings<ret>'           
        map -docstring "find previous error/warning" window lsp 'p' '<esc>: lsp-find-error --previous --include-warnings<ret>'
        map -docstring "jump *goto*"                 window lsp '<a-g>' '<esc>: jump *goto*<ret>'
        map -docstring "rename"                      window lsp '<ret>' '<esc>: lsp-rename '
        map -docstring "LSP mode"                    window user 'a' ': enter-user-mode lsp<ret>'

        # https://github.com/ul/kak-lsp/issues/273
        # hook window BufWritePre .* lsp-formatting-sync
    }

    hook global WinSetOption filetype=(rust) %{
        # bug https://github.com/ul/kak-lsp/issues/217#issuecomment-512793942
        set-option window lsp_server_configuration rust.clippy_preference="on"

        hook window -group rust-inlay-hints BufReload .* rust-analyzer-inlay-hints
        hook window -group rust-inlay-hints NormalIdle .* rust-analyzer-inlay-hints
        hook window -group rust-inlay-hints InsertIdle .* rust-analyzer-inlay-hints
        hook -once -always window WinSetOption filetype=.* %{
            remove-hooks window rust-inlay-hints
        }
        # set-face global InlayHint rgb:A3B3FF
        set-face global InlayHint rgb:eab700

        hook window -group semantic-tokens BufReload .* lsp-semantic-tokens
        hook window -group semantic-tokens NormalIdle .* lsp-semantic-tokens
        hook window -group semantic-tokens InsertIdle .* lsp-semantic-tokens
        hook -once -always window WinSetOption filetype=.* %{
            remove-hooks window semantic-tokens
        }
    }

    # hook global WinSetOption filetype=(go) %{
    #     hook -group lsp buffer BufWritePre .* lsp-formatting-sync
    # }

    hook global KakEnd .* lsp-exit
}

# plug "alexherbo2/bc.kak"
# plug "alexherbo2/search-highlighter.kak"
# plug "danr/kakoune-easymotion"
# plug "Delapouite/kakoune-auto-star"
# plug "andreyorst/powerline.kak" noload config %{
#     set-option global powerline_ignore_warnings true
#     set-option global powerline_format 'git bufname smarttab mode_info filetype client session position'
#     # hook -once global WinDisplay .* %{
#     #     powerline-theme github
#     # }
# }
# plug "alexherbo2/explore.kak"
# plug "alexherbo2/word-select.kak" config %{
#     map global normal w ': word-select-next-word<ret>'
#     map global normal <a-w> ': word-select-next-big-word<ret>'
#     map global normal b ': word-select-previous-word<ret>'
#     map global normal <a-b> ': word-select-previous-big-word<ret>'
# }
# plug "alexherbo2/yank-ring.kak" config %{
#     map -docstring 'yank ring' global normal 'Y' ': yank-ring<ret>'
# }
# plug "Delapouite/kakoune-registers"

