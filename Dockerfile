# Dockerfile: dotfiles setup (based on debian:bookworm)
# -----------------------------------------------------------------------------
# This container starts from a clean debian image
# and sets up user dotfiles from the public repo.

FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl \
       git \
       ca-certificates \
       file \
       ripgrep \
       libfuse2 \
       xclip \
       tmux \
       neovim \
       dos2unix \
    && rm -rf /var/lib/apt/lists/*

# Install latest fzf binary (≥ 0.56.0) system-wide
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /opt/fzf && \
    /opt/fzf/install --bin --no-update-rc --no-key-bindings --no-completion && \
    mv /opt/fzf/bin/fzf /usr/local/bin/ && \
    rm -rf /opt/fzf

# Create a new user (named `developer`, change if desired)
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID --create-home --shell /bin/bash $USERNAME

# Switch to new user for rust install
USER $USERNAME
ENV USER=$USERNAME
ENV HOME=/home/$USERNAME

ENV SHELL_CONFIG=$HOME/.bashrc

# Install plug.vim
RUN curl -fLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Copy the local dotfiles repo into the container
COPY --chown=$USERNAME:$USERNAME . /opt/dotfiles

# Convert all shell scripts to Unix line endings
RUN find /opt/dotfiles -type f -exec dos2unix {} +

RUN mkdir -p ~/.config/nvim && \
    ln -s /opt/dotfiles/init.vim $HOME/.config/nvim/init.vim

RUN nvim +PlugInstall +qall
RUN /bin/bash /opt/dotfiles/scripts/install_shell_config.sh

# Link .tmux.conf
RUN ln -s /opt/dotfiles/tmux.conf $HOME/.tmux.conf

# Launch an interactive Bash shell by default
CMD ["/bin/bash"]

