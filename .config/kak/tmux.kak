# tmux tricks
# define-command -override -docstring "rename tmux window to current buffer filename" \
# rename-tmux %{ nop %sh{ [ -n "$kak_client_env_TMUX" ] && tmux rename-window "kak: ${kak_bufname##*/}" } }

# hook -group tmux global FocusIn .* %{rename-tmux}
# hook -group tmux global WinDisplay .* %{rename-tmux}
# hook -group tmux global KakEnd .* %{ %sh{ [ -n "$TMUX" ] && tmux rename-window 'zsh' } }

# define-command -docstring "split tmux vertically" \
# vsplit -params .. -command-completion %{
#     tmux-terminal-horizontal kak -c %val{session} -e "%arg{@}"
# }

# define-command -docstring "split tmux horizontally" \
# split -params .. -command-completion %{
#     tmux-terminal-vertical kak -c %val{session} -e "%arg{@}"
# }

# define-command -docstring "create new tmux window" \
# tabnew -params .. -command-completion %{
#     tmux-terminal-window kak -c %val{session} -e "%arg{@}"
# }

# Layout
# ‾‾‾‾‾‾

declare-option -hidden str-list tmux_client_info

define-command -hidden tmux-visit-client %{
    evaluate-commands %sh{
        if [ -n "${kak_client_env_TMUX}" ] && [ -n "${kak_client_env_TMUX_PANE}" ]; then
            printf 'set-option -add global tmux_client_info %%{%s} %%{%s} %%{%s}\n' "${kak_client}" "${kak_client_env_TMUX}" "${kak_client_env_TMUX_PANE}"
        fi
    }
}

define-command -hidden tmux-collect-client-info %{
    set-option global tmux_client_info
    evaluate-commands %sh{
        for client in ${kak_client_list}; do
            printf 'evaluate-commands -client "%s" tmux-visit-client\n' "${client}"
        done
    }
}

define-command update-client-options %{
    tmux-collect-client-info
    evaluate-commands %sh{
        toolsclient=
        toolsclient_left=-1
        toolsclient_top=999999

        # Best client for tools client is upper-righthand corner
        eval set -- "${kak_opt_tmux_client_info}"
        while [ $# -gt 0 ]; do
            client="$1"; shift
            TMUX="$1"; shift
            TMUX_PANE="$1"; shift
            export TMUX TMUX_PANE

            pane_position=$(tmux display-message -t "${TMUX_PANE}" -p -F '#{pane_top}.#{pane_left}')
            pane_top="${pane_position%.*}"
            pane_left="${pane_position#*.}"

            accept=no
            if [ $pane_left -gt $toolsclient_left ]; then
                accept=yes
            elif [ $pane_left -eq $toolsclient_left ] && [ $pane_top -lt $toolsclient_top ]; then
                accept=yes
            fi

            if [ $accept = yes ]; then
                toolsclient=$client
                toolsclient_left=$pane_left
                toolsclient_top=$pane_top
            fi
        done

        jumpclient=
        jumpclient_left=-1
        jumpclient_top=999999

        # Best client for jumpclient is just to left of toolsclient
        eval set -- "${kak_opt_tmux_client_info}"
        while [ $# -gt 0 ]; do
            client="$1"; shift
            TMUX="$1"; shift
            TMUX_PANE="$1"; shift
            export TMUX TMUX_PANE

            pane_position=$(tmux display-message -t "${TMUX_PANE}" -p -F '#{pane_top}.#{pane_left}')
            pane_top="${pane_position%.*}"
            pane_left="${pane_position#*.}"

            accept=no
            if [ $pane_left -lt $toolsclient_left ] && [ $pane_left -gt $jumpclient_left ]; then
                accept=yes
            elif [ $pane_left -eq $jumpclient_left ] && [ $pane_top -lt $jumpclient_top ]; then
                accept=yes
            fi

            if [ $accept = yes ]; then
                jumpclient=$client
                jumpclient_left=$pane_left
                jumpclient_top=$pane_top
            fi
        done

        # REPL pane is in the lower, right-hand corner
        repl_pane=
        repl_pane_left=-1
        repl_pane_top=-1
        tmux list-panes -F '#{pane_top} #{pane_left} #{pane_id}' | {
            while read pane_top pane_left pane_id; do
                accept=no
                if [ $pane_left -gt $repl_pane_left ]; then
                    accept=yes
                elif [ $pane_left -eq $repl_pane_left ] && [ $pane_top -gt $repl_pane_top ]; then
                    accept=yes
                fi

                if [ $accept = yes ]; then
                    repl_pane="$pane_id"
                    repl_pane_left=$pane_left
                    repl_pane_top=$pane_top
                fi
            done
            if [ -n "$repl_pane" ]; then
                printf 'set-option global tmux_repl_id %%{%s}\n' "$repl_pane"
            fi
        }

        if [ -n "$toolsclient" ]; then
            printf 'set-option global toolsclient "%s"\n' "$toolsclient"
        fi
        if [ -n "$jumpclient" ]; then
            printf 'set-option global jumpclient "%s"\n' "$jumpclient"
        fi
    }
}

hook -group client-tracker global FocusIn .* update-client-options
hook -group client-tracker global WinCreate .* update-client-options
hook -group client-tracker global WinClose .* update-client-options
hook -group client-tracker global WinResize .* update-client-options

# tmux
# ‾‾‾‾

try %{ require-module tmux }
define-command -hidden -override -params 2.. tmux-terminal-impl %{
    evaluate-commands %sh{
        tmux=${kak_client_env_TMUX:-$TMUX}
        if [ -z "$tmux" ]; then
            echo "fail 'This command is only available in a tmux session'"
            exit
        fi
        tmux_args="$1"
        shift
        # ideally we should escape single ';' to stop tmux from interpreting it as a new command
        # but that's probably too rare to care
        keys=""
        while [ $# -gt 0 ]; do
            keys="$keys '$(printf %s "$1" |sed -e "s/\'/\'\\\'\'/g")'"
            shift
        done
        keys="$keys ; exit 0
"
        TMUX=$tmux tmux $tmux_args env TMPDIR="$TMPDIR" ${kak_client_env_SHELL:-/bin/sh} -l \; send-keys -l "$keys"
    }
}

