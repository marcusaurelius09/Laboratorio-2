#!/bin/bash

# Script for managing users, groups, and file permissions
# Usage: ./ejercicio1.sh <username> <groupname> <filepath>

# ---- Root Check ----
if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] This script requires root privileges. Use: sudo $0 <args>"
    exit 1
fi

# ---- Parameter Validation ----
if [ $# -ne 3 ]; then
    echo "Usage: $0 <username> <groupname> <filepath>"
    exit 1
fi

user="$1"
group="$2"
filepath="$3"

# ---- Input Validation ----
if [ -z "$user" ] || [ -z "$group" ] || [ -z "$filepath" ]; then
    echo "[ERROR] All arguments are required."
    exit 1
fi

# ---- File Validation ----
if [ ! -e "$filepath" ]; then
    echo "[ERROR] Path '$filepath' does not exist."
    exit 1
elif [ ! -f "$filepath" ]; then
    echo "[ERROR] '$filepath' exists but is not a regular file."
    exit 1
fi

# ---- Group Management ----
if getent group "$group" >/dev/null; then
    echo "[INFO] Group '$group' already exists."
else
    groupadd "$group" && echo "[INFO] Group '$group' created successfully."
fi

# ---- User Management ----
if id "$user" &>/dev/null; then
    echo "[INFO] User '$user' already exists. Adding to group '$group'."
    usermod -aG "$group" "$user"
else
    useradd -m -G "$group" "$user" && echo "[INFO] User '$user' created and added to group '$group'."
fi

# ---- File Permissions ----
chown "$user":"$group" "$filepath"
chmod 740 "$filepath"  # Fixed: Group gets read-only (r--), not execute (r-x)

# ---- Results ----
echo -e "\n[INFO] Final permissions for '$filepath':"
ls -l "$filepath"

exit 0
