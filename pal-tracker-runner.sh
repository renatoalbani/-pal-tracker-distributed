#/bin/sh

set -x

export PROTO=https://

#API ENDPOINTS
export TIMESHEETS_APP_URL=timesheets-pal-renato-victor.apps.evans.pal.pivotal.io
export REGISTRATION_APP_URL=registration-pal-renato-victor.apps.evans.pal.pivotal.io
export BACKLOG_APP_URL=backlog-pal-renato-victor.apps.evans.pal.pivotal.io
export ALLOCATIONS_APP_URL=allocations-pal-renato-victor.apps.evans.pal.pivotal.io

#TODO: CHANGE TO CF CLI TOOL COMMANDS
export UAA_ENDPOINT=${PROTO}login.sys.evans.pal.pivotal.io
export UAA_CLIENT_ID=f2c5bee2-bba6-40ac-a198-71fd67720775
export UAA_CLIENT_SECRET=163dbca3-1049-4ca4-8ea3-e2a583154e08
export RAND=$(openssl rand -base64 14)
export USER_NAME="Ney_"$RAND

#ENVIRONMENT
export ENV=$1

if [ "${ENV}" == 'dev' ] 
then

 PROTO=http://
 TIMESHEETS_APP_URL=localhost:8084
 REGISTRATION_APP_URL=localhost:8083
 BACKLOG_APP_URL=localhost:8082
 ALLOCATIONS_APP_URL=localhost:8081
 UAA_ENDPOINT=${PROTO}localhost:8999
 UAA_CLIENT_ID=tracker-client
 UAA_CLIENT_SECRET=supersecret

fi

#GET TOKEN
export ACCESS_TOKEN=$(curl -k "${UAA_ENDPOINT}/oauth/token" -u "${UAA_CLIENT_ID}:${UAA_CLIENT_SECRET}" -X POST -H 'Accept: application/json' -H 'Content-Type: application/x-www-form-urlencoded' -d 'grant_type=client_credentials&response_type=token' |jq -r '.access_token')

function testAll(){

#DEFINING USER
export USER_ID=$(curl -XPOST -H"Content-Type: application/json" -H"Authorization: Bearer ${ACCESS_TOKEN}" ${PROTO}${REGISTRATION_APP_URL}/registration -d"{\"name\": \"${USER_NAME}\"}" |jq -r '.id') 
export ACCOUNT_ID=$(curl -H"Content-Type: application/json" -H"Authorization: Bearer ${ACCESS_TOKEN}" ${PROTO}${REGISTRATION_APP_URL}/accounts?ownerId=${USER_ID} |jq -r '.[].id')

#CREATE PROJECTS
export PROJECT_A_ID=$(curl -XPOST -H"Content-Type: application/json" -H"Authorization: Bearer ${ACCESS_TOKEN}" ${PROTO}${REGISTRATION_APP_URL}/projects -d"{\"name\": \"Project_A_${RAND}\", \"accountId\": \"${ACCOUNT_ID}\"}" |jq -r '.id')

export PROJECT_B_ID=$(curl -XPOST -H"Content-Type: application/json" -H"Authorization: Bearer ${ACCESS_TOKEN}" ${PROTO}${REGISTRATION_APP_URL}/projects -d"{\"name\": \"Project_B_${RAND}\", \"accountId\": \"${ACCOUNT_ID}\"}" |jq -r '.id')

#ALLOCATIONS
#PROJECT A
export ALLOCATION_ID=$(curl -XPOST -H"Content-Type: application/json" -H"Authorization: Bearer ${ACCESS_TOKEN}" ${PROTO}${ALLOCATIONS_APP_URL}/allocations/ -d"{\"projectId\": \"${PROJECT_A_ID}\", \"userId\": \"${USER_ID}\", \"firstDay\": \"2015-05-17\", \"lastDay\": \"2015-05-18\"}" |jq -r '.id') 

}

function getLastFive(){
 curl -i -XPOST -H"Content-Type: application/json" -H"Authorization: Bearer ${ACCESS_TOKEN}" ${PROTO}${BACKLOG_APP_URL}/actuator/refresh
 testAll
 for conta in {1..6};
 do
  curl -i -XPOST -H"Content-Type: application/json" -H"Authorization: Bearer ${ACCESS_TOKEN}" ${PROTO}${BACKLOG_APP_URL}/stories -d"{\"projectId\": ${PROJECT_A_ID}, \"name\": \"Find ${conta} some reeds ${RAND}\"}"
 done

  curl -i -H"Content-Type: application/json" -H"Authorization: Bearer ${ACCESS_TOKEN}" ${PROTO}${BACKLOG_APP_URL}/stories/last
}

if [ $2 == 'lastFive' ]
then
   getLastFive
else
   testAll
fi
