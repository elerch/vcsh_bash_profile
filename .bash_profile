# Load our dotfiles like ~/.bash_prompt, etc…
#   ~/.extra can be used for settings you don’t want to commit,
#   Use it to configure your PATH, thus it being first in line.
for file in ~/.{extra,exports,aliases,functions,secrets}; do
    [ -r "$file" ] && source "$file"
done
unset file

[[ $- = *i* ]] && \
  { [ -r ~/.liquidprompt/liquidprompt ] && \
    source ~/.liquidprompt/liquidprompt; } || \
  { [ -r ~/liquidprompt/liquidprompt ] && \
    source ~/liquidprompt/liquidprompt;} ||
  [ -r ~/.bash_prompt ] && source ~/.bash_prompt

# Add ~/bin:/usr/local/sbin:/usr/local/bin to path if they're not there
! echo $PATH |fgrep /usr/local/bin >/dev/null && \
  PATH=/usr/local/bin:$PATH
! echo $PATH |fgrep /usr/local/sbin >/dev/null && \
  PATH=/usr/local/sbin:$PATH
! echo $PATH |fgrep $HOME/bin >/dev/null && \
  PATH=$HOME/bin:$PATH

if hash brew 2>/dev/null; then
  # brew --prefix is slow
  #PATH=$(brew --prefix coreutils)/libexec/gnubin:$PATH
  PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH
fi

# Set the default text editor.
export EDITOR='vi'
hash vim 2>/dev/null && export EDITOR='vim'
#hash subl 2>/dev/null && export EDITOR='subl -w' # sublime

# Source virtualenvwrapper.sh script
#[ -r /usr/local/bin/virtualenvwrapper.sh ] && \
#  source /usr/local/bin/virtualenvwrapper.sh
# This will be handled by .functions
# See http://blog.n01se.net/agriffis-n01se-net-blog-dynamic-virtualenvwrapper-.html

# Set GOPATH environment variable to the Go lang workspace.
[ -d $HOME/Workspace/go-workspace ] && \
  export GOPATH=$HOME/Workspace/go-workspace

# Add the Go Workspace's bin subdirectory to PATH.
[ "${GOPATH}x" != "x" ] && PATH=$PATH:$GOPATH/bin


hash aws_completer 2>/dev/null && complete -C aws_completer aws

if [ -d ~/.nvm ]; then
  export NVM_DIR=~/.nvm

  # See https://github.com/creationix/nvm/issues/539#issuecomment-245791291
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" --no-use # This loads nvm

  alias node='unalias node ; unalias npm ; nvm use default ; node $@'
  alias npm='unalias node ; unalias npm ; nvm use default ; npm $@'
fi

# Check for GPG, and if installed, use it
# Based on https://gist.github.com/bmhatfield/cc21ec0a3a2df963bffa3c1f884b676b
if [ hash gpg-agent 2> /dev/null ]; then
  # We have gpg-agent, great
  export GPG_TTY=$(tty)
  if [ -f "${HOME}/.gpg-agent-info" && \
     [ -n "$(pgrep -U $USER gpg-agent)" ] ]; then
    . "${HOME}/.gpg-agent-info"
    export GPG_AGENT_INFO
    export SSH_AUTH_SOCK
    export SSH_AGENT_PID
  else
    eval $(gpg-agent --daemon --write-env-file ${HOME}/.gpg-agent-info)
  fi
else
  # Fallback to SSH
  #
  # SSH agent stuff might need to be added. See
  # https://coderwall.com/p/qdwcpg/using-the-latest-ssh-from-homebrew-on-osx
  # for more details
  #
  # Use single ssh-agent launched by launchd
  #
  [ -f /usr/local/bin/ssh-ask-keychain ] && \
    export SSH_ASKPASS=/usr/local/bin/ssh-ask-keychain

  if [ -f $HOME/.ssh-agent-pid ] && \
    kill -0 `cat $HOME/.ssh-agent-pid` 2>/dev/null; then
    SSH_AUTH_SOCK=`cat $HOME/.ssh-auth-sock`
    SSH_AGENT_PID=`cat $HOME/.ssh-agent-pid`
    export SSH_AUTH_SOCK SSH_AGENT_PID
  else
    # Discover the running ssh-agent started by launchd
    export SSH_AGENT_PID=$(pgrep -U $USER ssh-agent)
    if [ -n "$SSH_AGENT_PID" ]; then
      export SSH_AUTH_SOCK=\
        $(lsof -U -a -p $SSH_AGENT_PID -F n | grep '^n/' | cut -c2-)
      echo "$SSH_AUTH_SOCK" > ${HOME}/.ssh-auth-sock
      echo "$SSH_AGENT_PID" > ${HOME}/.ssh-agent-pid
      #else
      # echo "No running ssh-agent found.  Check your launchd service."
    fi

    # Add all the local keys, getting the passphrase from keychain,
    # helped by the $SSH_ASKPASS script.
    ssh-add < /dev/null 2>/dev/null
  fi
fi # SSH section if gpg-agent not available
