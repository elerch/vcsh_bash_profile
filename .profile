[ -n "$PS1" ] && [ -n "$BASH" ] && [ -r ~/.commonrc ] && . "$HOME"/.commonrc
# Dash support (login or if ENV=$HOME/.profile is set
[ -n "$PS1" ] && [ "$(echo "$0")" = "sh" ] && [ -r ~/.commonrc ] && . "$HOME"/.commonrc
# ZSH does not use .profile, so no need to handle that here
