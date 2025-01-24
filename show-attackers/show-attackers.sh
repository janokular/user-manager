#!/bin/bash

# This script counts the number of failed loggin attemps by IP address
# If there are any IPs with over the LIMIT failures, display the count, IP, and location

LIMIT='10'
LOG_FILE="${1}"

# Make sure the file was supplied as an argument
if [[ ! -e "${LOG_FILE}" ]]
then
  echo "Cannot open log file ${LOG_FILE}" >&2
  exit 1
fi

# Display the header
# For CSV format change tabs for commas
echo -e 'Count:\tIP:\t\tLocation:'

# Loop through the list of failed attemps and corresponding IP addresses
grep Failed "${LOG_FILE}" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort | uniq -c | sort -rn | while read COUNT IP
do
  # If the number of failed attemps is greater than the limit, display count, IP, and location
  if [[ "${COUNT}" -gt "${LIMIT}" ]]
  then
    LOCATION=$(geoiplookup ${IP} | awk -F ', ' '{print $2}')
    echo -e "${COUNT}\t${IP}\t${LOCATION}"
  fi
done

exit 0
