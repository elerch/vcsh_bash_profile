# Load our dotfiles like ~/.bash_prompt, etc…
#   ~/.extra can be used for settings you don’t want to commit,
#   Use it to configure your PATH, thus it being first in line.
for file in ~/.{extra,bash_prompt,exports,aliases,functions}; do
    [ -r "$file" ] && source "$file"
done
unset file

# Add ~/bin:/usr/local/sbin:/usr/local/bin to path if they're not there
! echo $PATH |fgrep /usr/local/bin >/dev/null && \
  PATH=/usr/local/bin:$PATH
! echo $PATH |fgrep /usr/local/sbin >/dev/null && \
  PATH=/usr/local/sbin:$PATH
! echo $PATH |fgrep $HOME/bin >/dev/null && \
  PATH=$HOME/bin:$PATH

if hash brew 2>/dev/null; then
  PATH=$(brew --prefix coreutils)/libexec/gnubin:$PATH
  export HOMEBREW_GITHUB_API_TOKEN=8b83c2c1ffa4a7972944cd2be460eb85342bb2f4
fi

# Set the default text editor.
if hash subl 2>/dev/null; then
  export EDITOR='subl -w'
elif hash vim 2>/dev/null; then
  export EDITOR='vim'
fi


# Source virtualenvwrapper.sh script
[ -r /usr/local/bin/virtualenvwrapper.sh ] && \
  source /usr/local/bin/virtualenvwrapper.sh

# Set GOPATH environment variable to the Go lang workspace.
[ -d $HOME/Workspace/go-workspace ] && \
  export GOPATH=$HOME/Workspace/go-workspace

# Add the Go Workspace's bin subdirectory to PATH.
[ "${GOPATH}x" != "x" ] && PATH=$PATH:$GOPATH/bin


hash aws_completer 2>/dev/null && complete -C aws_completer aws

if [ -d ~/.nvm ]; then
  export NVM_DIR=~/.nvm

  # TODO: Determine what this means in linux
  hash brew 2>/dev/null && source $(brew --prefix nvm)/nvm.sh
fi

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

