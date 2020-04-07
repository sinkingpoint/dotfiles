IS_LINUX=$(expr `uname` = 'Linux')
IS_OSX=$(expr `uname` = 'Darwin')

autoload -Uz compinit && compinit
autoload -U promptinit && promptinit
autoload -U colors && colors

setopt AUTO_CD
setopt CORRECT
setopt HIST_IGNORE_ALL_DUPS
setopt MULTIOS
setopt NO_BEEP

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# formatting and messages
# # http://www.masterzen.fr/2009/04/19/in-love-with-zsh-part-one/
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format "$fg[yellow]%B--- %d%b"
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format "$fg[red]No matches for:$reset_color %d"
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

# ===== Correction
setopt correct # spelling correction for commands
setopt correctall # spelling correction for arguments

# ===== Prompt
setopt prompt_subst # Enable parameter expansion, command substitution, and arithmetic expansion in the prompt
setopt transient_rprompt # only show the rprompt on the current prompt

# ===== Scripts and Functions
setopt multios # perform implicit tees or cats when multiple redirections are attempted

# ==================== History ====================

HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_all_dups
setopt hist_ignore_space

# ==================== Aliases ====================

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias dirs='dirs -v'

if [ $IS_LINUX = 1 ]; then
    alias ls='ls --color=auto'
    alias rm='rm -Iv --one-file-system'
elif [ $IS_OSX = 1 ]; then
    alias ls='ls -G'
    alias rm='rm -iv'
fi
alias la='ls -la'
alias ll='ls -l'
alias l1='ls -1'

alias grep='grep --color=auto'

alias mkdir='mkdir -p -v'

alias mv='mv -iv'

alias shred='shred -v'

# Copy / paste aliases
if [ $IS_LINUX = 1 ]; then
    alias c='xclip -sel clip -i'
    alias v='xclip -sel clip -o'
elif [ $IS_OSX = 1 ]; then
    alias c='pbcopy'
    alias v='pbpaste'
fi

# Power controls
alias shutdown='sudo shutdown'
alias halt='sudo halt'
alias poweroff='sudo poweroff'
alias reboot='sudo reboot'

# Net Shortcuts
alias digg='dig @8.8.8.8'
alias digc='dig @1.1.1.1'
alias cwhois='whois -h whois.cymru.com'
alias curlh='curl -vso /dev/null'

if [ -d ~/go/bin ]; then
    export PATH=$PATH:/Users/colin/go/bin
fi

# ==================== Keys ====================

typeset -A key

key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# Setup key accordingly
[[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
[[ -n "${key[Insert]}"   ]]  && bindkey  "${key[Insert]}"   overwrite-mode
[[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       up-line-or-history
[[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     down-line-or-history
[[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"   beginning-of-buffer-or-history
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" end-of-buffer-or-history
[[ -n "^[${key[Left]}"   ]]  && bindkey  "^[${key[Left]}"   backward-word
[[ -n "^[${key[Right]}"  ]]  && bindkey  "^[${key[Right]}"  forward-word

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        printf '%s' "${terminfo[smkx]}"
    }

    function zle-line-finish () {
        printf '%s' "${terminfo[rmkx]}"
    }

    zle -N zle-line-init
    zle -N zle-line-finish
fi

# Change tmux window title on ssh
ssh() {
    if [ "$(ps -p $(ps -p $$ -o ppid=) -o comm=)" = "tmux" ]; then
        tmux rename-window "$(echo $* | cut -d . -f 1)"
        command ssh "$@"
        tmux set-window-option automatic-rename "on" 1>/dev/null
    else
        command ssh "$@"
    fi
}

# This remembers the directory stack
# Use dirs -v to view
# Use cd -<num> to change to one of them

# Keep a separate dirstack file for each terminal
DIRSTACKFILE=`mktemp`
trap "rm -rf $DIRSTACKFILE" EXIT

chpwd() {
    print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
}

DIRSTACKSIZE=20

setopt autopushd pushdsilent pushdtohome

# Remove duplicate entries
setopt pushdignoredups
# This reverts the +/- operators.
setopt pushdminus

alias vi="vim"
export PATH=$PATH:/usr/local/go/bin
export PATH="$HOME/.cargo/bin:$PATH"
export PATH=$PATH:~/.local/bin

source ~/.dotfiles/prompt.zsh
source ~/.dotfiles/jump.zsh

if [ -z $TMUX ]; then
    (tmux ls | grep -vq attached && exec tmux -2 at) || exec tmux -2
fi
