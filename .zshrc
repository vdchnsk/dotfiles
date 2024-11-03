export ZSH="$HOME/.oh-my-zsh"

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:/usr/local/go/bin:$PATH"

# Themes: https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

plugins=(git zsh-autosuggestions vi-mode)

source $ZSH/oh-my-zsh.sh

# Aliases
alias cl="clear"
alias gs="git status"
alias ls='ls --color=never'
alias cd='z'

# zoxide
eval "$(zoxide init zsh)"


# Keybindings
 

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAFEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# tmux
#
# Check if TMUX is already running
if [ -z "$TMUX" ]; then
  # Check if there are any existing tmux sessions
  if tmux ls 2>/dev/null | grep -q "^0:"; then
    # Attach to the existing session
    tmux attach-session -t 0
  else
    # Create a new session
    tmux new-session -s 0
  fi
fi


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
