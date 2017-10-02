#!/bin/bash

# Constants
FILE_DEBIAN_VERSION="/etc/debian_version"
DEBIAN_VERSION="$(sed 's/\..*//' ${FILE_DEBIAN_VERSION})"
REPO_ANSIBLE="deb [trusted=yes] http://ppa.launchpad.net/ansible/ansible/ubuntu xenial main"
DIR_SOURCES_LIST="/etc/apt/sources.list.d"
FILE_ANSIBLE_SOURCES="${DIR_SOURCES_LIST}/ansible.list"
DIR_SSH_KEYS="${HOME}/.ssh"
NAME_SSH_KEY="ansible@example"
PATH_SSH_KEY_PAIR="${DIR_SSH_KEYS}/${NAME_SSH_KEY}"
URL_KEYSERVER="keyserver.ubuntu.com"
KEY_ANSIBLE="93C4A3FD7BB9C367"
FILE_ANSIBLE_CONFIG_NAME="ansible.cfg"
FILE_ANSIBLE_CONFIG="/etc/ansible/ansible.cfg"
FILE_ANSIBLE_CONFIG_BACKUP="${FILE_ANSIBLE_CONFIG}.bak"
PATH_AUTHORIZED_KEYS="${HOME}/.ssh/authorized_keys"

echo "*** STAGE 0: INSTALLING ANSIBLE ***"
echo "*** START: STAGE 0 ***"
echo

# Prerequesits
echo "=== Step 0: Checking prerequesits ==="
if [ "$(uname)" != "Linux" ] || [ ! -e "${FILE_DEBIAN_VERSION}" ]; then
   echo "ERROR: This script must be run on a Debian GNU/Linux system!" 1>&2
   exit 1
fi
if [ "${DEBIAN_VERSION}" != "9" ]; then
   echo "ERROR: This script can only be run on Debian 9 \"Stretch\"!" 1>&2
   exit 1
fi
if [ "$(id -u)" != "0" ]; then
   echo "ERROR: This script must be run as root!" 1>&2
   exit 1
fi
if [ -e "${PATH_SSH_KEY_PAIR}" ]; then
   echo "ERROR: This host seems to be initialized already, aborting!" 1>&2
   exit 1
fi
echo "All good, moving on..."
echo

echo "=== Step 1: Enabling key downloads ==="
apt -y update
apt -y install dirmngr
echo "Done."
echo

echo "=== Step 2: Installing Ansible ==="
# Add Ansible repository
echo "${REPO_ANSIBLE}" > "${FILE_ANSIBLE_SOURCES}"

# Import repo key
apt-key adv --keyserver "${URL_KEYSERVER}" --recv-keys "${KEY_ANSIBLE}"

# Install Ansible
apt -y update
apt -y dist-upgrade
apt -y install git python ansible openssh-server rsync python-dnspython ntfs-3g cowsay
echo "Done."
echo

echo "=== Step 3: Deploy Ansible configuration file ==="
cp -v "${FILE_ANSIBLE_CONFIG}" "${FILE_ANSIBLE_CONFIG_BACKUP}"
cp -v "${FILE_ANSIBLE_CONFIG_NAME}" "${FILE_ANSIBLE_CONFIG}"
echo "Done."
echo

echo "=== Step 4: Generating a key that can be used by all slaves ==="
ssh-keygen -o -a 100 -t ed25519 -f "${PATH_SSH_KEY_PAIR}" -C "${NAME_SSH_KEY}" -N ""
echo "Done."
echo

echo "=== Step 5: Append key to authorized_keys so that a local connection works ==="
cat "${PATH_SSH_KEY_PAIR}.pub" >> "${PATH_AUTHORIZED_KEYS}"
echo "Done."
echo

echo "*** END: STAGE 0 ***"
