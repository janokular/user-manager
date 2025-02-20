#!/bin/bash

# This script creates a new user on the local system
# You must supply a username as an argument to the script
# Optionally, you can also provide a comment for the account as an argument
# A password will be automatically generated for the account
# The username, password, and host for the account will be displayed

# Make sure the script is being executed with superuser privileges
if [[ "${UID}" -ne 0 ]]
then
  echo 'Please run with sudo or as root.' >&2
  exit 1
fi

# If user doesn't supply at least one argument, then give them help
NUMBER_OF_PARAMETERS="${#}"
if [[ "${NUMBER_OF_PARAMETERS}" -lt 1 ]]
then
  echo "Usage: ${0} USER_NAME [COMMENT]..." >&2
  exit 1
fi

# The first parameter is the user name
USER_NAME="${1}"

# The rest of the parameters are for the account comments
shift 1
COMMENT="${@}"

# Generate password
PASSWORD=$(date +%s%N | sha256sum | head -c48)

# Create the user with the password.
useradd -c "${COMMENT}" -m ${USER_NAME} &> /dev/null

# Check to see if the useradd command succeeded
if [[ "${?}" -ne 0 ]]
then
  echo 'Command useradd did NOT succeeded!' >&2
  exit 1
fi

# Set the password.
echo "${USER_NAME}:${PASSWORD}" | chpasswd &> /dev/null

# Check if the passwd command succeeded
if [[ "${?}" -ne 0 ]]
then
  echo 'Command chpasswd did NOT succeeded!' >&2
  exit 1
fi

# Force password change on first login
passwd -e ${USER_NAME} &> /dev/null

# Display the username, password, and the host where te user was created
echo -e "username:\n${USER_NAME}"
echo -e "password:\n${PASSWORD}"
echo -e "host:\n${HOSTNAME}"
exit 0
