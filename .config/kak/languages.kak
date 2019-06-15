# Go
# ‾‾‾‾
hook global WinSetOption filetype=(go) %{
    # try %{ set-option buffer grepcmd 'rg --column -tgo -g=!vendor' }
    evaluate-commands %sh{
        if [ -n "$(command -v fd)" ]; then
            echo "set-option buffer fzf_file_command %{fd --no-ignore --type f --follow --exclude .git --exclude vendor .}"
        fi
        if [ -n "$(command -v rg)" ]; then
            echo "set-option buffer grepcmd %{rg --column -tgo -g=!vendor}"
        fi
    }
    set-option buffer matching_pairs '(' ')' '{' '}' '[' ']'
    # set-option buffer auto_pairs '(' ')' '{' '}' '[' ']' '"' '"' '''' '''' '`' '`'
    # indentwidth 0 means a tab character
    set-option buffer indentwidth 0
    set-option buffer formatcmd 'goimports'
    # alias window jump-to-definition go-jump
    # set buffer lintcmd '(gometalinter | grep -v "::\w")  <'
    # map global goto u '<esc>: go-jump<ret>' -docstring 'go-jump'
    # map global help-and-hovers d ': go-doc-info<ret>' -docstring 'go-doc-info'

    hook buffer BufWritePre .* %{ format }
}

# C/Cpp
# ‾‾‾‾‾
hook global WinSetOption filetype=(c|cpp) %{
    set-face buffer delimiter rgb:aa3a03,default
    set-option buffer formatcmd 'clang-format'
    set-option buffer matching_pairs '{' '}' '[' ']' '(' ')'

    try %{
        remove-highlighter buffer/operators
        add-highlighter    buffer/operators regex (\+|-|\*|&|=|\\|\?|%|\|-|!|\||->|\.|,|<|>|:|\^|/|~|\[|\]) 0:operator
    }
    try %{
        remove-highlighter buffer/delimiters
        add-highlighter    buffer/delimiters regex (\(|\)||\{|\}|\;|'|`) 0:delimiter
    }
}

hook global ModuleLoad c-family %{ try %{ evaluate-commands %sh{
    join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }

    # taken from rc/filetype/c-family.kak
    c_keywords='asm break case continue default do else for goto if return
                sizeof switch while offsetof alignas alignof'

    # Highlight functions ignoring C specific keywords
    printf "%s\n" "add-highlighter shared/c/code/my_functions regex (\w*?)\b($(join '${c_keywords}' '|'))?(\h+)?(?=\() 1:function"

    # taken from rc/filetype/c-family.kak
    cpp_keywords='alignas alignof and and_eq asm bitand bitor break case catch
                  compl const_cast continue decltype delete do dynamic_cast
                  else export for goto if new not not_eq operator or or_eq
                  reinterpret_cast return sizeof static_assert static_cast switch
                  throw try typedef typeid using while xor xor_eq'

    # Highlight functions ignoring C++ specific keywords
    printf "%s\n" "add-highlighter shared/cpp/code/functions regex (\w*?)\b($(join '${cpp_keywords}' '|'))?(\h+)?(?=\() 1:function"
    # Namespace highlighting
    printf "%s\n" "add-highlighter shared/cpp/code/namespace  regex [a-zA-Z](\w+)?(\h+)?(?=::) 0:module"
    # Types and common highlightings. Same for C and C++
    for filetype in c cpp; do
        printf "%s\n" "add-highlighter shared/$filetype/code/my_field   regex ((?<!\.\.)(?<=\.)|(?<=->))[a-zA-Z](\w+)?\b(?![>\"\(]) 0:meta
                       add-highlighter shared/$filetype/code/my_method  regex ((?<!\.\.)(?<=\.)|(?<=->))[a-zA-Z](\w+)?(\h+)?(?=\() 0:function
                       add-highlighter shared/$filetype/code/my_return  regex \breturn\b 0:meta
                       add-highlighter shared/$filetype/code/my_types_1 regex \b(v|u|vu)\w+(8|16|32|64)(_t)?\b 0:type
                       add-highlighter shared/$filetype/code/my_types_2 regex \b(v|u|vu)?(_|__)?(s|u)(8|16|32|64)(_t)?\b 0:type
                       add-highlighter shared/$filetype/code/my_types_3 regex \b(v|u|vu)(_|__)?(int|short|char|long)(_t)?\b 0:type
                       add-highlighter shared/$filetype/code/my_types_4 regex \b\w+_t\b 0:type
                       add-highlighter shared/$filetype/code/my_types_5 regex \((\w+)\h*\*\)\h*\w+ 1:type"
    done
}}}

# Rust
# ‾‾‾‾
hook global WinSetOption filetype=(rust) %{
    # set-option buffer formatcmd 'rustfmt'
    set-option buffer matching_pairs '{' '}' '[' ']' '(' ')'
    evaluate-commands %sh{
        if [ -n "$(command -v fd)" ]; then
            echo "set-option buffer fzf_file_command %{fd --no-ignore --type f --follow --exclude .git --exclude target .}"
        fi
        if [ -n "$(command -v rg)" ]; then
            echo "set-option buffer grepcmd %{rg --column -trust -g=!target}"
        fi
    }
}

hook global ModuleLoad rust %{ try %{ evaluate-commands %sh{
    # Taken from rc/filetype/rust.kak
    rust_keywords="let as fn return match if else loop for in while
                   break continue move box where impl dyn pub unsafe"

    join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }

    # Highlight functions ignoring Rust specific keywords
    printf "%s\n" "add-highlighter shared/rust/code/functions regex ([_a-z]?\w*)\b($(join '${rust_keywords}' '|'))?\h*(?=\() 1:function"

    # Common highlightings for Rust
    printf "%s\n" "add-highlighter shared/rust/code/field     regex ((?<!\.\.)(?<=\.))[_a-zA-Z](\w+)?\b(?![>\"\(]) 0:meta
                   add-highlighter shared/rust/code/method    regex ((?<!\.\.)(?<=\.))[_a-zA-Z](\w+)?(\h+)?(?=\() 0:function
                   add-highlighter shared/rust/code/return    regex \breturn\b 0:meta
                   add-highlighter shared/rust/code/usertype  regex \b[A-Z]\w*\b 0:type
                   add-highlighter shared/rust/code/namespace regex [a-zA-Z](\w+)?(\h+)?(?=::) 0:module"
}}}

# hook global WinSetOption filetype=(js) %{
#     set buffer formatcmd 'js-beautify -a -j -B --good-stuff'
# }

# hook global WinSetOption filetype=(json) %{
#     set buffer formatcmd 'js-beautify'
# }

# Markdown
# ‾‾‾‾‾‾‾‾
hook -once global WinSetOption filetype=(markdown) %{
    define-command markdown-require-highlighters %{ evaluate-commands -save-regs 'a' %{ try %{
        execute-keys -draft 'gtGbGls```\h*\K[^\s]+<ret>"ay'
        nop %sh{ (
            eval "set -- $kak_reg_a"
            while [ $# -gt 0 ]; do
                case $1 in
                    c|cpp|c++|objc) module="c-family"   ;;
                    cabal)          module="cabal"      ;;
                    clojure)        module="clojure"    ;;
                    coffee)         module="coffee"     ;;
                    css)            module="css"        ;;
                    cucumber)       module="cucumber"   ;;
                    d)              module="d"          ;;
                    dockerfile)     module="dockerfile" ;;
                    fish)           module="fish"       ;;
                    gas)            module="gas"        ;;
                    go)             module="go"         ;;
                    haml)           module="haml"       ;;
                    haskell)        module="haskell"    ;;
                    html)           module="html"       ;;
                    ini)            module="ini"        ;;
                    java)           module="java"       ;;
                    javascript)     module="javascript" ;;
                    json)           module="json"       ;;
                    julia)          module="julia"      ;;
                    kak)            module="kakrc"      ;;
                    kickstart)      module="kickstart"  ;;
                    latex)          module="latex"      ;;
                    lisp)           module="lisp"       ;;
                    lua)            module="lua"        ;;
                    makefile)       module="makefile"   ;;
                    markdown)       module="markdown"   ;;
                    moon)           module="moon"       ;;
                    perl)           module="perl"       ;;
                    pug)            module="pug"        ;;
                    python)         module="python"     ;;
                    ragel)          module="ragel"      ;;
                    ruby)           module="ruby"       ;;
                    rust)           module="rust"       ;;
                    sass)           module="sass"       ;;
                    scala)          module="scala"      ;;
                    scss)           odule="scss"        ;;
                    sh)             module="sh"         ;;
                    swift)          module="swift"      ;;
                    toml)           module="toml"       ;;
                    tupfile)        module="tupfile"    ;;
                    typescript)     module="typescript" ;;
                    yaml)           module="yaml"       ;;
                    sql)            module="sql"        ;;
                esac
                [ -n "$module" ] && printf "%s\n" "evaluate-commands -client $kak_client %{ require-module $module }"
                module=
                shift
            done | kak -p $kak_session
        ) > /dev/null 2>&1 < /dev/null & }
    }}}


    hook buffer NormalIdle .* markdown-require-highlighters
    hook buffer InsertIdle .* markdown-require-highlighters
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
        evaluate-commands %sh{
            color=$(echo "$kak_reg_a" | perl -pe "s/'//g")
            inverted_color=$(echo "${color}" | perl -pe 'tr/0123456789abcdefABCDEF/fedcba9876543210543210/')
            printf "%s\n" "echo -markup %{{rgb:${inverted_color},rgb:${color}+b}  #${color}  }"
        }
    }}
}}

# Highlight any files whose names start with "zsh" as sh
hook global BufCreate (.*/)?\.?zsh.* %{
    set-option buffer filetype sh
}

# Highlight files ending in .conf as ini
# (Will probably be close enough)
hook global BufCreate .*\.conf %{
    set-option buffer filetype ini
}

