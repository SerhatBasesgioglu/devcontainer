#dev:1
ARG SDK_IMAGE

FROM ${SDK_IMAGE} AS dev

RUN apt update -y \
  && apt upgrade -y \
  && apt install -y \
    curl \
    git \
    sudo

RUN curl -o /tmp/nvim -L https://github.com/neovim/neovim/releases/download/stable/nvim.appimage



ENTRYPOINT ["sleep", "infinity"]
