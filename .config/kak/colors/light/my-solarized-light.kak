# Solarized Light

evaluate-commands %sh{
    gr_base00='rgb:f7f7f7'
    gr_base01='rgb:e3e3e3'
    gr_base02='rgb:b9b9b9'
    gr_base03='rgb:ababab'
    gr_base04='rgb:525252'
    gr_base05='rgb:464646'
    gr_base06='rgb:252525'
    gr_base07='rgb:101010'
    gr_base08='rgb:7c7c7c'
    gr_base09='rgb:999999'
    gr_base0A='rgb:a0a0a0'
    gr_base0B='rgb:8e8e8e'
    gr_base0C='rgb:868686'
    gr_base0D='rgb:686868'
    gr_base0E='rgb:747474'
    gr_base0F='rgb:5e5e5e'

    base03='rgb:002b36'
    base02='rgb:073642'
    base01='rgb:586e75'
    base00='rgb:657b83'
    base0='rgb:839496'
    base1='rgb:93a1a1'
    base2='rgb:eee8d5'
    base3='rgb:fdf6e3'
    yellow='rgb:b58900'
    orange='rgb:cb4b16'
    red='rgb:dc322f'
    magenta='rgb:d33682'
    violet='rgb:6c71c4'
    blue='rgb:268bd2'
    cyan='rgb:2aa198'
    green='rgb:859900'

    echo "
        # code
        face global value              ${cyan}
        face global type               ${red}
        face global variable           ${blue}
        face global module             ${cyan}
        face global function           ${blue}
        face global string             ${cyan}
        face global keyword            ${green}
        face global operator           ${yellow}
        face global attribute          ${violet}
        face global comment            ${base1}
        face global meta               ${orange}
        face global builtin            default+b

        # markup
        face global title              ${blue}+b
        face global header             ${blue}
        face global bold               ${base01}+b
        face global italic             ${base01}+i
        face global mono               ${base1}
        face global block              ${cyan}
        face global link               ${base01}
        face global bullet             ${yellow}
        face global list               ${green}

        # builtin
        face global Default            ${base00},${base3}

         face global PrimarySelection   ${gr_base00},${gr_base0F}
         face global PrimaryCursor      ${gr_base00},${gr_base09}
         face global PrimaryCursorEol   ${gr_base00},${gr_base09}+fg
         face global SecondarySelection ${gr_base0F},${gr_base0A}
         face global SecondaryCursor    ${gr_base0A},${gr_base0F}
         face global SecondaryCursorEol ${gr_base0A},${gr_base0F}+fg

        face global LineNumbers        ${base1},${base2}
        face global LineNumberCursor   ${base01},${base2}
        face global LineNumbersWrapped ${base2},${base2}
        face global MenuForeground     ${base3},${yellow}
        face global MenuBackground     ${base01},${base2}
        face global MenuInfo           ${base1}
        face global Information        ${base2},${base1}
        face global Error              ${red},default+b
        face global StatusLine         ${base01},${base2}+b
        face global StatusLineMode     ${orange}
        face global StatusLineInfo     ${cyan}
        face global StatusLineValue    ${green}
        face global StatusCursor       ${base0},${base03}
        face global Prompt             ${yellow}+b
        face global MatchingChar       ${red},${base2}+b
        face global BufferPadding      ${base1},${base3}
        face global Whitespace         ${base1}+f
    "
}
