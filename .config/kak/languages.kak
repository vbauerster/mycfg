# Go
# ‾‾‾‾
hook global WinSetOption filetype=(go) %{
    evaluate-commands %sh{
        # if [ -n "$(command -v fd)" ]; then
        #     echo "set-option buffer fzf_file_command %{fd --no-ignore --type f --follow --exclude .git --exclude vendor .}"
        # fi
        if [ -n "$(command -v rg)" ]; then
            echo "set-option buffer grepcmd %{rg --column -tgo -g=!vendor}"
        fi
    }
    set-option buffer matching_pairs '(' ')' '{' '}' '[' ']'
    # set-option buffer auto_pairs '(' ')' '{' '}' '[' ']' '"' '"' '''' '''' '`' '`'
    set-option buffer indentwidth 0 # 0 means real tab
    set-option buffer formatcmd 'goimports'
    set-option buffer lintcmd 'gometalinter .'
    set-option buffer makecmd 'go build .'
    # alias window jump-to-definition go-jump
    # set buffer lintcmd '(gometalinter | grep -v "::\w")  <'
    # map global goto u '<esc>: go-jump<ret>' -docstring 'go-jump'
    # map global help-and-hovers d ': go-doc-info<ret>' -docstring 'go-doc-info'

    # hook buffer BufWritePre .* %{ format }
    map buffer lang-mode o %{:grep ^func|^import|^var|^package|^const|^goto|^struct|^type %val{bufname} -H<ret>} -docstring "Show outline"
    # map buffer lang-mode o ': godecls<ret>' -docstring 'godecl outline'
}

# C/Cpp
# ‾‾‾‾‾
hook global WinSetOption filetype=(c|cpp) %{
    set-option buffer formatcmd 'clang-format'
    set-option buffer matching_pairs '{' '}' '[' ']' '(' ')'
}

hook global ModuleLoaded c-family %{ try %{ evaluate-commands %sh{
    join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }

    # taken from rc/filetype/c-family.kak
    c_keywords='asm break case continue default do else for goto if return
                sizeof switch while offsetof alignas alignof'

    cpp_keywords='alignas alignof and and_eq asm bitand bitor break case catch
                  compl const_cast continue decltype delete do dynamic_cast
                  else export for goto if new not not_eq operator or or_eq
                  reinterpret_cast return sizeof static_assert static_cast switch
                  throw try typedef typeid using while xor xor_eq'

    # Highlight functions ignoring C and C++ specific keywords. Ugly hack, because we must not override keyword highlighting
    printf "%s\n" "add-highlighter shared/c/code/my_functions   regex (\w*?)\b($(join '${c_keywords}' '|'))?(\h+)?(?=\() 1:function
                   add-highlighter shared/cpp/code/my_functions regex (\w*?)\b($(join '${cpp_keywords}' '|'))?(\h+)?(?=\() 1:function"

    # Namespace highlighting for C++
    printf "%s\n" "add-highlighter shared/cpp/code/namespace regex _?[a-zA-Z](\w+)?(\h+)?(?=::) 0:module"

    # Types and common highlightings. Same for C and C++
    for ft in c cpp; do
        printf "%s\n" "add-highlighter shared/$ft/code/my_field     regex (?:(?<!\.\.)(?<=\.)|(?<=->))(_?[a-zA-Z]\w*)\b(?![>\"\(]) 1:meta
                       add-highlighter shared/$ft/code/my_return    regex \breturn\b 0:meta
                       add-highlighter shared/$ft/code/my_types_1   regex \b(v|u|vu)\w+(8|16|32|64)\b 0:type
                       add-highlighter shared/$ft/code/my_types_2   regex \b(v|u|vu)?(_|__)?(s|u)(8|16|32|64)\b 0:type
                       add-highlighter shared/$ft/code/my_types_3   regex \b(v|u|vu)(_|__)?(int|short|char|long)\b 0:type
                       add-highlighter shared/$ft/code/struct_type  regex struct\h+(\w+) 1:type
                       add-highlighter shared/$ft/code/generic_type regex \b\w+_t\b 0:type
                       add-highlighter shared/$ft/code/type_cast    regex \((?:volatile\h*)?([^(]\w+\h*[^()*]*)(?:\*\h*)\)\h*(?:\(|[&*]?\w+) 1:type
                       add-highlighter shared/$ft/code/func_pointer regex (\w+)\h*\(\*\h*(\w+)\)\([^)]*\) 1:type 2:function"
    done
}}}

# Rust
# ‾‾‾‾
hook global WinSetOption filetype=(rust) %{
    # set-option buffer matching_pairs '(' ')' '[' ']' '{' '}'
    set-register @ 'A;<esc>'
    evaluate-commands %sh{
        # if [ -n "$(command -v fd)" ]; then
        #     echo "set-option buffer fzf_file_command %{fd --no-ignore --type f --follow --exclude .git --exclude target .}"
        # fi
        if [ -n "$(command -v rg)" ]; then
            echo "set-option buffer grepcmd %{rg --column -trust -g=!target}"
        fi
    }
    hook window InsertChar \Q-\E %{ try %{
        execute-keys -draft h2H <a-k>\Q)<space><minus>\E<ret>
        execute-keys <gt>
    }}
    hook window InsertChar \' %{
        try %{
            execute-keys -draft hH <a-k>\Q<lt>'\E<ret>
            execute-keys a
        }
        try %{
            execute-keys -draft hH <a-k>\Q&'\E<ret>
            execute-keys a
        }
    }
    hook window InsertChar \? %{ try %{
        execute-keys -draft hH <a-k>\Q{?\E<ret>
        execute-keys <left>:<right>}
    }}
    hook window InsertChar '#' %{ try %{
        execute-keys -draft hH <a-k>\Q{#\E<ret>
        execute-keys <left>:<right>?}
    }}
}

# Makefile
# ‾‾‾‾‾‾‾‾
hook global BufCreate .*\.mk$ %{
    set-option buffer filetype makefile
}

# Kakscript
# ‾‾‾‾‾‾‾‾‾
hook global WinSetOption filetype=(kak) %{ hook global NormalIdle .* %{
    evaluate-commands -save-regs 'a' %{ try %{
        execute-keys -draft <a-i>w"ay
        evaluate-commands %sh{ (
            color="${kak_reg_a}"
            inverted_color=$(echo "${color}" | perl -pe 'tr/0123456789abcdefABCDEF/fedcba9876543210543210/')
            printf "%s\n" "evaluate-commands -client $kak_client %{ try %{
                               echo -markup %{{rgb:${inverted_color},rgb:${color}+b}   #${color}   }
                           }}" | kak -p $kak_session
        ) >/dev/null 2>&1 </dev/null & }
    }}
}}

hook global WinSetOption filetype=(sql) %{
    map buffer lang-mode o %{: grep ^INSERT|^UPDATE|^DELETE|^CREATE|^DROP' %val{bufname} -H -i<ret>} -docstring "Show outline"
}

# Highlight any files whose names start with "zsh" as sh
hook global BufCreate (.*/)?\.?zsh.* %{
    set-option buffer filetype sh
}

# Highlight files ending in .conf as ini
# (Will probably be close enough)
hook global BufCreate .*\.conf %{
    set-option buffer filetype ini
}

# hook global WinSetOption filetype=(js) %{
#     set buffer formatcmd 'js-beautify -a -j -B --good-stuff'
# }

# hook global WinSetOption filetype=(json) %{
#     set buffer formatcmd 'js-beautify'
# }

hook global WinSetOption filetype=(yaml) %{
    set-option buffer tabstop 2
    set-option buffer indentwidth 2
}
