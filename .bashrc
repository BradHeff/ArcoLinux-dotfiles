#
# ~/.bashrc
#

. ~/.git-prompt.bash

precmd() {
    echo `git_prompt_precmd`
}
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export HISTCONTROL=ignoreboth:erasedups

SELECT(){
	if [ "$?" -eq 0 ]
    then
		echo ""
	else 
		echo "[X]"
fi
}

COLOR_BLACK="\[$(tput setaf 0)\]"
COLOR_RED="\[$(tput setaf 1)\]"
COLOR_GREEN="\[$(tput setaf 2)\]"
COLOR_YELLOW="\[$(tput setaf 3)\]"
COLOR_BLUE="\[$(tput setaf 4)\]"
COLOR_PURPLE="\[$(tput setaf 5)\]"
COLOR_CYAN="\[$(tput setaf 6)\]"
COLOR_WHITE="\[$(tput setaf 7)\]"
COLOR_RESET="\[$(tput sgr0)\]"


PS1="${COLOR_RED}\$(SELECT)${COLOR_CYAN}[${COLOR_RESET}\\w${COLOR_CYAN}]-[${COLOR_RESET}\\@${COLOR_CYAN}]${COLOR_PURPLE}\$(precmd)
${COLOR_YELLOW}>${COLOR_RESET} "

mkcd() {
        if [ $# != 1 ]; then
                echo "Usage: mkcd <dir>"
        else
                mkdir -p $1 && cd $1
        fi
}
cdls() { 
	cd "$@" && l; 
}

rd(){
    pwd > "$HOME/.lastdir_$1"
}

crd(){
        lastdir="$(cat "$HOME/.lastdir_$1")">/dev/null 2>&1
        if [ -d "$lastdir" ]; then
                cd "$lastdir"
        else
                echo "no existing directory stored in buffer $1">&2
        fi
}
extract () {
   if [ -f $1 ] ; then
       case $1 in
           *.tar.bz2)   tar xvjf $1    ;;
           *.tar.gz)    tar xvzf $1    ;;
           *.bz2)       bunzip2 $1     ;;
           *.rar)       unrar x $1       ;;
           *.gz)        gunzip $1      ;;
           *.tar)       tar xvf $1     ;;
           *.tbz2)      tar xvjf $1    ;;
           *.tgz)       tar xvzf $1    ;;
           *.zip)       unzip $1       ;;
           *.Z)         uncompress $1  ;;
           *.7z)        7z x $1        ;;
           *)           echo "don't know how to extract '$1'..." ;;
       esac
   else
       echo "'$1' is not a valid file!"
   fi
 }

youtube() {
    if [ $# -eq 1 ]
    then  
        youtube-dl -q "$1"
    elif [ $# -eq 2 ]
    then
        youtube-dl -q -x --audio-format mp3 "$2" 
    else
        echo "No arguments supplied"
    fi
}

if [ -d "$HOME/.bin" ];
then
	PATH="$HOME/.bin:$PATH"
fi

#list
alias ls='ls --color=auto'
alias la='ls -a'
alias ll='ls -la'
alias l='ls' 					
alias l.="ls -A | egrep '^\.'"      

#fix obvious typo's
alias cd..="cd .."
alias pdw="pwd"

## Colorize the grep command output for ease of use (good for log files)##
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"

#readable output
alias df='df -h'

#pacman unlock
alias unlock="sudo rm /var/lib/pacman/db.lck"

#free
alias free="free -mt"

#continue download
alias wget="wget -c"

#userlist
alias userlist="cut -d: -f1 /etc/passwd"

#merge new settings
alias merge="xrdb -merge ~/.Xresources"

# Aliases for software managment
# pacman or pm
alias pacman="sudo pacman --color auto"
alias update="sudo pacman -Syyu"
alias pins="sudo pacman -S --color auto"
alias psr="sudo pacman -Ss --color auto"
alias pdep="deps p"

# yay as aur helper - updates everything
alias pksyua="yay -Syu --noconfirm"
alias yins="yay -S --color auto"
alias ysr="yay -Ss --color auto"
alias ydep="deps y"

deps() {
	if [[ "$1" -eq "p" ]]
	then
		sudo pacman -Si "$2" |sed -n '/Depends\ On/,/:/p'|sed '$d'|cut -d: -f2
	elif [[ "$1" -eq "y" ]]
	then
		yay -Si "$2" |sed -n '/Depends\ On/,/:/p'|sed '$d'|cut -d: -f2
	fi	
}

#ps
alias ps="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"

#grub update
alias update-grub="sudo grub-mkconfig -o /boot/grub/grub.cfg"

#improve png
alias fixpng="find . -type f -name "*.png" -exec convert {} -strip {} \;"

#add new fonts
alias fc="sudo fc-cache -fv"

#get fastest mirrors in your neighborhood 
alias mirror="sudo reflector --protocol https --latest 50 --number 20 --sort rate --save /etc/pacman.d/mirrorlist"
alias mirrors=mirror

#mounting the folder Public for exchange between host and guest on virtualbox
alias vbm="sudo mount -t vboxsf -o rw,uid=1000,gid=1000 Public /home/$USER/Public"

alias gpl="git pull"
alias gcl="git clone"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push -u origin master"
alias gr="git rm"
alias grd="git rm -r"
alias gra="gitremote"

alias serv="ssh brad@192.168.1.5"

gitremote() {
	if [[ "$1" -eq "gh" ]]
	then
		git remote add origin https://github.com/BradHeff/"$2".git
	elif [[ "$1" -eq "gl" ]]
	then
		git remote add origin https://gitlab.com/BradHeff/"$2".git
	fi	
}
alias sZ="source ~/.bashrc"
alias eZ="vim ~/.bashrc"
alias e3="vim ~/.config/i3/config"

alias ~="cd ~ && source ~/.bashrc"

alias yt='youtube'
alias ytm='youtube mp3'

alias rmd='rm -r'
alias srm='sudo rm'
alias srmd='sudo rm -r'
alias cpd='cp -R'
alias scp='sudo cp'
alias scpd='sudo cp -R'

alias lin='sudo ln -s'

#shopt
shopt -s autocd # change to named directory
shopt -s cdspell # autocorrects cd misspellings
shopt -s cmdhist # save multi-line commands in history as single line
shopt -s dotglob
shopt -s histappend # do not overwrite history
shopt -s expand_aliases # expand aliases

#neofetch
clear && ~/.i3/info
EDITOR=vim

