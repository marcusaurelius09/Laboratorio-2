#!/bin/bash

#This is the script for users and permissions.

#Control to check if the user is root

if ["$UID" -ne 0 ]; then
	echo "[ERROR] This script requires root privileges. If you want to run it, please use the sudo command or start as root user..."
	exit 1
fi


#Request data from the user.

echo "To provide you with the best possible service, please complete the following information below:"
read -p "User name: " user
read -p "Group name: " group
read -p "File route: " filepath

# Validate that all data is entered

if [ -z "$user" ] || [ -z "$group" ] || [ -z "$filepath" ]; then #-z it's a conditional test just to verify that the requested information is not empty.
	echo "[ERROR] You need to provide all the requested information :("
	exit 1
fi

#File route verification.

if [ ! -e "$filepath" ]; then
    echo "[ERROR] Path '$filepath' does not exist."
    exit 1
elif [ ! -f "$filepath" ]; then
    echo "[ERROR] '$filepath' exists but is not a regular file."
    exit 1
fi

# Group management
if getent group "$group" >/dev/null; then
    echo "[INFO] The group '$group' already exists."
else
    groupadd "$group"
    echo "[INFO] Group '$group' created successfully."
fi

# User management
if id "$user" &>/dev/null; then
    echo "[INFO] The user '$user' already exists. Adding to group '$group'."
    usermod -aG "$group" "$user"
else
    useradd -m -G "$group" "$user"
    echo "[INFO] User '$user' created successfully and added to group '$group'."
fi

# Change file ownership
chown "$user":"$group" "$filepath"
echo "[INFO] File ownership changed to '$user:$group'."

# Modify file permissions
chmod 750 "$filepath"
echo -e "\n[INFO] Updated file permissions:"
echo "User: read, write, execute (rwx)"
echo "Group: read and execute only (r-x)"
echo "Others: no permissions (---)"
echo -e "\nFinal result:"
ls -l "$filepath"

exit 0
