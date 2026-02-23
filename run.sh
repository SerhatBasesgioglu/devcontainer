#!/usr/bin/env bash
set -euo pipefail

container="devcontainer"
image="dev:1"
containerHome="/devcontainer"
uid=$(id -u)
gid=$(id -g)
user=$(id -un)
group=$(id -gn)
tmuxSessionTitle="${1:-}"

path="$containerHome"
if [[ -n "$tmuxSessionTitle" ]]; then
  path="$containerHome$tmuxSessionTitle"
fi

# Check if container exists and started
if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
  if ! docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
    docker start "$container" >/dev/null
  fi
else
  docker run \
    --rm -d \
    --name "$container" \
    --hostname "$container" \
    --privileged \
    --network host \
    --env DEVCONTAINER=1 \
    --volume "$HOME/.devcontainer:$containerHome" \
    --volume "$HOME/repos":"$containerHome/repos" \
    --volume "$HOME/.ssh":"$containerHome/.ssh" \
    "$image"
fi

# If user with same id but different name exists delete it, then create host user, group and home, add to sudo group too
docker exec -u root "$container" bash -c "
  id -un $user >/dev/null 2>&1 || getent passwd "$uid" | cut -d: -f1 | xargs userdel -- >/dev/null 2>&1
  getent group $gid >/dev/null || groupadd -g $gid $group
  id -u $uid >/dev/null 2>&1 || useradd -u $uid -g $gid -G sudo -s /bin/bash -d $containerHome $user
  mkdir -p $containerHome
  chown -R $uid:$gid $containerHome
  echo \"$user ALL=(ALL) NOPASSWD:ALL\" > /etc/sudoers.d/$user
  grep -q \"$container\" /etc/hosts || echo \"127.0.0.1\" $container >> /etc/hosts
"

# Setup dotfiles
docker exec -u $uid "$container" bash -c "
  mkdir -p $containerHome/.config
  cd $containerHome/repos/dotfiles
  ./install.sh
"

docker exec -it -u $user -w "$path" "$container" bash
