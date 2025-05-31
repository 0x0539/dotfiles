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
       sudo \
       ca-certificates \
       ripgrep \
       libfuse2 \
       xclip \
       tmux \
       dos2unix \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.local/bin:${PATH}"

# Pre-install vim-plug to ensure plug.vim is loaded to the correct directory
RUN curl -fLo /root/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Pre-install fzf binary to avoid plugin post-install scripts needing FUSE or user input
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf \
    && /root/.fzf/install --bin --no-update-rc --no-key-bindings --no-completion \
    && mv /root/.fzf/bin/fzf /usr/local/bin \
    && rm -rf /root/.fzf

# Copy the local dotfiles repo into the container
COPY . /opt/dotfiles

# Convert all shell scripts to Unix line endings
RUN find /opt/dotfiles -type f -exec dos2unix {} +

# Run the install script
RUN cd /opt/dotfiles \
    && /bin/bash /opt/dotfiles/install.sh

# Launch an interactive Bash shell by default
CMD ["/bin/bash"]

