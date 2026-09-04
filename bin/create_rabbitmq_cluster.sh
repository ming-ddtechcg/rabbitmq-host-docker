#!/bin/sh

RABBITMQ_HOME=""
RABBITMQ_ETC_HOME=""

EXECUTION_DIR=`dirname $0`

PRG="$0"



#
# updates environment directory setup
#
updateEnvironmentDirectory()
{
    if [ "${EXECUTION_DIR}" = "." ]
    then
        EXECUTION_DIR=`pwd`
    fi

    CURRENT_PWD="${EXECUTION_DIR}"
    while true
    do
        if [ -s "${CURRENT_PWD}/.root-rabbitmq.txt" ]
        then
            RABBITMQ_HOME="${CURRENT_PWD}"
            RABBITMQ_ETC_HOME="${RABBITMQ_HOME}/etc"
            break
        fi

        CURRENT_PWD=`dirname ${CURRENT_PWD}`
    done
}



#
# lanuchs a RabbitMQ instance
#
launchRabbitMqInstance()
{
    RABBITMQ_HOST="$1"
    RABBITMQ_PORT="$2"

    docker run -d --rm --net ${RABBITMQ_NETWORK_NAME} \
        -v ${RABBITMQ_ETC_HOME}/config/${RABBITMQ_HOST}/:/config/ \
        -e RABBITMQ_CONFIG_FILE=/config/rabbitmq \
        -e RABBITMQ_ERLANG_COOKIE="${RABBITMQ_ERLANG_COOKIE}" \
        --hostname ${RABBITMQ_HOST} \
        --name ${RABBITMQ_HOST} \
        -p ${RABBITMQ_PORT}:15672 \
        ${RABBITMQ_CONTAINER_IMAGE}
}



#
# enables the RabbitMQ federation
#
enableRqbbitMqFederation()
{
    RABBITMQ_HOST="$1"

    docker exec -it ${RABBITMQ_HOST} rabbitmq-plugins enable rabbitmq_federation
}



#
# starts from here
#

updateEnvironmentDirectory

. ${RABBITMQ_ETC_HOME}/rabbitmq_settings.sh

# creates the rabbitmq network
echo ""
echo "create RabbitMQ network: ${RABBITMQ_NETWORK_NAME}"
docker network create ${RABBITMQ_NETWORK_NAME}


INSTANCE_LIST=""

for each_instance_info in `echo ${RABBITMQ_INSTANCES} | sed -e 's|~| |g'`
do
    if [ "${each_instance_info}" = "" ]
    then
        continue
    fi

    INSTANCE_NAME=`echo ${each_instance_info} | cut -d':' -f1`
    INSTANCE_PORT=`echo ${each_instance_info} | cut -d':' -f2`

    INSTANCE_LIST="${INSTANCE_LIST} ${INSTANCE_NAME}" 

    echo ""
    echo "create a RabbitMQ instance: ${INSTANCE_NAME}"
    launchRabbitMqInstance "${INSTANCE_NAME}" "${INSTANCE_PORT}"
done

for each_instance in ${INSTANCE_LIST}
do
    if [ "${each_instance}" = "" ]
    then
        continue
    fi

    enableRqbbitMqFederation "${each_instance}" 
done

exit 0

