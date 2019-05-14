
# Go
# ‾‾‾‾
hook global WinSetOption filetype=(go) %{
    try %{ set-option buffer grepcmd 'rg --column -tgo -g=!vendor' }
    set-option buffer matching_pairs '(' ')' '{' '}' '[' ']'
    set-option buffer auto_pairs '(' ')' '{' '}' '[' ']' '"' '"' '''' '''' '`' '`'
    set-option buffer indentwidth 0
    set-option buffer formatcmd 'goimports'
    # alias window jump-to-definition go-jump
    # set buffer lintcmd '(gometalinter | grep -v "::\w")  <'
    # map global goto u '<esc>: go-jump<ret>' -docstring 'go-jump'
    # map global help-and-hovers d ': go-doc-info<ret>' -docstring 'go-doc-info'

    hook buffer BufWritePre .* %{ format }
}

# Rust
# ‾‾‾‾
hook global WinSetOption filetype=(rust) %{
    set-option buffer formatcmd 'rustfmt'
    set-option buffer matching_pairs '{' '}' '[' ']' '(' ')'

    evaluate-commands %sh{
        # Common highlightings for Rust
        printf "%s\n" "add-highlighter shared/rust/code/field     regex ((?<!\.\.)(?<=\.))[a-zA-Z](\w+)?\b(?![>\"\(]) 0:meta
                       add-highlighter shared/rust/code/method    regex ((?<!\.\.)(?<=\.))[a-zA-Z](\w+)?(\h+)?(?=\() 0:function
                       add-highlighter shared/rust/code/return    regex \breturn\b 0:meta
                       add-highlighter shared/rust/code/usertype  regex \b[A-Z]\w*\b 0:type
                       add-highlighter shared/rust/code/namespace regex [a-zA-Z](\w+)?(\h+)?(?=::) 0:module"

        # Taken from rc/filetype/rust.kak
        rust_keywords="let as fn return match if else loop for in while
                       break continue move box where impl dyn pub unsafe"

        join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }

        # Highlight functions ignoring Rust specific keywords
        printf "%s\n" "add-highlighter shared/rust/code/functions regex (\w*?)\b($(join '${rust_keywords}' '|'))?\h*(?=\() 1:function"
    }
}

# hook global WinSetOption filetype=(c|cpp) %{
#     clang-enable-autocomplete; clang-enable-diagnostics
#     alias window lint clang-parse
#     alias window lint-next-error clang-diagnostics-next
#     alias window lint-next-error clang-diagnostics-next
#     map window object ';' '/\*,\*/<ret>'
# }

hook global WinSetOption filetype=(js) %{
    set buffer formatcmd 'js-beautify -a -j -B --good-stuff'
}

hook global WinSetOption filetype=(json) %{
    set buffer formatcmd 'js-beautify'
}

# Markdown
# ‾‾‾‾‾‾‾‾
hook global WinSetOption filetype=(markdown) %{
    remove-highlighter buffer/operators
    remove-highlighter buffer/delimiters
}

# Makefile
# ‾‾‾‾‾‾‾‾
hook global BufCreate .*\.mk$ %{
    set-option buffer filetype makefile
}

# Kakscript
# ‾‾‾‾‾‾‾‾‾
hook global WinSetOption filetype=(kak) %{
    hook global NormalIdle .* %{
        evaluate-commands -save-regs 'a' %{ try %{
            execute-keys -draft <a-i>w"ay
            evaluate-commands %sh{
                color=$(echo "$kak_reg_a" | perl -pe "s/'//g")
                inverted_color=$(echo "${color}" | perl -pe 'tr/0123456789abcdefABCDEF/fedcba9876543210543210/')
                printf "%s\n" "echo -markup %{{rgb:${inverted_color},rgb:${color}+b}  #${color}  }"
            }
        }}
    }
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

