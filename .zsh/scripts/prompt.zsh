#!/usr/bin/env zsh

export PROMPT='$(_myprompt)'

export PROMPT_EOL_MARK=' %B<- \n added by zsh%b'

setopt promptvars
setopt promptsubst


function _myprompt {
    local excode="$?"
    local wd="$(pwd)"
    if [ "$wd" = "$HOME" ]; then
        wd='~'
    else
        wd="$(basename "$wd")"
    fi
    wd="%{${fg_bold[default]}%}$wd%{${fg_no_bold[default]}%}"
    local hostname="$(hostname -s)"
    hostname='Timok'
    local user="$USERNAME"
    local pchar='$'
    if [ "$EUID" -eq '0' ]; then
        pchar='#'
    fi
    if [ "$excode" -ne '0' ]; then
        pchar="%{${fg[red]}%}$pchar%{${color_reset}%}"
    fi
    local jobcount="$(_jobcount)"
    if [ "$jobcount" -ne '0' ]; then
        jobcount="[%%${jobcount}]"
    else
        jobcount=''
    fi
    local firstpart=''
    if git rev-parse --is-inside-work-tree 1> /dev/null 2> /dev/null; then
        firstpart="$(_gitprompt)"
    else
        firstpart="${jobcount}${hostname}:${wd}"
    fi
    printf "%s %s%s " "$firstpart" "$user" "$pchar"
}


function _gitprompt {
    local gitdir="$(cd "$(git rev-parse --git-dir)" && pwd)"
    local prefix="$(dirname "$(dirname "${gitdir}")")/"
    local wd="$(pwd)"
    local git_path=${wd#$prefix}
    print "$git_path"
}

function _jobcount {
    echo $(jobs | wc -l)
}
