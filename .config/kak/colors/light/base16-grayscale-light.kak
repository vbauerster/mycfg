## base16-kakoune (https://github.com/leira/base16-kakoune)
## by Leira Hua
## Grayscale Light scheme by Alexandre Gavioli (https:&#x2F;&#x2F;github.com&#x2F;Alexx2&#x2F;)

evaluate-commands %sh{

    base00='rgb:f7f7f7'
    base01='rgb:e3e3e3'
    base02='rgb:b9b9b9'
    base03='rgb:ababab'
    base04='rgb:525252'
    base05='rgb:464646'
    base06='rgb:252525'
    base07='rgb:101010'
    base08='rgb:7c7c7c'
    base09='rgb:999999'
    base0A='rgb:a0a0a0'
    base0B='rgb:8e8e8e'
    base0C='rgb:868686'
    base0D='rgb:686868'
    base0E='rgb:747474'
    base0F='rgb:5e5e5e'

    cat <<- EOF

        # For Code
        face global keyword   ${base0E}+b
        face global attribute ${base06}
        face global type      ${base0F}
        face global string    ${base0D}
        face global value     ${base0D}
        face global meta      ${base0C}
        face global builtin   ${base05}+b
        face global module    ${base0D}
        face global comment   ${base03}+i
        face global documentation comment
        face global function  ${base0E}
        face global operator  ${base0E}
        face global variable  ${base0E}

        # For markup
        face global title  ${base0D}+b
        face global header ${base0D}
        face global mono   ${base0B}
        face global block  ${base09}
        face global link   ${base0C}+u
        face global list   Default
        face global bullet +b
        face global bold   +b
        face global italic +i

         face global Default            ${base05},${base00}

         face global PrimarySelection   ${base05},${base01}
         face global PrimaryCursor      ${base00},${base05}
         face global PrimaryCursorEol   ${base00},${base07}+fg
         face global SecondarySelection ${base01},${base03}
         face global SecondaryCursor    ${base01},${base0E}
         face global SecondaryCursorEol ${base01},${base04}+fg

         # face global PrimarySelection   ${base00},${base04}
         # face global PrimaryCursor      ${base00},${base09}
         # face global PrimaryCursorEol   ${base00},${base09}+fg
         # face global SecondarySelection ${base0F},${base0A}
         # face global SecondaryCursor    ${base0A},${base0F}
         # face global SecondaryCursorEol ${base0A},${base0F}+fg

         face global MatchingChar       ${base07},${base01}
         face global Search             ${base00},${base0A}+i
         face global CurrentWord        ${base08},${base01}
         face global Whitespace         ${base01}+f
         face global WrapMarker         ${base05}+f
         face global BufferPadding      ${base03},${base00}
         face global LineNumbers        ${base02},${base00}
         face global LineNumberCursor   ${base04},${base00}
         face global LineNumbersWrapped ${base00},${base00}
         face global MenuForeground     ${base00},${base0D}
         face global MenuBackground     ${base01},${base0C}
         face global MenuInfo           ${base06}+i
         face global Information        ${base01},${base0D}
         face global Error              ${base00},${base08}
         face global StatusLine         ${base06},${base01}
         face global StatusLineMode     ${base01},${base06}
         face global StatusLineInfo     ${base08}
         face global StatusLineValue    ${base00}
         face global StatusCursor       ${base00},${base05}
         face global Prompt             ${base00},${base0D}

EOF
}
