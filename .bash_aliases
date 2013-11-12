_update_prompt () {
    ## Save $? early, we'll need it later
    local exit="$?"  

    ## define some colors
    Color_Off="\[\033[0m\]"       # Text Reset

    Black="\[\033[00;30m\]"
    DarkGrey="\[\033[01;30m\]"
    Red="\[\033[00;31m\]"
    LightRed="\[\033[01;31m\]"
    Green="\[\033[00;32m\]"
    LightGreen="\[\033[01;32m\]"
    Brown="\[\033[00;33m\]"
    Yellow="\[\033[01;33m\]"
    Blue="\[\033[00;34m\]"
    LightBlue="\[\033[01;34m\]"
    Cyan="\[\033[00;36m\]"
    LightCyan="\[\033[01;36m\]"
    Purple="\[\033[00;35m\]"
    LightPurple="\[\033[01;35m\]"
    LightGrey="\[\033[00;37m\]"
    White="\[\033[01;37m\]"

    # Various variables you might want for your PS1 prompt instead
    Time12h="\T"
    Time24h="\t"
    Time12a="\@"
    PathShort="\w"
    PathFull="\W"
    NewLine="\n"
    Jobs="\j"
    sHostname=`hostname`
    path="$LightBlue$PathShort$Color_Off$"

    if [ "$UID" = "0" ]; then
        u="$Red\u$ColorOff";
    else
        u="$Green\u$ColorOff";
    fi

    ## Initial prompt
    _prompt="$LightGrey$Time24h$Color_Off $u@$Green$sHostname$Color_Off";

    ## Color git status if any
    branch=`__git_ps1 "(%s)"`
    if [ -n "$branch" ] ; then
        if [ -z "$_dumb_prompt" ]; then
            ## Assumes that untracked files are always listed after modified ones
            ## True for all git versions I could find
            git status --porcelain | perl -ne 'exit(1) if /^ /; exit(2) if /^[?]/'
            case "$?" in
                "0" )  branch=" $Green$branch$Color_Off"; path="$Yellow$PathShort$Color_Off$";; 
                "1" )  branch=" $Red$branch$Color_off"; path="$Yellow$PathShort$Color_Off$";; 
                "2" )  branch=" $Yellow$branch$Color_Off"; path="$Yellow$PathShort$Color_Off$";;
                "130" ) branch=" $White$branch$Color_Off"; path="$LightBlue$PathShort$Color_Off$"; _dumb_prompt=1 ;; 
            esac
        else
            branch=" $White$branch$Color_Off"; path="$LightBlue$PathShort$Color_Off$"
        fi
    fi

    export PS1="$_prompt$branch $path ";
}

dumb_prompt () {
    _dumb_prompt=1
}

smart_prompt () {
    unset _dumb_prompt
}

if [ -n "$PS1" ] ; then
    PROMPT_COMMAND='_update_prompt'
    export PROMPT_COMMAND
fi
