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
       dos2unix \
    && rm -rf /var/lib/apt/lists/*

# Install a recent Neovim from GitHub releases (Debian's apt nvim is too old for
# AstroNvim, which requires Neovim >= 0.10).
RUN curl -fL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
      -o /tmp/nvim.tar.gz && \
    tar -C /opt -xzf /tmp/nvim.tar.gz && \
    ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim && \
    rm /tmp/nvim.tar.gz

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

# Copy the local dotfiles repo into the container
COPY --chown=$USERNAME:$USERNAME . /opt/dotfiles

# Convert all shell scripts to Unix line endings
RUN find /opt/dotfiles -type f -exec dos2unix {} +

# Bootstrap AstroNvim and drop in our personal plugin spec, then install plugins
# with lazy.nvim (the AstroNvim way -- no vim-plug).
RUN git clone --depth 1 https://github.com/AstroNvim/template $HOME/.config/nvim && \
    rm -rf $HOME/.config/nvim/.git && \
    mkdir -p $HOME/.config/nvim/lua/plugins && \
    ln -s /opt/dotfiles/nvim/lua/plugins/dotfiles.lua $HOME/.config/nvim/lua/plugins/dotfiles.lua && \
    nvim --headless "+Lazy! sync" +qa

RUN /bin/bash /opt/dotfiles/scripts/install_shell_config.sh

# Link .tmux.conf
RUN ln -s /opt/dotfiles/tmux.conf $HOME/.tmux.conf

# Launch an interactive Bash shell by default
CMD ["/bin/bash"]

