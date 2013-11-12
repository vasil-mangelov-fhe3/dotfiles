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
    git_branch=`__git_ps1 "(%s)"`
    svn_url=`svn info | awk '/URL:/ {print $2}'`
    if [ -n "$git_branch" ] ; then
        git_promt git_branch
    fi
    if [ -n "$svn_url" ]; then
        svn_prompt
    fi
    export PS1="$_prompt$git_branch$svn_branch $path ";
}

git_promt () {
    git_branch=${1}
    if [ -n "$git_branch" ] ; then
        if [ -z "$_dumb_prompt" ]; then
            ## Assumes that untracked files are always listed after modified ones
            ## True for all git versions I could find
            git status --porcelain | perl -ne 'exit(1) if /^ /; exit(2) if /^[?]/'
            case "$?" in
                "0" )  git_branch=" $Green$git_branch$Color_Off"; path="$Yellow$PathShort$Color_Off$";; 
                "1" )  git_branch=" $Red$git_branch$Color_off"; path="$Yellow$PathShort$Color_Off$";; 
                "2" )  git_branch=" $Yellow$git_branch$Color_Off"; path="$Yellow$PathShort$Color_Off$";;
                "130" ) git_branch=" $White$git_branch$Color_Off"; path="$LightBlue$PathShort$Color_Off$"; _dumb_prompt=1 ;; 
            esac
        else
            branch=" $White$git_branch$Color_Off"; path="$LightBlue$PathShort$Color_Off$"
        fi
    fi
}

svn_prompt () {
    svn_status=`svn status`
    if [ -z "$svn_status" ] && [ "$?" == "0"]; then
        svn_branch=" $Green$(__svn_branch)$Color_Off"; path="$Yellow$PathShort$Color_Off$"
    elif [ ! -z "$svn_status" ] && [ "$?" == "0"]; then
        svn_branch=" $Yellow$(__svn_branch)$Color_off"; path="$Yellow$PathShort$Color_Off$"
    elif [ "$?" == "0"]; then
        svn_branch=" $Red$(__svn_branch)$Color_off"; path="$Yellow$PathShort$Color_Off$"
    fi
}

# Outputs the current trunk, branch, or tag
__svn_branch() {
    local url=
    if [[ -d .svn ]]; then
        url=`svn info | awk '/URL:/ {print $2}'`
        if [[ $url =~ trunk ]]; then
            echo trunk
        elif [[ $url =~ /branches/ ]]; then
            echo $url | sed -e 's#^.*/\(branches/.*\)/.*$#\1#'
        elif [[ $url =~ /tags/ ]]; then
            echo $url | sed -e 's#^.*/\(tags/.*\)/.*$#\1#'
        fi
    fi
}

# Outputs the current revision
__svn_rev() {
    local r=$(svn info | awk '/Revision:/ {print $2}')

    if [ ! -z $SVN_SHOWDIRTYSTATE ]; then
        local svnst flag
        svnst=$(svn status | grep '^\s*[?ACDMR?!]')
        [ -z "$svnst" ] && flag=*
        r=$r$flag
    fi
    echo $r
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
