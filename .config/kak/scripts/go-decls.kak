hook -once global WinSetOption filetype=(go) %{
    define-command go-decls %{
        require-module fzf
        go-decls-impl file
        define-command -override go-decls %{
            go-decls-impl file
        }
    }

    define-command go-decls-dir %{
        require-module fzf
        go-decls-impl dir
        define-command -override go-decls-dir %{
            go-decls-impl dir
        }
    }
}

define-command -hidden go-decls-impl -params 1 %{ evaluate-commands -no-hooks %sh{
    # output=$(mktemp ${TMPDIR:-/tmp}/kak-go-decls.XXXXXX)
    output="${TMPDIR:-/tmp}/kak-go-decls"

    if [ $1 = "dir" ]; then
        rel_dir=${kak_buffile%/*}
        scope="-dir .${rel_dir:${#PWD}}"
    else
        scope="-file $kak_bufname"
    fi

    motion -mode decls -include func,type $scope | jq -c '[.decls[]]' > $output

    filter='.[] | "\(.filename):\(.line):\(.col):\t\(.keyword) \(.ident)"'
    items_command="cat $output | jq -r '${filter}' | nl -b a -n ln"
    pcmd=$(printf 'n=$(echo {} | cut -f 1); cat %s | jq -r .[$(($n-1))].full | gofmt' "$output")
    preview="--preview '${pcmd}'"
    # echo "echo -debug items_command: $items_command"
    # echo "echo -debug preview: ${preview}"

    printf "%s\n" "fzf -kak-cmd %{fzf-sk-grep-handler} -items-cmd %{$items_command} -preview -preview-cmd %{$preview} -fzf-args %{--expect $kak_opt_fzf_window_map} -filter %{cut -f 2,3} -post-action %{buffer %opt{fzf_sk_first_file}}"
}}
