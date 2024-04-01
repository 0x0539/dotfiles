ln -f -s $PWD/vimrc $HOME/.vimrc
mkdir -p $HOME/.config/nvim
ln -f -s $PWD/vimrc $HOME/.config/nvim/init.vim
ln -f -s $PWD/tmux.conf $HOME/.tmux.conf

sudo apt-get install fzf

echo "source /usr/share/doc/fzf/examples/key-bindings.bash" >> ~/.bashrc
echo "source /usr/share/bash-completion/completions/fzf" >> ~/.bashrc
echo "source /usr/share/doc/fzf/examples/fzf.vim" >> ~/.vimrc


