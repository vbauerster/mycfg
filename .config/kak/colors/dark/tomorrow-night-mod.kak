# gotham theme
# https://github.com/whatyouhide/gotham-contrib

evaluate-commands %sh{
    black="rgb:0c1014"
    gray="rgb:245361"
    white="rgb:d3ebe9"

    pink="rgb:888ca6"
    purple="rgb:4e5166"
    blue="rgb:195466"
    cyan="rgb:33859e"
    green="rgb:2aa889"
    yellow="rgb:edb443"
    orange="rgb:d26937"
    red="rgb:c23127"

    tn_foreground="rgb:c5c8c6"
    tn_background="rgb:272727"
    tn_selection="rgb:373b41"
    tn_window="rgb:383838"
    tn_text="rgb:D8D8D8"
    tn_text_light="rgb:4E4E4E"
    tn_line="rgb:282a2e"
    tn_comment="rgb:969896"
    tn_red="rgb:cc6666"
    tn_orange="rgb:d88860"
    tn_yellow="rgb:f0c674"
    tn_green="rgb:b5bd68"
    tn_green_dark="rgb:a1b56c"
    tn_blue="rgb:81a2be"
    tn_aqua="rgb:87afaf"
    tn_magenta="rgb:ab4642"
    tn_purple="rgb:b294bb"

    echo "
         face global value $tn_orange
         face global type $tn_yellow
         face global variable $tn_magenta
         face global function $tn_aqua
         face global module $tn_green
         face global string $tn_green_dark
         face global error $tn_red
         face global keyword $tn_purple
         face global operator $tn_orange
         face global attribute $tn_purple
         face global comment $tn_comment+i
         face global meta $tn_aqua
         face global builtin $tn_orange+b

         face global title $tn_blue
         face global header $tn_aqua
         face global bold $tn_yellow
         face global italic $tn_orange
         face global mono $tn_green_dark
         face global block $tn_orange
         face global link blue
         face global bullet $tn_red
         face global list $tn_red

         face global Default $tn_text,$tn_background

         # face global PrimarySelection default,$purple
         # face global PrimaryCursor $tn_background,$tn_text
         # face global PrimaryCursorEol $tn_background,$tn_text
         face global PrimarySelection $tn_background,$pink
         face global PrimaryCursor $tn_background,$tn_text
         face global PrimaryCursorEol $tn_background,$tn_text

         face global SecondarySelection $tn_background,$purple
         face global SecondaryCursor $tn_background,$pink
         face global SecondaryCursorEol $tn_background,$pink
         # face global SecondarySelection default,$purple
         # face global SecondaryCursor $tn_background,$pink
         # face global SecondaryCursorEol default,$pink

         face global MatchingChar default,$tn_selection+u
         face global Search default,$tn_selection+ib
         face global CurrentWord $white,$blue

         # listchars
         face global Whitespace $tn_text_light,$tn_background+f
         # ~ lines at EOB
         face global BufferPadding $tn_text_light,$tn_background

         face global LineNumbers $tn_text_light,$tn_line
         # must use -hl-cursor
         face global LineNumberCursor $tn_comment,$tn_selection
         face global LineNumbersWrapped $tn_text_light,$tn_line+u

         # when item focused in menu
         face global MenuForeground $tn_background,$tn_purple+b
         # default bottom menu and autocomplete
         face global MenuBackground $tn_comment,$purple
         # complement in autocomplete like path
         face global MenuInfo $tn_comment,$purple
         # clippy
         # face global Information $tn_comment,$tn_window
         face global Information $tn_aqua,$tn_window
         face global Error $tn_text,$tn_magenta

         # all status line: what we type, but also client@[session]
         face global StatusLine $tn_foreground,$tn_background
         # insert mode, prompt mode
         face global StatusLineMode $tn_background,$tn_comment
         # message like '1 sel'
         # face global StatusLineInfo $tn_aqua,$tn_window
         face global StatusLineInfo $tn_comment,$tn_background
         # count
         face global StatusLineValue $tn_green_dark,$tn_background
         face global StatusCursor $tn_background,$tn_purple
         # like the word 'select:' when pressing 's'
         face global Prompt $tn_purple,$tn_background+i
    "
}
