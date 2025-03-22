""" Neovim Configuration
" Author: Sebastian Goodman (updated by Claude)
" Works on both macOS and Linux

""" Auto-install vim-plug if not already installed
let data_dir = stdpath('data') . '/site'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

""" Plugins
call plug#begin(stdpath('data') . '/plugged')
  " Fuzzy finder
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
call plug#end()

""" Basic Settings
filetype plugin indent on
set tabstop=2                " Tab width is 2 spaces
set shiftwidth=2             " Indent with 2 spaces
set expandtab                " Use spaces instead of tabs
set clipboard=unnamedplus    " Use system clipboard

""" Key Mappings
nnoremap <silent> <C-f> :Files<CR>
nnoremap <silent> <Leader>f :Rg<CR>

""" FZF Configuration
" Try to source FZF from various possible locations
function! SourceIfExists(file)
  if filereadable(expand(a:file))
    exe 'source' a:file
  endif
endfunction

" macOS locations (Homebrew)
call SourceIfExists("/opt/homebrew/opt/fzf/plugin/fzf.vim")
call SourceIfExists("/usr/local/opt/fzf/plugin/fzf.vim")

" Linux locations
call SourceIfExists("/usr/share/doc/fzf/examples/fzf.vim")

" Custom location
call SourceIfExists(expand("~/.config/nvim/fzf.vim"))

