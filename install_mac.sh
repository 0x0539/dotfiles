ln -f -s $PWD/vimrc $HOME/.vimrc
mkdir -p $HOME/.config/nvim
ln -f -s $PWD/vimrc $HOME/.config/nvim/init.vim
ln -f -s $PWD/tmux.conf $HOME/.tmux.conf

brew reinstall fzf

BREW_DIR="$(brew --prefix fzf)"

echo "source $BREW_DIR/shell/key-bindings.zsh" >> ~/.zshrc
echo "source $BREW_DIR/shell/completion.zsh" >> ~/.zshrc
echo "source $BREW_DIR/plugin/fzf.vim" >> ~/.vimrc


