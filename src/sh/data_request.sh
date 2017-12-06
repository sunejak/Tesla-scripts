#!/bin/bash
# Script to send a command towards a Tesla
#
# assumes that you have your keys in the keys.txt file
#
# Copyright Sune Jakobsson, 2017
#
# Inspired by https://timdorr.docs.apiary.io
#
if [[ $1 == "" ]] ; then
    echo "Usage: data_request.sh command"
    echo "where the command can be:"
    echo "charge_state"
    echo "climate_state"
    echo "drive_state"
    echo "vehicle_state"

    exit 1
fi

COMMAND=$1

source ./keys.txt
if [[ $? != 0 ]] ; then echo "Failed opening file with keys" ; exit 1
fi
URL=https://owner-api.teslamotors.com
OAUTH=/oauth/token

# Fetch the oauth token you need for later API calls.
response=$(curl -s -X POST -d "grant_type=password&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&email=${EMAIL}&password=${PASSW}" ${URL}${OAUTH})
if [[ $? != 0 ]] ; then echo "Failed getting oauth token" ; exit 1
fi
token=$(echo $response | jq '.access_token' | tr -d '"' )
if [[ "${token}" == null ]] ; then echo "ERROR, getting access Token, resulted in: ${response}" ; exit 1
fi

# Retrieve a list of your owned vehicles
inventory=$(curl -s --header "Authorization: Bearer ${token}" ${URL}/api/1/vehicles )
if [[ $? != 0 ]] ; then echo "Failed getting inventory" ; exit 1
fi
vehicles=$(echo ${inventory} | jq '.response' )
first=$(echo ${vehicles} | jq '.[0]' )
id=$(echo ${first} | jq '.id_s' | tr -d '"' )
if [[ ${id} == '' ]] ; then exit 1
fi

# Send command
heat=$(curl -s --header "Authorization: Bearer ${token}" ${URL}/api/1/vehicles/${id}/data_request/${COMMAND} )
if [[ $? != 0 ]] ; then echo "Failed running command ${COMMAND}" ; exit 1
fi

# Show the result as pretty printed JSON
echo ${heat} | jq '.'
