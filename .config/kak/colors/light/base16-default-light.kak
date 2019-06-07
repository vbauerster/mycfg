## base16-kakoune (https://github.com/leira/base16-kakoune)
## by Leira Hua
## Default Light scheme by Chris Kempson (http:&#x2F;&#x2F;chriskempson.com)

evaluate-commands %sh{

    base00='rgb:f8f8f8'
    base01='rgb:e8e8e8'
    base02='rgb:d8d8d8'
    base03='rgb:b8b8b8'
    base04='rgb:585858'
    base05='rgb:383838'
    base06='rgb:282828'
    base07='rgb:181818'
    base08='rgb:ab4642'
    base09='rgb:dc9656'
    base0A='rgb:f7ca88'
    base0B='rgb:a1b56c'
    base0C='rgb:86c1b9'
    base0D='rgb:7cafc2'
    base0E='rgb:ba8baf'
    base0F='rgb:a16946'

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

         face global PrimarySelection   ${base00},${base0A}
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
         face global LineNumbersWrapped ${base02},${base00}+u
         face global MenuForeground     ${base00},${base0F}
         face global MenuBackground     ${base01},${base0C}
         face global MenuInfo           ${base02}
         face global Information        ${base01},${base0F}
         face global Error              ${base00},${base08}
         # face global StatusLine         ${base04},${base00}
         face global StatusLine         ${base05},${base01}
         # face global StatusLineMode     ${base0B}+b
         face global StatusLineMode     ${base00},${base0D}
         face global StatusLineInfo     ${base0F}
         face global StatusLineValue    ${base0C}
         face global StatusCursor       ${base00},${base05}
         face global Prompt             ${base00},${base0B}
    "
}
