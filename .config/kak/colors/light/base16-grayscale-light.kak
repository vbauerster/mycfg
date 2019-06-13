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

    echo "
         # face global identifier ${base08}
         # face global error $red

         face global value     ${base09}
         face global type      ${base0A}+b
         face global variable  ${base08}
         face global function  ${base0D}
         face global module    ${base0E}
         face global string    ${base0B}
         face global keyword   ${base0E}+b
         face global operator  ${base05}
         face global attribute ${base0F}
         face global comment   ${base03}+i
         face global meta      ${base0C}
         face global builtin   ${base05}+b

         face global title  ${base0D}+b
         face global header ${base0D}+b
         face global bold   ${base0A}+b
         face global italic ${base0E}
         face global mono   ${base0B}
         face global block  ${base0C}
         face global link   ${base09}
         face global bullet ${base08}
         face global list   ${base08}

         face global Default            ${base05},${base00}

         face global PrimarySelection   ${base00},${base0F}
         face global PrimaryCursor      ${base00},${base09}
         face global PrimaryCursorEol   ${base00},${base09}+fg
         face global SecondarySelection ${base0F},${base0A}
         face global SecondaryCursor    ${base0A},${base0F}
         face global SecondaryCursorEol ${base0A},${base0F}+fg
         face global MatchingChar       ${base05},${base01}+u
         # face global MatchingChar       ${base0A},${base0F}
         face global Search             ${base00},${base03}+i
         face global CurrentWord        ${base08},${base01}
         face global Whitespace         ${base01},${base00}+f
         face global BufferPadding      ${base03},${base00}
         face global LineNumbers        ${base02},${base00}
         face global LineNumberCursor   ${base00},${base02}
         face global LineNumbersWrapped ${base00},${base00}
         face global MenuForeground     ${base00},${base0F}
         face global MenuBackground     ${base01},${base0C}
         face global MenuInfo           ${base02}
         face global Information        ${base01},${base0F}
         face global Error              ${base00},${base08}
         # face global StatusLine         ${base04},${base00}
         face global StatusLine         ${base05},${base01}
         face global StatusLineMode     ${base00},${base0D}
         face global StatusLineInfo     ${base0F}
         face global StatusLineValue    ${base0C}
         face global StatusCursor       ${base00},${base05}
         face global Prompt             ${base00},${base0B}
    "
}
