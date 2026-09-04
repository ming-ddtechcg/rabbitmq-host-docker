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
# starts from here
#

updateEnvironmentDirectory

. ${RABBITMQ_ETC_HOME}/rabbitmq_settings.sh


for each_instance_info in `echo ${RABBITMQ_INSTANCES} | sed -e 's|~| |g'`
do
    if [ "${each_instance_info}" = "" ]
    then
        continue
    fi

    INSTANCE_NAME=`echo ${each_instance_info} | cut -d':' -f1`

    echo ""
    echo "tears down a RabbitMQ instance: ${INSTANCE_NAME}"
    docker rm -f "${INSTANCE_NAME}"
done

echo ""
echo "tears down RabbitMQ network: ${RABBITMQ_NETWORK_NAME}"
docker network rm -f ${RABBITMQ_NETWORK_NAME}

exit 0

