#!/bin/bash
# Script to send commands towards a Tesla
# Copyright Sune Jakobsson, 2017
#
# https://timdorr.docs.apiary.io
#
if [[ $1 == "" ]] ; then
    echo "Usage: send_command.sh email password command"
    echo "Where command can be:"
    echo "auto_conditioning_start"
    echo "auto_conditioning_stop"
    exit 1
fi
EMAIL=$1

if [[ $2 == "" ]] ; then
    echo "Usage: send_command.sh email password command"
    exit 1
fi
PASSWORD=$2

if [[ $3 == "" ]] ; then
    echo "Usage: send_command.sh email password command"
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
if [[ $? != 0 ]] ; then exit 1
fi
token=$(echo $response | jq '.access_token' | tr -d '"' )
if [[ ${token} == '' ]] ; then echo ${COMMAND} could not be run ; exit 1
fi

# Retrive a list of your owned vehicles
inventory=$(curl -s --header "Authorization: Bearer ${token}" ${URL}/api/1/vehicles )
if [[ $? != 0 ]] ; then exit 1
fi
vehicles=$(echo ${inventory} | jq '.response' )
first=$(echo ${vehicles} | jq '.[0]' )
id=$(echo ${first} | jq '.id_s' | tr -d '"' )
if [[ ${id} == '' ]] ; then exit 1
fi

# Turn on heat
heat=$(curl -s -X POST --header "Authorization: Bearer ${token}" ${URL}/api/1/vehicles/${id}/command/${COMMAND} )
if [[ $? != 0 ]] ; then exit 1
fi
echo ${heat} | jq '.'
