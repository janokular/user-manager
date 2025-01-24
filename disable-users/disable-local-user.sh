#!/bin/bash

# This script disables, deletes, and/or archives users on the local system

ARCHIVE_DIR='/archive'

usage() {
  # Usage message
  echo "Usage: ${0} [-dra] USER [USERN]"
  echo 'Disable a local Linux account.'
  echo '-d Deletes accounts instead of disabling them.'
  echo '-r Removes the home directory associated with the account(s).'
  echo '-a Creates an archive of the home directory associated with the account(s).'
  exit 1
}

# Check if script was run with sudo privliges
if [[ "${UID}" -ne 0 ]]
then
  echo "Pleas run with sudo or as a root." >&2
  exit 1
fi

# Check options provided by the user
while getopts dra OPTION
do
  case ${OPTION} in
    d) DELETE='true' ;;
    r) REMOVE_HOME_DIR='-r' ;;
    a) ARCHIVE='true' ;;
    ?) usage ;;
  esac
done

# Remove the options while leaving the remaining arguments
shift "$(( OPTIND - 1 ))"

# Check if user provided arguments to the script.
if [[ "${#}" -lt 1 ]]
then
  usage
fi

# Loop through all the usernames supplied as arguments
for ACCOUNT in "${@}"
do
  echo "Processing user: ${ACCOUNT}"
  # Check if user is not trying to disable a system account
  ACC_UID=$(id -u "${ACCOUNT}")
  if [[ "${ACC_UID}" -lt 1000 ]]
  then
    echo "Refusing to remove the ${ACCOUNT} account with UID ${ACC_UID}." >&2
    exit 1
  else
    # Check if the account should be archived and if directory ARCHIVE_DIR exists
    if [[ "${ARCHIVE}" = 'true' ]]
    then
      if [[ ! -d "${ARCHIVE_DIR}" ]]
      then
        echo "Creating ${ARCHIVE_DIR} directory." && mkdir -p ${ARCHIVE_DIR}
        if [[ "${?}" -ne 0 ]]
        then
          echo "The archive directory ${ARCHIVE_DIR} could not be created." >&2
          exit 1
        fi
      fi

      # Archive the user's home directory and move it into the ARCHIVE_DIR
      HOME_DIR="/home/${ACCOUNT}"
      ARCHIVE_FILE="${ARCHIVE_DIR}/${ACCOUNT}.tgz"
      if [[ -d "${HOME_DIR}" ]]
      then 
        echo "Archiving ${HOME_DIR} to ${ARCHIVE_FILE}"
        tar -zcf ${ARCHIVE_FILE} ${HOME_DIR} &> /dev/null
        if [[ "${?}" -ne 0 ]]
        then
          echo "Could not create ${ARCHIVE_FILE}." >&2
          exit 1
        fi
      else
        echo "${HOME_DIR} does not exist or is not a directory." >&2
        exit 1
      fi
    fi

    # Check if user account should be deleted or disabled
    if [[ "${DELETE}" = 'true' ]]
    then
      # Delete the user.
      userdel ${REMOVE_HOME_DIR} ${ACCOUNT}

      # Check to see if the userdel command succeeded
      if [[ "${?}" -ne 0 ]]
      then
        echo "The account ${ACCOUNT} was NOT deleted." >&2
        exit 1
      fi
      echo "The account ${ACCOUNT} was deleted."
    else
      # Disable user.
      chage -E 0 ${ACCOUNT}
      
      # Check to see if the chage command succeeded
      if [[ "${?}" -ne 0 ]]
      then
        echo "The account ${ACCOUNT} was NOT disabled." >&2
        exit 1
      fi
      echo "Disable the ${ACCOUNT} account."
    fi
  fi
done

exit 0
