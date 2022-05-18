#!/usr/bin/env bash
# Update BirdNET-Pi's Git Repo
source /etc/birdnet/birdnet.conf
trap 'exit 1' SIGINT SIGHUP

usage() { echo "Usage: $0 [-r <remote name>] [-b <branch name>]" 1>&2; exit 1; }

# Defaults
remote="origin"
branch="main"

while getopts ":r:b:" o; do
    case "${o}" in
        r)
            remote=${OPTARG}
            ;;
        b)
            branch=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

echo "remote: $remote"
echo "branch: $branch"
exit

USER=$(awk -F: '/1000/ {print $1}' /etc/passwd)
HOME=$(awk -F: '/1000/ {print $6}' /etc/passwd)
my_dir=$HOME/BirdNET-Pi/scripts


sudo_with_user () {
  set -x
  sudo -u $USER "$@"
  set +x
}

# Reset current HEAD to remove any local changes
sudo_with_user git reset --hard

#
sudo_with_user git switch -C $branch --track $remote/$branch
sudo_with_user git -C $my_dir rm privacy_server.py
sudo_with_user git -C $my_dir pull -f $remote $branch
sudo systemctl daemon-reload
sudo ln -sf $my_dir/* /usr/local/bin/

# The script below handles changes to the host system
# Any additions to the updater should be placed in that file.
sudo $my_dir/update_birdnet_snippets.sh
