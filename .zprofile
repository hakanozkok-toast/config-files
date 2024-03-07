if [ "$(uname)" == "Darwin" ]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH=$PATH:/usr/local/go/bin
eval "$(pyenv init --path)"
