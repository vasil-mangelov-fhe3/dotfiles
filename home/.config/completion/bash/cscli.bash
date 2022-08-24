# bash completion for cscli                                -*- shell-script -*-

__cscli_debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE:-} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__cscli_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

__cscli_index_of_word()
{
    local w word=$1
    shift
    index=0
    for w in "$@"; do
        [[ $w = "$word" ]] && return
        index=$((index+1))
    done
    index=-1
}

__cscli_contains_word()
{
    local w word=$1; shift
    for w in "$@"; do
        [[ $w = "$word" ]] && return
    done
    return 1
}

__cscli_handle_go_custom_completion()
{
    __cscli_debug "${FUNCNAME[0]}: cur is ${cur}, words[*] is ${words[*]}, #words[@] is ${#words[@]}"

    local shellCompDirectiveError=1
    local shellCompDirectiveNoSpace=2
    local shellCompDirectiveNoFileComp=4
    local shellCompDirectiveFilterFileExt=8
    local shellCompDirectiveFilterDirs=16

    local out requestComp lastParam lastChar comp directive args

    # Prepare the command to request completions for the program.
    # Calling ${words[0]} instead of directly cscli allows to handle aliases
    args=("${words[@]:1}")
    requestComp="${words[0]} __completeNoDesc ${args[*]}"

    lastParam=${words[$((${#words[@]}-1))]}
    lastChar=${lastParam:$((${#lastParam}-1)):1}
    __cscli_debug "${FUNCNAME[0]}: lastParam ${lastParam}, lastChar ${lastChar}"

    if [ -z "${cur}" ] && [ "${lastChar}" != "=" ]; then
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go method.
        __cscli_debug "${FUNCNAME[0]}: Adding extra empty parameter"
        requestComp="${requestComp} \"\""
    fi

    __cscli_debug "${FUNCNAME[0]}: calling ${requestComp}"
    # Use eval to handle any environment variables and such
    out=$(eval "${requestComp}" 2>/dev/null)

    # Extract the directive integer at the very end of the output following a colon (:)
    directive=${out##*:}
    # Remove the directive
    out=${out%:*}
    if [ "${directive}" = "${out}" ]; then
        # There is not directive specified
        directive=0
    fi
    __cscli_debug "${FUNCNAME[0]}: the completion directive is: ${directive}"
    __cscli_debug "${FUNCNAME[0]}: the completions are: ${out[*]}"

    if [ $((directive & shellCompDirectiveError)) -ne 0 ]; then
        # Error code.  No completion.
        __cscli_debug "${FUNCNAME[0]}: received error from custom completion go code"
        return
    else
        if [ $((directive & shellCompDirectiveNoSpace)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __cscli_debug "${FUNCNAME[0]}: activating no space"
                compopt -o nospace
            fi
        fi
        if [ $((directive & shellCompDirectiveNoFileComp)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __cscli_debug "${FUNCNAME[0]}: activating no file completion"
                compopt +o default
            fi
        fi
    fi

    if [ $((directive & shellCompDirectiveFilterFileExt)) -ne 0 ]; then
        # File extension filtering
        local fullFilter filter filteringCmd
        # Do not use quotes around the $out variable or else newline
        # characters will be kept.
        for filter in ${out[*]}; do
            fullFilter+="$filter|"
        done

        filteringCmd="_filedir $fullFilter"
        __cscli_debug "File filtering command: $filteringCmd"
        $filteringCmd
    elif [ $((directive & shellCompDirectiveFilterDirs)) -ne 0 ]; then
        # File completion for directories only
        local subdir
        # Use printf to strip any trailing newline
        subdir=$(printf "%s" "${out[0]}")
        if [ -n "$subdir" ]; then
            __cscli_debug "Listing directories in $subdir"
            __cscli_handle_subdirs_in_dir_flag "$subdir"
        else
            __cscli_debug "Listing directories in ."
            _filedir -d
        fi
    else
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${out[*]}" -- "$cur")
    fi
}

__cscli_handle_reply()
{
    __cscli_debug "${FUNCNAME[0]}"
    local comp
    case $cur in
        -*)
            if [[ $(type -t compopt) = "builtin" ]]; then
                compopt -o nospace
            fi
            local allflags
            if [ ${#must_have_one_flag[@]} -ne 0 ]; then
                allflags=("${must_have_one_flag[@]}")
            else
                allflags=("${flags[*]} ${two_word_flags[*]}")
            fi
            while IFS='' read -r comp; do
                COMPREPLY+=("$comp")
            done < <(compgen -W "${allflags[*]}" -- "$cur")
            if [[ $(type -t compopt) = "builtin" ]]; then
                [[ "${COMPREPLY[0]}" == *= ]] || compopt +o nospace
            fi

            # complete after --flag=abc
            if [[ $cur == *=* ]]; then
                if [[ $(type -t compopt) = "builtin" ]]; then
                    compopt +o nospace
                fi

                local index flag
                flag="${cur%=*}"
                __cscli_index_of_word "${flag}" "${flags_with_completion[@]}"
                COMPREPLY=()
                if [[ ${index} -ge 0 ]]; then
                    PREFIX=""
                    cur="${cur#*=}"
                    ${flags_completion[${index}]}
                    if [ -n "${ZSH_VERSION:-}" ]; then
                        # zsh completion needs --flag= prefix
                        eval "COMPREPLY=( \"\${COMPREPLY[@]/#/${flag}=}\" )"
                    fi
                fi
            fi

            if [[ -z "${flag_parsing_disabled}" ]]; then
                # If flag parsing is enabled, we have completed the flags and can return.
                # If flag parsing is disabled, we may not know all (or any) of the flags, so we fallthrough
                # to possibly call handle_go_custom_completion.
                return 0;
            fi
            ;;
    esac

    # check if we are handling a flag with special work handling
    local index
    __cscli_index_of_word "${prev}" "${flags_with_completion[@]}"
    if [[ ${index} -ge 0 ]]; then
        ${flags_completion[${index}]}
        return
    fi

    # we are parsing a flag and don't have a special handler, no completion
    if [[ ${cur} != "${words[cword]}" ]]; then
        return
    fi

    local completions
    completions=("${commands[@]}")
    if [[ ${#must_have_one_noun[@]} -ne 0 ]]; then
        completions+=("${must_have_one_noun[@]}")
    elif [[ -n "${has_completion_function}" ]]; then
        # if a go completion function is provided, defer to that function
        __cscli_handle_go_custom_completion
    fi
    if [[ ${#must_have_one_flag[@]} -ne 0 ]]; then
        completions+=("${must_have_one_flag[@]}")
    fi
    while IFS='' read -r comp; do
        COMPREPLY+=("$comp")
    done < <(compgen -W "${completions[*]}" -- "$cur")

    if [[ ${#COMPREPLY[@]} -eq 0 && ${#noun_aliases[@]} -gt 0 && ${#must_have_one_noun[@]} -ne 0 ]]; then
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${noun_aliases[*]}" -- "$cur")
    fi

    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
        if declare -F __cscli_custom_func >/dev/null; then
            # try command name qualified custom func
            __cscli_custom_func
        else
            # otherwise fall back to unqualified for compatibility
            declare -F __custom_func >/dev/null && __custom_func
        fi
    fi

    # available in bash-completion >= 2, not always present on macOS
    if declare -F __ltrim_colon_completions >/dev/null; then
        __ltrim_colon_completions "$cur"
    fi

    # If there is only 1 completion and it is a flag with an = it will be completed
    # but we don't want a space after the =
    if [[ "${#COMPREPLY[@]}" -eq "1" ]] && [[ $(type -t compopt) = "builtin" ]] && [[ "${COMPREPLY[0]}" == --*= ]]; then
       compopt -o nospace
    fi
}

# The arguments should be in the form "ext1|ext2|extn"
__cscli_handle_filename_extension_flag()
{
    local ext="$1"
    _filedir "@(${ext})"
}

__cscli_handle_subdirs_in_dir_flag()
{
    local dir="$1"
    pushd "${dir}" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1 || return
}

__cscli_handle_flag()
{
    __cscli_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    # if a command required a flag, and we found it, unset must_have_one_flag()
    local flagname=${words[c]}
    local flagvalue=""
    # if the word contained an =
    if [[ ${words[c]} == *"="* ]]; then
        flagvalue=${flagname#*=} # take in as flagvalue after the =
        flagname=${flagname%=*} # strip everything after the =
        flagname="${flagname}=" # but put the = back
    fi
    __cscli_debug "${FUNCNAME[0]}: looking for ${flagname}"
    if __cscli_contains_word "${flagname}" "${must_have_one_flag[@]}"; then
        must_have_one_flag=()
    fi

    # if you set a flag which only applies to this command, don't show subcommands
    if __cscli_contains_word "${flagname}" "${local_nonpersistent_flags[@]}"; then
      commands=()
    fi

    # keep flag value with flagname as flaghash
    # flaghash variable is an associative array which is only supported in bash > 3.
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        if [ -n "${flagvalue}" ] ; then
            flaghash[${flagname}]=${flagvalue}
        elif [ -n "${words[ $((c+1)) ]}" ] ; then
            flaghash[${flagname}]=${words[ $((c+1)) ]}
        else
            flaghash[${flagname}]="true" # pad "true" for bool flag
        fi
    fi

    # skip the argument to a two word flag
    if [[ ${words[c]} != *"="* ]] && __cscli_contains_word "${words[c]}" "${two_word_flags[@]}"; then
        __cscli_debug "${FUNCNAME[0]}: found a flag ${words[c]}, skip the next argument"
        c=$((c+1))
        # if we are looking for a flags value, don't show commands
        if [[ $c -eq $cword ]]; then
            commands=()
        fi
    fi

    c=$((c+1))

}

__cscli_handle_noun()
{
    __cscli_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    if __cscli_contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
        must_have_one_noun=()
    elif __cscli_contains_word "${words[c]}" "${noun_aliases[@]}"; then
        must_have_one_noun=()
    fi

    nouns+=("${words[c]}")
    c=$((c+1))
}

__cscli_handle_command()
{
    __cscli_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    local next_command
    if [[ -n ${last_command} ]]; then
        next_command="_${last_command}_${words[c]//:/__}"
    else
        if [[ $c -eq 0 ]]; then
            next_command="_cscli_root_command"
        else
            next_command="_${words[c]//:/__}"
        fi
    fi
    c=$((c+1))
    __cscli_debug "${FUNCNAME[0]}: looking for ${next_command}"
    declare -F "$next_command" >/dev/null && $next_command
}

__cscli_handle_word()
{
    if [[ $c -ge $cword ]]; then
        __cscli_handle_reply
        return
    fi
    __cscli_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    if [[ "${words[c]}" == -* ]]; then
        __cscli_handle_flag
    elif __cscli_contains_word "${words[c]}" "${commands[@]}"; then
        __cscli_handle_command
    elif [[ $c -eq 0 ]]; then
        __cscli_handle_command
    elif __cscli_contains_word "${words[c]}" "${command_aliases[@]}"; then
        # aliashash variable is an associative array which is only supported in bash > 3.
        if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
            words[c]=${aliashash[${words[c]}]}
            __cscli_handle_command
        else
            __cscli_handle_noun
        fi
    else
        __cscli_handle_noun
    fi
    __cscli_handle_word
}

_cscli_alerts_delete()
{
    last_command="cscli_alerts_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--scope=")
    two_word_flags+=("--scope")
    local_nonpersistent_flags+=("--scope")
    local_nonpersistent_flags+=("--scope=")
    flags+=("--value=")
    two_word_flags+=("--value")
    two_word_flags+=("-v")
    local_nonpersistent_flags+=("--value")
    local_nonpersistent_flags+=("--value=")
    local_nonpersistent_flags+=("-v")
    flags+=("--scenario=")
    two_word_flags+=("--scenario")
    two_word_flags+=("-s")
    local_nonpersistent_flags+=("--scenario")
    local_nonpersistent_flags+=("--scenario=")
    local_nonpersistent_flags+=("-s")
    flags+=("--ip=")
    two_word_flags+=("--ip")
    two_word_flags+=("-i")
    local_nonpersistent_flags+=("--ip")
    local_nonpersistent_flags+=("--ip=")
    local_nonpersistent_flags+=("-i")
    flags+=("--range=")
    two_word_flags+=("--range")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--range")
    local_nonpersistent_flags+=("--range=")
    local_nonpersistent_flags+=("-r")
    flags+=("--all")
    flags+=("-a")
    local_nonpersistent_flags+=("--all")
    local_nonpersistent_flags+=("-a")
    flags+=("--contained")
    local_nonpersistent_flags+=("--contained")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_alerts_flush()
{
    last_command="cscli_alerts_flush"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--max-items=")
    two_word_flags+=("--max-items")
    local_nonpersistent_flags+=("--max-items")
    local_nonpersistent_flags+=("--max-items=")
    flags+=("--max-age=")
    two_word_flags+=("--max-age")
    local_nonpersistent_flags+=("--max-age")
    local_nonpersistent_flags+=("--max-age=")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_alerts_inspect()
{
    last_command="cscli_alerts_inspect"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--details")
    flags+=("-d")
    local_nonpersistent_flags+=("--details")
    local_nonpersistent_flags+=("-d")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_alerts_list()
{
    last_command="cscli_alerts_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--until=")
    two_word_flags+=("--until")
    local_nonpersistent_flags+=("--until")
    local_nonpersistent_flags+=("--until=")
    flags+=("--since=")
    two_word_flags+=("--since")
    local_nonpersistent_flags+=("--since")
    local_nonpersistent_flags+=("--since=")
    flags+=("--ip=")
    two_word_flags+=("--ip")
    two_word_flags+=("-i")
    local_nonpersistent_flags+=("--ip")
    local_nonpersistent_flags+=("--ip=")
    local_nonpersistent_flags+=("-i")
    flags+=("--scenario=")
    two_word_flags+=("--scenario")
    two_word_flags+=("-s")
    local_nonpersistent_flags+=("--scenario")
    local_nonpersistent_flags+=("--scenario=")
    local_nonpersistent_flags+=("-s")
    flags+=("--range=")
    two_word_flags+=("--range")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--range")
    local_nonpersistent_flags+=("--range=")
    local_nonpersistent_flags+=("-r")
    flags+=("--type=")
    two_word_flags+=("--type")
    local_nonpersistent_flags+=("--type")
    local_nonpersistent_flags+=("--type=")
    flags+=("--scope=")
    two_word_flags+=("--scope")
    local_nonpersistent_flags+=("--scope")
    local_nonpersistent_flags+=("--scope=")
    flags+=("--value=")
    two_word_flags+=("--value")
    two_word_flags+=("-v")
    local_nonpersistent_flags+=("--value")
    local_nonpersistent_flags+=("--value=")
    local_nonpersistent_flags+=("-v")
    flags+=("--contained")
    local_nonpersistent_flags+=("--contained")
    flags+=("--machine")
    flags+=("-m")
    local_nonpersistent_flags+=("--machine")
    local_nonpersistent_flags+=("-m")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--limit")
    local_nonpersistent_flags+=("--limit=")
    local_nonpersistent_flags+=("-l")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_alerts()
{
    last_command="cscli_alerts"

    command_aliases=()

    commands=()
    commands+=("delete")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("remove")
        aliashash["remove"]="delete"
    fi
    commands+=("flush")
    commands+=("inspect")
    commands+=("list")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_bouncers_add()
{
    last_command="cscli_bouncers_add"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--key=")
    two_word_flags+=("--key")
    two_word_flags+=("-k")
    local_nonpersistent_flags+=("--key")
    local_nonpersistent_flags+=("--key=")
    local_nonpersistent_flags+=("-k")
    flags+=("--length=")
    two_word_flags+=("--length")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--length")
    local_nonpersistent_flags+=("--length=")
    local_nonpersistent_flags+=("-l")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_bouncers_delete()
{
    last_command="cscli_bouncers_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_bouncers_list()
{
    last_command="cscli_bouncers_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_bouncers()
{
    last_command="cscli_bouncers"

    command_aliases=()

    commands=()
    commands+=("add")
    commands+=("delete")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("remove")
        aliashash["remove"]="delete"
    fi
    commands+=("list")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_capi_register()
{
    last_command="cscli_capi_register"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--file=")
    two_word_flags+=("--file")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--file")
    local_nonpersistent_flags+=("--file=")
    local_nonpersistent_flags+=("-f")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_capi_status()
{
    last_command="cscli_capi_status"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_capi()
{
    last_command="cscli_capi"

    command_aliases=()

    commands=()
    commands+=("register")
    commands+=("status")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_collections_inspect()
{
    last_command="cscli_collections_inspect"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--url=")
    two_word_flags+=("--url")
    two_word_flags+=("-u")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_cscli_collections_install()
{
    last_command="cscli_collections_install"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--download-only")
    flags+=("-d")
    flags+=("--force")
    flags+=("--ignore")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_cscli_collections_list()
{
    last_command="cscli_collections_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_collections_remove()
{
    last_command="cscli_collections_remove"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("--force")
    flags+=("--purge")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_cscli_collections_upgrade()
{
    last_command="cscli_collections_upgrade"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    flags+=("--force")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_cscli_collections()
{
    last_command="cscli_collections"

    command_aliases=()

    commands=()
    commands+=("inspect")
    commands+=("install")
    commands+=("list")
    commands+=("remove")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("delete")
        aliashash["delete"]="remove"
    fi
    commands+=("upgrade")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_completion()
{
    last_command="cscli_completion"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    local_nonpersistent_flags+=("-h")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    must_have_one_noun+=("bash")
    must_have_one_noun+=("fish")
    must_have_one_noun+=("powershell")
    must_have_one_noun+=("zsh")
    noun_aliases=()
}

_cscli_config_backup()
{
    last_command="cscli_config_backup"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_config_restore()
{
    last_command="cscli_config_restore"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--old-backup")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_config_show()
{
    last_command="cscli_config_show"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--key=")
    two_word_flags+=("--key")
    local_nonpersistent_flags+=("--key")
    local_nonpersistent_flags+=("--key=")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_config()
{
    last_command="cscli_config"

    command_aliases=()

    commands=()
    commands+=("backup")
    commands+=("restore")
    commands+=("show")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_console_disable()
{
    last_command="cscli_console_disable"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    local_nonpersistent_flags+=("--all")
    local_nonpersistent_flags+=("-a")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    must_have_one_noun+=("custom")
    must_have_one_noun+=("manual")
    must_have_one_noun+=("tainted")
    noun_aliases=()
}

_cscli_console_enable()
{
    last_command="cscli_console_enable"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    local_nonpersistent_flags+=("--all")
    local_nonpersistent_flags+=("-a")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    must_have_one_noun+=("custom")
    must_have_one_noun+=("manual")
    must_have_one_noun+=("tainted")
    noun_aliases=()
}

_cscli_console_enroll()
{
    last_command="cscli_console_enroll"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    local_nonpersistent_flags+=("-n")
    flags+=("--overwrite")
    local_nonpersistent_flags+=("--overwrite")
    flags+=("--tags=")
    two_word_flags+=("--tags")
    two_word_flags+=("-t")
    local_nonpersistent_flags+=("--tags")
    local_nonpersistent_flags+=("--tags=")
    local_nonpersistent_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_console_status()
{
    last_command="cscli_console_status"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_console()
{
    last_command="cscli_console"

    command_aliases=()

    commands=()
    commands+=("disable")
    commands+=("enable")
    commands+=("enroll")
    commands+=("status")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_dashboard_remove()
{
    last_command="cscli_dashboard_remove"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    local_nonpersistent_flags+=("-f")
    flags+=("--yes")
    flags+=("-y")
    local_nonpersistent_flags+=("--yes")
    local_nonpersistent_flags+=("-y")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_dashboard_setup()
{
    last_command="cscli_dashboard_setup"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--dir=")
    two_word_flags+=("--dir")
    two_word_flags+=("-d")
    local_nonpersistent_flags+=("--dir")
    local_nonpersistent_flags+=("--dir=")
    local_nonpersistent_flags+=("-d")
    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    local_nonpersistent_flags+=("-f")
    flags+=("--listen=")
    two_word_flags+=("--listen")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--listen")
    local_nonpersistent_flags+=("--listen=")
    local_nonpersistent_flags+=("-l")
    flags+=("--password=")
    two_word_flags+=("--password")
    local_nonpersistent_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    flags+=("--port=")
    two_word_flags+=("--port")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--port")
    local_nonpersistent_flags+=("--port=")
    local_nonpersistent_flags+=("-p")
    flags+=("--yes")
    flags+=("-y")
    local_nonpersistent_flags+=("--yes")
    local_nonpersistent_flags+=("-y")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_dashboard_show-password()
{
    last_command="cscli_dashboard_show-password"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_dashboard_start()
{
    last_command="cscli_dashboard_start"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_dashboard_stop()
{
    last_command="cscli_dashboard_stop"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_dashboard()
{
    last_command="cscli_dashboard"

    command_aliases=()

    commands=()
    commands+=("remove")
    commands+=("setup")
    commands+=("show-password")
    commands+=("start")
    commands+=("stop")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_decisions_add()
{
    last_command="cscli_decisions_add"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ip=")
    two_word_flags+=("--ip")
    two_word_flags+=("-i")
    local_nonpersistent_flags+=("--ip")
    local_nonpersistent_flags+=("--ip=")
    local_nonpersistent_flags+=("-i")
    flags+=("--range=")
    two_word_flags+=("--range")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--range")
    local_nonpersistent_flags+=("--range=")
    local_nonpersistent_flags+=("-r")
    flags+=("--duration=")
    two_word_flags+=("--duration")
    two_word_flags+=("-d")
    local_nonpersistent_flags+=("--duration")
    local_nonpersistent_flags+=("--duration=")
    local_nonpersistent_flags+=("-d")
    flags+=("--value=")
    two_word_flags+=("--value")
    two_word_flags+=("-v")
    local_nonpersistent_flags+=("--value")
    local_nonpersistent_flags+=("--value=")
    local_nonpersistent_flags+=("-v")
    flags+=("--scope=")
    two_word_flags+=("--scope")
    local_nonpersistent_flags+=("--scope")
    local_nonpersistent_flags+=("--scope=")
    flags+=("--reason=")
    two_word_flags+=("--reason")
    two_word_flags+=("-R")
    local_nonpersistent_flags+=("--reason")
    local_nonpersistent_flags+=("--reason=")
    local_nonpersistent_flags+=("-R")
    flags+=("--type=")
    two_word_flags+=("--type")
    two_word_flags+=("-t")
    local_nonpersistent_flags+=("--type")
    local_nonpersistent_flags+=("--type=")
    local_nonpersistent_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_decisions_delete()
{
    last_command="cscli_decisions_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ip=")
    two_word_flags+=("--ip")
    two_word_flags+=("-i")
    local_nonpersistent_flags+=("--ip")
    local_nonpersistent_flags+=("--ip=")
    local_nonpersistent_flags+=("-i")
    flags+=("--range=")
    two_word_flags+=("--range")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--range")
    local_nonpersistent_flags+=("--range=")
    local_nonpersistent_flags+=("-r")
    flags+=("--id=")
    two_word_flags+=("--id")
    local_nonpersistent_flags+=("--id")
    local_nonpersistent_flags+=("--id=")
    flags+=("--type=")
    two_word_flags+=("--type")
    two_word_flags+=("-t")
    local_nonpersistent_flags+=("--type")
    local_nonpersistent_flags+=("--type=")
    local_nonpersistent_flags+=("-t")
    flags+=("--value=")
    two_word_flags+=("--value")
    two_word_flags+=("-v")
    local_nonpersistent_flags+=("--value")
    local_nonpersistent_flags+=("--value=")
    local_nonpersistent_flags+=("-v")
    flags+=("--all")
    local_nonpersistent_flags+=("--all")
    flags+=("--contained")
    local_nonpersistent_flags+=("--contained")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_decisions_import()
{
    last_command="cscli_decisions_import"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--input=")
    two_word_flags+=("--input")
    two_word_flags+=("-i")
    local_nonpersistent_flags+=("--input")
    local_nonpersistent_flags+=("--input=")
    local_nonpersistent_flags+=("-i")
    flags+=("--duration=")
    two_word_flags+=("--duration")
    two_word_flags+=("-d")
    local_nonpersistent_flags+=("--duration")
    local_nonpersistent_flags+=("--duration=")
    local_nonpersistent_flags+=("-d")
    flags+=("--scope=")
    two_word_flags+=("--scope")
    local_nonpersistent_flags+=("--scope")
    local_nonpersistent_flags+=("--scope=")
    flags+=("--reason=")
    two_word_flags+=("--reason")
    two_word_flags+=("-R")
    local_nonpersistent_flags+=("--reason")
    local_nonpersistent_flags+=("--reason=")
    local_nonpersistent_flags+=("-R")
    flags+=("--type=")
    two_word_flags+=("--type")
    two_word_flags+=("-t")
    local_nonpersistent_flags+=("--type")
    local_nonpersistent_flags+=("--type=")
    local_nonpersistent_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_decisions_list()
{
    last_command="cscli_decisions_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    local_nonpersistent_flags+=("--all")
    local_nonpersistent_flags+=("-a")
    flags+=("--since=")
    two_word_flags+=("--since")
    local_nonpersistent_flags+=("--since")
    local_nonpersistent_flags+=("--since=")
    flags+=("--until=")
    two_word_flags+=("--until")
    local_nonpersistent_flags+=("--until")
    local_nonpersistent_flags+=("--until=")
    flags+=("--type=")
    two_word_flags+=("--type")
    two_word_flags+=("-t")
    local_nonpersistent_flags+=("--type")
    local_nonpersistent_flags+=("--type=")
    local_nonpersistent_flags+=("-t")
    flags+=("--scope=")
    two_word_flags+=("--scope")
    local_nonpersistent_flags+=("--scope")
    local_nonpersistent_flags+=("--scope=")
    flags+=("--origin=")
    two_word_flags+=("--origin")
    local_nonpersistent_flags+=("--origin")
    local_nonpersistent_flags+=("--origin=")
    flags+=("--value=")
    two_word_flags+=("--value")
    two_word_flags+=("-v")
    local_nonpersistent_flags+=("--value")
    local_nonpersistent_flags+=("--value=")
    local_nonpersistent_flags+=("-v")
    flags+=("--scenario=")
    two_word_flags+=("--scenario")
    two_word_flags+=("-s")
    local_nonpersistent_flags+=("--scenario")
    local_nonpersistent_flags+=("--scenario=")
    local_nonpersistent_flags+=("-s")
    flags+=("--ip=")
    two_word_flags+=("--ip")
    two_word_flags+=("-i")
    local_nonpersistent_flags+=("--ip")
    local_nonpersistent_flags+=("--ip=")
    local_nonpersistent_flags+=("-i")
    flags+=("--range=")
    two_word_flags+=("--range")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--range")
    local_nonpersistent_flags+=("--range=")
    local_nonpersistent_flags+=("-r")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--limit")
    local_nonpersistent_flags+=("--limit=")
    local_nonpersistent_flags+=("-l")
    flags+=("--no-simu")
    local_nonpersistent_flags+=("--no-simu")
    flags+=("--machine")
    flags+=("-m")
    local_nonpersistent_flags+=("--machine")
    local_nonpersistent_flags+=("-m")
    flags+=("--contained")
    local_nonpersistent_flags+=("--contained")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_decisions()
{
    last_command="cscli_decisions"

    command_aliases=()

    commands=()
    commands+=("add")
    commands+=("delete")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("remove")
        aliashash["remove"]="delete"
    fi
    commands+=("import")
    commands+=("list")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_explain()
{
    last_command="cscli_explain"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--dsn=")
    two_word_flags+=("--dsn")
    two_word_flags+=("-d")
    flags+=("--failures")
    flags+=("--file=")
    two_word_flags+=("--file")
    two_word_flags+=("-f")
    flags+=("--log=")
    two_word_flags+=("--log")
    two_word_flags+=("-l")
    flags+=("--type=")
    two_word_flags+=("--type")
    two_word_flags+=("-t")
    flags+=("--verbose")
    flags+=("-v")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_help()
{
    last_command="cscli_help"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_cscli_hub_list()
{
    last_command="cscli_hub_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    flags+=("--branch=")
    two_word_flags+=("--branch")
    two_word_flags+=("-b")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_hub_update()
{
    last_command="cscli_hub_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--branch=")
    two_word_flags+=("--branch")
    two_word_flags+=("-b")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_hub_upgrade()
{
    last_command="cscli_hub_upgrade"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--force")
    flags+=("--branch=")
    two_word_flags+=("--branch")
    two_word_flags+=("-b")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_hub()
{
    last_command="cscli_hub"

    command_aliases=()

    commands=()
    commands+=("list")
    commands+=("update")
    commands+=("upgrade")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_hubtest_clean()
{
    last_command="cscli_hubtest_clean"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--crowdsec=")
    two_word_flags+=("--crowdsec")
    flags+=("--cscli=")
    two_word_flags+=("--cscli")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--hub=")
    two_word_flags+=("--hub")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_hubtest_coverage()
{
    last_command="cscli_hubtest_coverage"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--parsers")
    flags+=("--percent")
    flags+=("--scenarios")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--crowdsec=")
    two_word_flags+=("--crowdsec")
    flags+=("--cscli=")
    two_word_flags+=("--cscli")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--hub=")
    two_word_flags+=("--hub")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_hubtest_create()
{
    last_command="cscli_hubtest_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ignore-parsers")
    flags+=("--parsers=")
    two_word_flags+=("--parsers")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--parsers")
    local_nonpersistent_flags+=("--parsers=")
    local_nonpersistent_flags+=("-p")
    flags+=("--postoverflows=")
    two_word_flags+=("--postoverflows")
    local_nonpersistent_flags+=("--postoverflows")
    local_nonpersistent_flags+=("--postoverflows=")
    flags+=("--scenarios=")
    two_word_flags+=("--scenarios")
    two_word_flags+=("-s")
    local_nonpersistent_flags+=("--scenarios")
    local_nonpersistent_flags+=("--scenarios=")
    local_nonpersistent_flags+=("-s")
    flags+=("--type=")
    two_word_flags+=("--type")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--crowdsec=")
    two_word_flags+=("--crowdsec")
    flags+=("--cscli=")
    two_word_flags+=("--cscli")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--hub=")
    two_word_flags+=("--hub")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_hubtest_eval()
{
    last_command="cscli_hubtest_eval"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--expr=")
    two_word_flags+=("--expr")
    two_word_flags+=("-e")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--crowdsec=")
    two_word_flags+=("--crowdsec")
    flags+=("--cscli=")
    two_word_flags+=("--cscli")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--hub=")
    two_word_flags+=("--hub")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_hubtest_explain()
{
    last_command="cscli_hubtest_explain"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--crowdsec=")
    two_word_flags+=("--crowdsec")
    flags+=("--cscli=")
    two_word_flags+=("--cscli")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--hub=")
    two_word_flags+=("--hub")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_hubtest_info()
{
    last_command="cscli_hubtest_info"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--crowdsec=")
    two_word_flags+=("--crowdsec")
    flags+=("--cscli=")
    two_word_flags+=("--cscli")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--hub=")
    two_word_flags+=("--hub")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_hubtest_list()
{
    last_command="cscli_hubtest_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--crowdsec=")
    two_word_flags+=("--crowdsec")
    flags+=("--cscli=")
    two_word_flags+=("--cscli")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--hub=")
    two_word_flags+=("--hub")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_hubtest_run()
{
    last_command="cscli_hubtest_run"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    local_nonpersistent_flags+=("--all")
    flags+=("--clean")
    local_nonpersistent_flags+=("--clean")
    flags+=("--no-clean")
    local_nonpersistent_flags+=("--no-clean")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--crowdsec=")
    two_word_flags+=("--crowdsec")
    flags+=("--cscli=")
    two_word_flags+=("--cscli")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--hub=")
    two_word_flags+=("--hub")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_hubtest()
{
    last_command="cscli_hubtest"

    command_aliases=()

    commands=()
    commands+=("clean")
    commands+=("coverage")
    commands+=("create")
    commands+=("eval")
    commands+=("explain")
    commands+=("info")
    commands+=("list")
    commands+=("run")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--crowdsec=")
    two_word_flags+=("--crowdsec")
    flags+=("--cscli=")
    two_word_flags+=("--cscli")
    flags+=("--hub=")
    two_word_flags+=("--hub")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_lapi_register()
{
    last_command="cscli_lapi_register"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--file=")
    two_word_flags+=("--file")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--file")
    local_nonpersistent_flags+=("--file=")
    local_nonpersistent_flags+=("-f")
    flags+=("--machine=")
    two_word_flags+=("--machine")
    local_nonpersistent_flags+=("--machine")
    local_nonpersistent_flags+=("--machine=")
    flags+=("--url=")
    two_word_flags+=("--url")
    two_word_flags+=("-u")
    local_nonpersistent_flags+=("--url")
    local_nonpersistent_flags+=("--url=")
    local_nonpersistent_flags+=("-u")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_lapi_status()
{
    last_command="cscli_lapi_status"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_lapi()
{
    last_command="cscli_lapi"

    command_aliases=()

    commands=()
    commands+=("register")
    commands+=("status")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_machines_add()
{
    last_command="cscli_machines_add"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--auto")
    flags+=("-a")
    local_nonpersistent_flags+=("--auto")
    local_nonpersistent_flags+=("-a")
    flags+=("--file=")
    two_word_flags+=("--file")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--file")
    local_nonpersistent_flags+=("--file=")
    local_nonpersistent_flags+=("-f")
    flags+=("--force")
    local_nonpersistent_flags+=("--force")
    flags+=("--interactive")
    flags+=("-i")
    local_nonpersistent_flags+=("--interactive")
    local_nonpersistent_flags+=("-i")
    flags+=("--password=")
    two_word_flags+=("--password")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    local_nonpersistent_flags+=("-p")
    flags+=("--url=")
    two_word_flags+=("--url")
    two_word_flags+=("-u")
    local_nonpersistent_flags+=("--url")
    local_nonpersistent_flags+=("--url=")
    local_nonpersistent_flags+=("-u")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_machines_delete()
{
    last_command="cscli_machines_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--machine=")
    two_word_flags+=("--machine")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--machine")
    local_nonpersistent_flags+=("--machine=")
    local_nonpersistent_flags+=("-m")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_machines_list()
{
    last_command="cscli_machines_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_machines_validate()
{
    last_command="cscli_machines_validate"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_machines()
{
    last_command="cscli_machines"

    command_aliases=()

    commands=()
    commands+=("add")
    commands+=("delete")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("remove")
        aliashash["remove"]="delete"
    fi
    commands+=("list")
    commands+=("validate")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_metrics()
{
    last_command="cscli_metrics"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--no-unit")
    flags+=("--url=")
    two_word_flags+=("--url")
    two_word_flags+=("-u")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_notifications_inspect()
{
    last_command="cscli_notifications_inspect"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_notifications_list()
{
    last_command="cscli_notifications_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_notifications()
{
    last_command="cscli_notifications"

    command_aliases=()

    commands=()
    commands+=("inspect")
    commands+=("list")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_parsers_inspect()
{
    last_command="cscli_parsers_inspect"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--url=")
    two_word_flags+=("--url")
    two_word_flags+=("-u")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_cscli_parsers_install()
{
    last_command="cscli_parsers_install"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--download-only")
    flags+=("-d")
    flags+=("--force")
    flags+=("--ignore")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_cscli_parsers_list()
{
    last_command="cscli_parsers_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_parsers_remove()
{
    last_command="cscli_parsers_remove"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("--force")
    flags+=("--purge")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_cscli_parsers_upgrade()
{
    last_command="cscli_parsers_upgrade"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("--force")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_cscli_parsers()
{
    last_command="cscli_parsers"

    command_aliases=()

    commands=()
    commands+=("inspect")
    commands+=("install")
    commands+=("list")
    commands+=("remove")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("delete")
        aliashash["delete"]="remove"
    fi
    commands+=("upgrade")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_postoverflows_inspect()
{
    last_command="cscli_postoverflows_inspect"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_cscli_postoverflows_install()
{
    last_command="cscli_postoverflows_install"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--download-only")
    flags+=("-d")
    flags+=("--force")
    flags+=("--ignore")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_cscli_postoverflows_list()
{
    last_command="cscli_postoverflows_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_postoverflows_remove()
{
    last_command="cscli_postoverflows_remove"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("--force")
    flags+=("--purge")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_cscli_postoverflows_upgrade()
{
    last_command="cscli_postoverflows_upgrade"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    flags+=("--force")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_cscli_postoverflows()
{
    last_command="cscli_postoverflows"

    command_aliases=()

    commands=()
    commands+=("inspect")
    commands+=("install")
    commands+=("list")
    commands+=("remove")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("delete")
        aliashash["delete"]="remove"
    fi
    commands+=("upgrade")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_scenarios_inspect()
{
    last_command="cscli_scenarios_inspect"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--url=")
    two_word_flags+=("--url")
    two_word_flags+=("-u")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_cscli_scenarios_install()
{
    last_command="cscli_scenarios_install"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--download-only")
    flags+=("-d")
    flags+=("--force")
    flags+=("--ignore")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_cscli_scenarios_list()
{
    last_command="cscli_scenarios_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_scenarios_remove()
{
    last_command="cscli_scenarios_remove"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("--force")
    flags+=("--purge")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_cscli_scenarios_upgrade()
{
    last_command="cscli_scenarios_upgrade"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    flags+=("--force")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_cscli_scenarios()
{
    last_command="cscli_scenarios"

    command_aliases=()

    commands=()
    commands+=("inspect")
    commands+=("install")
    commands+=("list")
    commands+=("remove")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("delete")
        aliashash["delete"]="remove"
    fi
    commands+=("upgrade")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_simulation_disable()
{
    last_command="cscli_simulation_disable"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--global")
    flags+=("-g")
    local_nonpersistent_flags+=("--global")
    local_nonpersistent_flags+=("-g")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_simulation_enable()
{
    last_command="cscli_simulation_enable"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--global")
    flags+=("-g")
    local_nonpersistent_flags+=("--global")
    local_nonpersistent_flags+=("-g")
    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_simulation_status()
{
    last_command="cscli_simulation_status"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_simulation()
{
    last_command="cscli_simulation"

    command_aliases=()

    commands=()
    commands+=("disable")
    commands+=("enable")
    commands+=("status")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_version()
{
    last_command="cscli_version"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--debug")
    flags+=("--error")
    flags+=("--info")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--warning")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_cscli_root_command()
{
    last_command="cscli"

    command_aliases=()

    commands=()
    commands+=("alerts")
    commands+=("bouncers")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("bouncer")
        aliashash["bouncer"]="bouncers"
    fi
    commands+=("capi")
    commands+=("collections")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("collection")
        aliashash["collection"]="collections"
    fi
    commands+=("completion")
    commands+=("config")
    commands+=("console")
    commands+=("dashboard")
    commands+=("decisions")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("decision")
        aliashash["decision"]="decisions"
    fi
    commands+=("explain")
    commands+=("help")
    commands+=("hub")
    commands+=("hubtest")
    commands+=("lapi")
    commands+=("machines")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("machine")
        aliashash["machine"]="machines"
    fi
    commands+=("metrics")
    commands+=("notifications")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("notification")
        aliashash["notification"]="notifications"
        command_aliases+=("notifications")
        aliashash["notifications"]="notifications"
    fi
    commands+=("parsers")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("parser")
        aliashash["parser"]="parsers"
    fi
    commands+=("postoverflows")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("postoverflow")
        aliashash["postoverflow"]="postoverflows"
    fi
    commands+=("scenarios")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("scenario")
        aliashash["scenario"]="scenarios"
    fi
    commands+=("simulation")
    commands+=("version")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    flags+=("--debug")
    flags+=("--info")
    flags+=("--warning")
    flags+=("--error")
    flags+=("--trace")

    must_have_one_flag=()
    must_have_one_noun=()
    must_have_one_noun+=("alerts")
    must_have_one_noun+=("bouncers")
    must_have_one_noun+=("capi")
    must_have_one_noun+=("collections")
    must_have_one_noun+=("completion")
    must_have_one_noun+=("config")
    must_have_one_noun+=("console")
    must_have_one_noun+=("dashboard")
    must_have_one_noun+=("decisions")
    must_have_one_noun+=("hub")
    must_have_one_noun+=("lapi")
    must_have_one_noun+=("machines")
    must_have_one_noun+=("metrics")
    must_have_one_noun+=("notifications")
    must_have_one_noun+=("parsers")
    must_have_one_noun+=("postoverflows")
    must_have_one_noun+=("scenarios")
    must_have_one_noun+=("simulation")
    must_have_one_noun+=("version")
    noun_aliases=()
}

__start_cscli()
{
    local cur prev words cword split
    declare -A flaghash 2>/dev/null || :
    declare -A aliashash 2>/dev/null || :
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -s || return
    else
        __cscli_init_completion -n "=" || return
    fi

    local c=0
    local flag_parsing_disabled=
    local flags=()
    local two_word_flags=()
    local local_nonpersistent_flags=()
    local flags_with_completion=()
    local flags_completion=()
    local commands=("cscli")
    local command_aliases=()
    local must_have_one_flag=()
    local must_have_one_noun=()
    local has_completion_function=""
    local last_command=""
    local nouns=()
    local noun_aliases=()

    __cscli_handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_cscli cscli
else
    complete -o default -o nospace -F __start_cscli cscli
fi

# ex: ts=4 sw=4 et filetype=sh
