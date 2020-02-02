define-command -hidden \
-docstring "smart-select <w|a-w>: select <word> if current selection is only one character." \
smart-select -params 1 %{
    try %{
        execute-keys "<a-k>..<ret>"
    } catch %{
        execute-keys "<a-i><%arg{1}>"
    } catch nop
}

define-command -override -hidden \
-docstring "smart-select-file: tries to select file path in current line automatically." \
smart-select-file %{
    try %{
        execute-keys "<a-k>..<ret>"
    } catch %{
        # guess we have nonblank character under cursor
        execute-keys "<a-k>\w<ret>"
        execute-keys "<a-i><a-w>"
    } catch %{
        # try selecting inside first occurrence of <...> string
        execute-keys "<a-x>s<<ret>)<space>"
        execute-keys "<a-i>a"
    } catch %{
        # try selecting inside first occurrence of "..."
        execute-keys '<a-x>s"<ret>)<space>'
        execute-keys "<a-i>Q"
    } catch %{
        # try selecting inside first  occurrence of '...'
        execute-keys "<a-x>s'<ret>)<space>"
        execute-keys "<a-i>q"
    } catch %{
        # try select from cursor to the end of the line
        execute-keys "<a-l><a-k>\w<ret>"
    } catch %{
        # try select from beginning to the end of the line
        execute-keys "Gi<a-l><a-k>\w<ret>"
    } catch %{
        fail "no file can be selected"
    }
    try %{
        execute-keys "s/?\w[\S]+(?!/)<ret>)<space>"
    } catch %{
        fail "failed to select file"
    }
}

define-command -docstring \
"search-file <filename>: search for file recusively under path option: %opt{path}" \
search-file -params 1 %{ evaluate-commands %sh{
    if [ -n "$(command -v fd)" ]; then                          # create find command template
        find='fd -L --type f "${file}" "${path}"'               # if `fd' is installed it will
    else                                                        # be used because it is faster
        find='find -L "${path}" -mount -type f -name "${file}"' # if not, we fallback to find.
    fi

    file=$(printf "%s\n" $1 | sed -E "s:^~/:$HOME/:") # we want full path

    eval "set -- ${kak_quoted_buflist}"
    while [ $# -gt 0 ]; do            # Check if buffer with this
        if [ "${file}" = "$1" ]; then # file already exists. Basically
            printf "%s\n" "buffer $1" # emulating what edit command does
            exit
        fi
        shift
    done

    if [ -e "${file}" ]; then                     # Test if file exists under
        printf "%s\n" "edit -existing %{${file}}" # servers' working directory
        exit                                      # this is last resort until
    fi                                            # we start recursive searchimg

    # if everthing  above fails - search for file under `path'
    eval "set -- ${kak_quoted_opt_path}"
    while [ $# -gt 0 ]; do                # Since we want to check fewer places,
        case $1 in                        # I've swapped ./ and %/ because
            (./) path=${kak_buffile%/*} ;; # %/ usually has smaller scope. So
            (%/) path=${PWD}            ;; # this trick is a speedi-up hack.
            (*)  path=$1                ;; # This means that `path' option should
        esac                              # first contain `./' and then `%/'

        if [ -z "${file##*/*}" ] && [ -e "${path}/${file}" ]; then
            printf "%s\n" "edit -existing %{${path}/${file}}"
            exit
        else
            # build list of candidates or automatically select if only one found
            # this doesn't support files with newlines in them unfortunately
            IFS='
'
            for candidate in $(eval "${find}"); do
                [ -n "${candidate}" ] && candidates="${candidates} %{${candidate}} %{evaluate-commands %{edit -existing %{${candidate}}}}"
            done

            # we want to get out as early as possible
            # so if any candidate found in current cycle
            # we prompt it in menu and exit
            if [ -n "${candidates}" ]; then
                printf "%s\n" "menu -auto-single ${candidates}"
                exit
            fi
        fi

        shift
    done

    printf "%s\n" "echo -markup %{{Error}unable to find file '${file}'}"
}}

define-command -hidden -docstring \
"select a word under cursor, or add cursor on next occurrence of current selection" \
select-or-add-cursor %{
    try %{
        execute-keys "<a-k>\A.\z<ret>"
        execute-keys -save-regs '' "_<a-i>w*"
    } catch %{
        execute-keys -save-regs '' "_*<s-n>"
    } catch nop
}

define-command -override -docstring "symbol [<symbol>]: jump to symbol definition in current file.
If no symbol given, current selection is used as a symbol name" \
-shell-script-candidates %{
    tags="${TMPDIR:-/tmp}/tags-tmp"
    ctags -f "${tags}" "${kak_buffile}"
    cut -f 1 "${tags}" | grep -v '^!' | awk '!x[$0]++'
} symbol -params ..1 %[ evaluate-commands %sh[
    tags="${TMPDIR:-/tmp}/tags-tmp"
    tagname="${1:-${kak_selection}}"

    if [ ! -s "${tags}" ]; then
        ctags -f "${tags}" "${kak_buffile}"
    fi

    if [ -n "$(command -v readtags)" ]; then
        tags_cmd='readtags -t "${tags}" "${tagname}"'
    else
        tags_cmd='grep "^\b${tagname}\b.*\$/" "${tags}" -o'
    fi

    eval "${tags_cmd}" | tagname="$tagname" awk -F '\t|\n' '
        /[^\t]+\t[^\t]+\t\/\^.*\$?\// {
            line = $0; sub(".*\t/\\^", "", line); sub("\\$?/.*$", "", line);
            menu_info = line; gsub("!", "!!", menu_info); gsub(/^[\t ]+/, "", menu_info); gsub("{", "\\{", menu_info); gsub(/\t/, " ", menu_info);
            keys = line; gsub(/</, "<lt>", keys); gsub(/\t/, "<c-v><c-i>", keys); gsub("!", "!!", keys); gsub("&", "&&", keys); gsub("#", "##", keys); gsub("\\|", "||", keys); gsub("\\\\/", "/", keys);
            menu_item = ENVIRON["tagname"]; gsub("!", "!!", menu_item);
            edit_path = $2; gsub("&", "&&", edit_path); gsub("#", "##", edit_path); gsub("\\|", "||", edit_path);
            select = $1; gsub(/</, "<lt>", select); gsub(/\t/, "<c-v><c-i>", select); gsub("!", "!!", select); gsub("&", "&&", select); gsub("#", "##", select); gsub("\\|", "||", select);
            out = out "%!" menu_item ": {MenuInfo}" menu_info "! %!evaluate-commands %# try %& edit -existing %|" edit_path "|; execute-keys %|/\\Q" keys "<ret>vc| & catch %& echo -markup %|{Error}unable to find tag| &; try %& execute-keys %|s\\Q" select "<ret>| & # !"
        }
        /[^\t]+\t[^\t]+\t[0-9]+/ {
            menu_item = $2; gsub("!", "!!", menu_item);
            select = $1; gsub(/</, "<lt>", select); gsub(/\t/, "<c-v><c-i>", select); gsub("!", "!!", select); gsub("&", "&&", select); gsub("#", "##", select); gsub("\\|", "||", select);
            menu_info = $3; gsub("!", "!!", menu_info); gsub("{", "\\{", menu_info);
            edit_path = $2; gsub("!", "!!", edit_path); gsub("#", "##", edit_path); gsub("&", "&&", edit_path); gsub("\\|", "||", edit_path);
            line_number = $3;
            out = out "%!" menu_item ": {MenuInfo}" menu_info "! %!evaluate-commands %# try %& edit -existing %|" edit_path "|; execute-keys %|" line_number "gx| & catch %& echo -markup %|{Error}unable to find tag| &; try %& execute-keys %|s\\Q" select "<ret>| & # !"
        }
        END { print ( length(out) == 0 ? "echo -markup %{{Error}no such tag " ENVIRON["tagname"] "}" : "menu -markup -auto-single " out ) }'
]]

define-command -docstring "evaluate-buffer: evaluate current buffer contents as kakscript" \
evaluate-buffer %{
    execute-keys -draft '%:<space><c-r>.<ret>'
}

define-command -docstring "evaluate-selection: evaluate current sellection contents as kakscript" \
evaluate-selection %{
    execute-keys -itersel -draft ':<space><c-r>.<ret>'
}

# Tab completion.
define-command tab-completion-enable %{
  hook -group tab-completion global InsertCompletionShow .* %{ try %{
    execute-keys -draft 'h<a-K>\h<ret>'
    map window insert <tab> <c-n>
    map window insert <s-tab> <c-p>
    map window insert <down> <c-n>
    map window insert <up> <c-p>
    # map window insert <c-g> <c-o>
  }}
  hook -group tab-completion global InsertCompletionHide .* %{
    unmap window insert <tab> <c-n>
    unmap window insert <s-tab> <c-p>
    unmap window insert <down> <c-n>
    unmap window insert <up> <c-p>
    # unmap window insert <c-g> <c-o>
  }
}
define-command tab-completion-disable %{ remove-hooks global tab-completion }

define-command pairwise-enable %~
    hook -group pairwise global InsertChar \) %{ try %{
        execute-keys -draft h2H <a-k>\Q())\E<ret>
        execute-keys <backspace><left>
    }}
    hook -group pairwise global InsertChar \] %{ try %{
        execute-keys -draft h2H <a-k>\Q[]]\E<ret>
        execute-keys <backspace><left>
    }}
    hook -group pairwise global InsertChar \} %[ try %[
        execute-keys -draft h2H <a-k>\Q{}}\E<ret>
        execute-keys <backspace><left>
    ]]
    hook -group pairwise global InsertChar > %{ try %{
        execute-keys -draft h2H <a-k>\Q<lt><gt><gt>\E<ret>
        execute-keys <backspace><left>
    }}
~
define-command pairwise-disable %{ remove-hooks global pairwise }

# search-highlighting.kak, simplified of
# plug "alexherbo2/search-highlighter.kak"
define-command -docstring "Enable search highlighting" \
search-highlighting-enable %{
  hook window -group search-highlighting NormalKey [/?*nN]|<a-[/?*nN]> %{ try %{
    addhl window/SearchHighlighting dynregex '%reg{/}' 0:Search
  }}
  hook window -group search-highlighting NormalKey <esc> %{ rmhl window/SearchHighlighting }
}
define-command -docstring "Disable search highlighting" \
search-highlighting-disable %{
  rmhl window/SearchHighlighting
  rmhooks window search-highlighting
}

# Basic autoindent.
define-command -hidden basic-autoindent-on-newline %{
  eval -draft -itersel %{
    try %{ exec -draft ';K<a-&>' }                      # copy indentation from previous line
    try %{ exec -draft ';k<a-x><a-k>^\h+$<ret>H<a-d>' } # remove whitespace from autoindent on previous line
  }
}
define-command basic-autoindent-enable %{
  hook -group basic-autoindent window InsertChar '\n' basic-autoindent-on-newline
  hook -group basic-autoindent window WinSetOption 'filetype=.*' basic-autoindent-disable
}
define-command basic-autoindent-disable %{ rmhooks window basic-autoindent }

# def selection-length %{echo %sh{echo ${#kak_selection} }}
define-command selection-length %{
    eval %sh{ echo "echo ${#kak_selection}" }
}

define-command trim-trailing-whitespace -docstring "trim trailing whitespaces" %{
  try %{
    eval -draft %{
      exec '%s\h+$<ret><a-d>'
      eval -client %val{client} echo -markup -- \
        %sh{ echo "{Information}trimmed trailing whitespaces on $(echo "$kak_selections_desc" | wc -w) lines" }
    }
  } catch %{
    echo -markup "{Information}no trailing whitespaces"
  }
}

# define-command enlarge-selection %{
#   exec '<a-:>L<a-;>H<a-:>'
# }
# define-command shrink-selection %{
#   exec '<a-:>H<a-;>L<a-:>'
# }
# define-command shift-selection-left %{
#   exec '<a-:>H<a-;>H<a-:>'
# }
# define-command shift-selection-right %{
#   exec '<a-:>L<a-;>L<a-:>'
# }

define-command slice-by-word %{
  exec s[A-Z][a-z]+|[A-Z]+|[a-z]+<ret>
}

# https://github.com/mawww/kakoune/wiki/Selections#how-to-convert-between-common-case-conventions
# foo_bar → fooBar
# foo-bar → fooBar
# foo bar → fooBar
define-command camelcase %{
  exec '`s[-_<space>]<ret>d~<a-i>w'
}

# fooBar → foo_bar
# foo-bar → foo_bar
# foo bar → foo_bar
define-command snakecase %{
  exec '<a-:><a-;>s-|[a-z][A-Z]<ret>\;a<space><esc>s[-\s]+<ret>c_<esc><a-i>w`'
}

# fooBar → foo-bar
# foo_bar → foo-bar
# foo bar → foo-bar
define-command kebabcase %{
  exec '<a-:><a-;>s_|[a-z][A-Z]<ret>\;a<space><esc>s[_\s]+<ret>c-<esc><a-i>w`'
}

# https://github.com/mawww/kakoune/wiki/Selections#how-to-make-x-select-lines-downward-and-x-select-lines-upward
define-command -hidden -params 1 extend-line-down %{
  exec "<a-:>%arg{1}X"
}
define-command -hidden -params 1 extend-line-up %{
  exec "<a-:><a-;>%arg{1}K<a-;>"
  try %{
    exec -draft ';<a-K>\n<ret>'
    exec X
  }
  exec '<a-;><a-X>'
}

# https://github.com/mawww/kakoune/wiki/Normal-mode-commands#suggestions
# if you press 0 alone, it will echo "foo".
# if you press 0 after a number to express a count, like 10, it will work as usual.
define-command -hidden -params 1 zero %{
   evaluate-commands %sh{
        if [ $kak_count = 0 ]; then
            echo "$1"
        else
            echo "execute-keys ${kak_count}0"
        fi
    }
}

# https://github.com/alyssais/dotfiles/blob/master/.config/kak/kakrc#L30-L38
define-command -docstring "import from the system clipboard" clipboard-import %{
  set-register dquote %sh{pbpaste}
  echo -markup "{Information}imported system clipboard to "" register"
}
define-command -docstring "export to the system clipboard" clipboard-export %{
  nop %sh{ printf "%s" "$kak_main_reg_dquote" | pbcopy }
  echo -markup "{Information}exported "" register to system clipboard"
}
define-command -docstring "choose from tmux buffer into "" reg" tmux-choose-buffer %{
    # evaluate-commands -no-hooks %sh{
    #     output="${TMPDIR:-/tmp}/tmux-buffer"
    #     tmux choose-buffer "save-buffer -b '%%' ${output}"
    #     printf "set-register dquote %%sh{cat %s}\n" ${output}
    #     printf "echo -debug %%sh{cat %s}\n" ${output}
    # }
    evaluate-commands -no-hooks %sh{
        output=$(mktemp -d -t kak-temp-XXXXXXXX)/fifo
        mkfifo ${output}
        tmux choose-buffer "save-buffer -b '%%' ${output}"
        echo "edit! -fifo ${output} *tmux-buffer*
              hook buffer BufClose .* %{ nop %sh{ rm -r $(dirname ${output})} }"
    }
}

# Sort of a replacement for gq.
# def format-par %{ exec '|par -w%opt{autowrap_column}<a-!><ret>' }
# def format-text %{ exec '|fmt -w 80<ret>: echo -markup {green}[sel] | fmt -w 80<ret>' }
define-command format-text %{ exec '|fmt %opt{autowrap_column}<a-!><ret>' }
define-command format-comment %{ exec '<a-s>ght/F<space>dx<a-_>|fmt<a-!><ret><a-s>Px<a-_>' }

# https://github.com/shachaf/kak/blob/c2b4a7423f742858f713f7cfe2511b4f9414c37e/kakrc#L218
# define-command select-word-better %{
#   # Note: \w doesn't use extra_word_chars.
#   eval -itersel %{
#     try %{ exec '<a-i>w' } catch %{ exec '<a-l>s\w<ret>) <a-i>w' } catch %{}
#   }
#   exec '<a-k>\w<ret>'
# }
# define-command select-WORD-better %{
#   eval -itersel %{
#     try %{ exec '<a-i><a-w>' } catch %{ exec '<a-l>s\S<ret>) <a-i><a-w>' } catch %{}
#   }
#   exec '<a-k>\S<ret>'
# }

# https://github.com/shachaf/kak/blob/c2b4a7423f742858f713f7cfe2511b4f9414c37e/kakrc#L241
# define-command switch-to-modified-buffer %{
#   eval -save-regs a %{
#     reg a ''
#     try %{
#       eval -buffer * %{
#         eval %sh{[ "$kak_modified" = true ] && echo "reg a %{$kak_bufname}; fail"}
#       }
#     }
#     eval %sh{[ -z "$kak_main_reg_a" ] && echo "fail 'No modified buffers!'"}
#     buffer %reg{a}
#   }
# }

# Git extras.
# https://github.com/shachaf/kak/blob/c2b4a7423f742858f713f7cfe2511b4f9414c37e/kakrc#L381
define-command git-show-blamed-commit %{
  git show %sh{git blame -L "$kak_cursor_line,$kak_cursor_line" "$kak_buffile" | awk '{print $1}'}
}
define-command git-log-lines %{
  git log -L %sh{
    anchor="${kak_selection_desc%,*}"
    anchor_line="${anchor%.*}"
    echo "$anchor_line,$kak_cursor_line:$kak_buffile"
  }
}
define-command git-toggle-blame %{
  try %{
    addhl window/git-blame group
    rmhl window/git-blame
    git blame
  } catch %{
    git hide-blame
  }
}
define-command git-hide-diff %{ rmhl window/git-diff }

# https://github.com/shachaf/kak/blob/c2b4a7423f742858f713f7cfe2511b4f9414c37e/kakrc#L355
define-command -docstring "switch to the other client's buffer" \
  other-client-buffer \
  %{ eval %sh{
  if [ "$(echo "$kak_client_list" | wc -w)" -ne 2 ]; then
    echo "fail 'only works with two clients'"
    exit
  fi
  set -- $kak_client_list
  other_client="$1"
  [ "$other_client" = "$kak_client" ] && other_client="$2"
  echo "eval -client '$other_client' 'eval -client ''$kak_client'' \"buffer ''%val{bufname}''\"'"
}}

# https://github.com/shachaf/kak/blob/c2b4a7423f742858f713f7cfe2511b4f9414c37e/kakrc#L347
define-command man-selection-with-count %{
  man %sh{
    page="$kak_selection"
    [ "$kak_count" != 0 ] && page="${page}(${kak_count})"
    echo "$page"
  }
}

# Hull
# ‾‾‾‾

# https://github.com/mawww/kakoune/wiki/Selections#how-to-select-the-smallest-single-selection-containing-every-selection
# https://github.com/shachaf/kak/blob/c2b4a7423f742858f713f7cfe2511b4f9414c37e/kakrc#L302
define-command selection-hull \
  -docstring 'The smallest single selection containing every selection.' \
  %{
  eval -save-regs 'ab' %{
    exec '"aZ' '<space>"bZ'
    try %{ exec '"az<a-space>' }
    exec -itersel '"b<a-Z>u'
    exec '"bz'
    echo
  }
}

# Flygrep
# ‾‾‾‾‾‾‾

define-command -docstring "flygrep: run grep on every key" \
flygrep %{
    edit -scratch *grep*
    prompt "flygrep: " -on-change %{
        flygrep-call-grep %val{text}
    } nop
}

define-command -hidden flygrep-call-grep -params 1 %{ evaluate-commands %sh{
    [ -z "${1##*&*}" ] && text=$(printf "%s\n" "$1" | sed "s/&/&&/g") || text="$1"
    if [ ${#1} -gt 2 ]; then
        printf "%s\n" "info"
        printf "%s\n" "evaluate-commands %&grep '$text'&"
    else
        printf "%s\n" "info -title flygrep %{$((3-${#1})) more chars}"
    fi
}}

# https://github.com/mawww/kakoune/issues/1106
# https://discuss.kakoune.com/t/repeating-a-character-n-times-in-insert-mode/670
define-command -params 1 count-insert %{
    execute-keys -with-hooks \;i.<esc>hd %arg{1} P %arg{1} Hs.<ret><a-space>c
}

# Jump
# ‾‾‾‾

declare-option -hidden str jump_search_result

define-command -hidden -params 1 jump-helper %{
    evaluate-commands %sh{
        if [ "$1" -ef "${kak_buffile}" ]; then
            printf 'set-option global jump_search_result "%s"\n' "${kak_client}"
        fi
    }
}

define-command -override \
    -docstring %{jump [<options>] <file> [<line> [<column>]]

Takes all the same switches as edit.} \
    -params 1..3 \
    -file-completion \
    jump %{
    set-option global jump_search_result %opt{jumpclient}
    evaluate-commands %sh{
        for client in ${kak_client_list}; do
            echo "evaluate-commands -client \"${client}\" %{jump-helper \"$1\"}"
        done
    }
    evaluate-commands -try-client %opt{jump_search_result} %{
        edit %arg{@}
        try %{ focus }
    }
}

# Misc
# ‾‾‾‾

define-command mkdir %{ nop %sh{ mkdir -p $(dirname $kak_buffile) } } -docstring "Creates the directory up to this file"

define-command rm %{
    nop %sh{ rm -f "$kak_buffile" }
    delete-buffer!
}

define-command \
    -override \
    -docstring %{mv <target>: move this file to <target> dir or file} \
    -shell-script-candidates %{fd --type f} \
    -params 1 \
    mv %{
    evaluate-commands %sh{
        target="$1"
        if $kak_modified; then
            printf 'fail "mv: buffer is modified."\n'
            exit
        fi
        if [ -d "$target" ]; then
            target="${target}/$(basename "$kak_buffile")"
        fi
        mkdir -p "$(dirname "$target")"
        mv "$kak_buffile" "$target"
        if [ $? -ne 0 ]; then
            printf 'fail "mv: unable to move file."\n'
            exit
        fi
        printf 'delete-buffer\n'
        printf 'edit %%{%s}\n' "$target"
    }
}

# https://discuss.kakoune.com/t/rfr-roll-back-through-old-versions-of-a-file-in-git/743
define-command git-edit-force 'edit!; nop %sh(git reset -- "$kak_buffile"); git checkout'
alias global ge! git-edit-force
