#!/bin/bash

# This script creates a new user on the local system
# You will be prompted for the account name, the person name and password

# Make sure the script is being executed with superuser privileges
if [[ "${UID}" -ne 0 ]]
then
  echo 'Please run with sudo or as root.'
  exit 1
fi

# Get the username (login)
read -p 'Enter the username to create: ' USER_NAME

# Get the real name
read -p 'Enter the name of the person or application that will be using this account: ' COMMENT

# Get the password
read -p 'Enter the password to use for the account: ' PASSWORD

# Create the user with the password
useradd -c "${COMMENT}" -m ${USER_NAME}

# Check to see if the useradd command succeeded
if [[ "${?}" -ne 0 ]]
then
  echo 'Command useradd did NOT succeeded!'
  exit 1
fi

# Set the password
echo "${USER_NAME}:${PASSWORD}" | chpasswd

# Check if the passwd command succeeded
if [[ "${?}" -ne 0 ]]
then
  echo 'Command chpasswd did NOT succeeded!'
  exit 1
fi

# Force password change on first login
passwd -e ${USER_NAME}

# Display the username, password, and the host where te user was created
echo "username: ${USER_NAME}"
echo "password: ${PASSWORD}"
echo "host: ${HOSTNAME}"
exit 0
