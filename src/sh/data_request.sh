#!/bin/bash
# Script to send commands towards a Tesla
# Copyright Sune Jakobsson, 2017
#
# Inspired by https://timdorr.docs.apiary.io
#
if [[ $1 == "" ]] ; then
    echo "Usage: data_request.sh email password command"
    echo "where the command can be:"
    echo "charge_state"
    echo "climate_state"
    echo "drive_state"
    echo "vehicle_state"

    exit 1
fi
EMAIL=$1

if [[ $2 == "" ]] ; then
    echo "Usage: data_request.sh email password command"
    exit 1
fi
PASSWORD=$2

if [[ $3 == "" ]] ; then
    echo "Usage: data_request.sh email password command"
    exit 1
fi
COMMAND=$3

source ./keys.txt
if [[ $? != 0 ]] ; then echo "Failed opening file with oauth keys" ; exit 1
fi
URL=https://owner-api.teslamotors.com
OAUTH=/oauth/token

# Fetch the oauth token you need for later API calls.
response=$(curl -s -X POST -d "grant_type=password&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&email=${EMAIL}&password=${PASSWORD}" ${URL}${OAUTH})
if [[ $? != 0 ]] ; then echo "Failed getting oauth token" ; exit 1
fi
token=$(echo $response | jq '.access_token' | tr -d '"' )
if [[ ${token} == '' ]] ; then echo ${COMMAND} could not be run ; exit 1
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
