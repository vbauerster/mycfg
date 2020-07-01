## base16-kakoune (https://github.com/leira/base16-kakoune)
## by Leira Hua
## Tomorrow scheme by Chris Kempson (http:&#x2F;&#x2F;chriskempson.com)

evaluate-commands %sh{

    base00='rgb:FDFDFD'
    base01='rgb:e0e0e0'
    base02='rgb:d6d6d6'
    base03='rgb:8e908c'
    base04='rgb:969896'
    base05='rgb:4d4d4c'
    base06='rgb:282a2e'
    base07='rgb:1d1f21'
    base08='rgb:c82829'
    base09='rgb:f5871f'
    base0A='rgb:eab700'
    base0B='rgb:718c00'
    base0C='rgb:3e999f'
    base0D='rgb:4271ae'
    base0E='rgb:8959a8'
    base0F='rgb:a3685a'

    white='rgb:FFFFFF'
    # matchb='rgb:EDF97D'
    # mytype='rgb:bf8b56'
    # menufg='rgb:f9f9f9'

    # High contrast alternative text
    vibrant_orange="rgb:EE7733"
    vibrant_blue="rgb:0077BB"
    vibrant_cyan="rgb:33BBEE"
    vibrant_magenta="rgb:EE3377"
    vibrant_red="rgb:CC3311"
    vibrant_teal="rgb:009988"
    vibrant_grey="rgb:BBBBBB"

    # Darker text with no red
    muted_rose="rgb:CC6677"
    muted_indigo="rgb:332288"
    muted_sand="rgb:DDCC77"
    muted_green="rgb:117733"
    muted_cyan="rgb:88CCEE"
    muted_wine="rgb:882255"
    muted_teal="rgb:44AA99"
    muted_olive="rgb:999933"
    muted_purple="rgb:AA4499"
    muted_pale_grey="rgb:DDDDDD"

    # Low contrast background colors
    light_blue="rgb:77AADD"
    light_orange="rgb:EE8866"
    light_yellow="rgb:EEDD88"
    light_pink="rgb:FFAABB"
    light_cyan="rgb:99DDFF"
    light_mint="rgb:44BB99"
    light_pear="rgb:BBCC33"
    light_olive="rgb:AAAA00"
    light_grey="rgb:DDDDDD"

    # Pale background colors, black foreground
    pale_blue="rgb:BBCCEE"
    pale_cyan="rgb:CCEEFF"
    pale_green="rgb:CCDDAA"
    pale_yellow="rgb:EEEEBB"
    pale_red="rgb:FFCCCC"
    pale_grey="rgb:DDDDDD"

    dark_grey="rgb:555555"

    cat <<- EOF

    # For Code
    face global keyword   ${base0E}+b
    face global attribute ${base08}
    face global type      ${base0F}
    face global string    ${base0B}
    face global value     ${base09}
    face global meta      ${base0C}
    face global builtin   ${base05}+b
    face global module    default
    face global comment   ${base03}+i
    face global documentation comment
    face global function  ${base0D}
    face global operator  default
    face global variable  default

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

    face global PrimarySelection   ${base06},${pale_cyan}
    face global PrimaryCursor      ${white},${vibrant_orange}
    face global PrimaryCursorEol   ${white},${vibrant_red}+fg
    face global SecondarySelection ${pale_cyan},${base04}
    face global SecondaryCursor    ${base00},${vibrant_cyan}
    face global SecondaryCursorEol ${base00},${vibrant_blue}+fg

    face global MatchingChar       ${base07},${base01}
    face global Search             ${base00},${base0A}+i
    face global CurrentWord        ${base08},${base01}
    face global Whitespace         ${base01}+f
    face global WrapMarker         ${base05}+f
    face global BufferPadding      ${base03},${base00}
    face global LineNumbers        ${base02},${base00}
    face global LineNumberCursor   ${base0A},${base00}
    face global LineNumbersWrapped ${base00},${base00}
    face global MenuForeground     ${base00},${base0F}
    face global MenuBackground     ${base01},${dark_grey}
    face global MenuInfo           ${pale_yellow}+i
    face global Information        ${base05},${pale_yellow}
    face global Error              ${white},${base08}
    face global StatusLine         ${base00},${base0C}
    face global StatusLineMode     ${base00},${base0B}
    face global StatusLineInfo     ${base01}
    face global StatusLineValue    ${base00}
    face global StatusCursor       ${base00},${base05}
    face global Prompt             ${base00},${base0D}

EOF
}
