## base16-kakoune (https://github.com/leira/base16-kakoune)
## by Leira Hua
## Google Light scheme by Seth Wright (http:&#x2F;&#x2F;sethawright.com)

evaluate-commands %sh{

    base00='rgb:ffffff'
    base01='rgb:e0e0e0'
    base02='rgb:c5c8c6'
    base03='rgb:b4b7b4'
    base04='rgb:969896'
    base05='rgb:373b41'
    base06='rgb:282a2e'
    base07='rgb:1d1f21'
    base08='rgb:CC342B'
    base09='rgb:F96A38'
    base0A='rgb:FBA922'
    base0B='rgb:198844'
    base0C='rgb:3971ED'
    base0D='rgb:3971ED'
    base0E='rgb:A36AC7'
    base0F='rgb:3971ED'

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
         face global attribute ${base0C}
         face global comment   ${base03}+i
         face global meta      ${base0D}
         face global builtin   ${base0D}+b

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
         face global PrimaryCursorEol   ${base00},${base09}
         face global SecondarySelection ${base0F},${base0A}
         face global SecondaryCursor    ${base0A},${base0F}
         face global SecondaryCursorEol ${base0A},${base0F}
         face global MatchingChar       ${base05},${base01}+b
         # face global MatchingChar       ${base0A},${base0F}
         face global Search             ${base00},${base03}+i
         face global CurrentWord        ${base08},${base01}
         face global Whitespace         ${base01},${base00}+f
         face global BufferPadding      ${base03},${base00}
         face global LineNumbers        ${base02},${base00}
         face global LineNumberCursor   ${base0A},${base00}
         face global LineNumbersWrapped ${base02},${base00}+u
         face global MenuForeground     ${base00},${base0F}
         face global MenuBackground     ${base01},${base0C}
         face global MenuInfo           ${base02}
         face global Information        ${base01},${base0F}
         face global Error              ${base00},${base08}
         # face global StatusLine         ${base04},${base00}
         face global StatusLine         ${base05},${base01}
         face global StatusLineMode     ${base0B}+b
         face global StatusLineInfo     ${base0F}
         face global StatusLineValue    ${base0C}
         face global StatusCursor       ${base00},${base05}
         face global Prompt             ${base00},${base0B}
    "
}
