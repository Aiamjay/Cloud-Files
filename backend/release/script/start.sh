cd ..
BIN_DIR=$(pwd)
DEPLOY_DIR=${BIN_DIR}
echo "deploy dir ${DEPLOY_DIR}"

echo "-------- SPRING_PROFILES_ACTIVE --------"
echo "--------start app ${DEPLOY_DIR}--------"
PARENT_DIR=$(dirname "$PWD")
CONF_DIR=$DEPLOY_DIR/conf
LIB_DIR=$DEPLOY_DIR/lib
echo "parent dir ${PARENT_DIR}"
echo "config dir ${CONF_DIR}"
SERVER_NAME=$(cat ${CONF_DIR}/application.properties | grep -w "spring.application.name" | grep -v "#" | awk -F=  'NR==1{print $2}')
SERVER_PORT=$(cat ${CONF_DIR}/application.properties | grep -w "server.port" | grep -v "#" | awk -F=  'NR==1{print $2}')


LOG_PATH=${DEPLOY_DIR}/log
echo ${DEPLOY_DIR}
STDOUT_FILE=${LOG_PATH}/nohup.out
echo "std outfile ${STDOUT_FILE}"
JAVA_HOME=$(which java)
if [ "${JAVA_HOME}" != "" ] ; then
	export JAVA_HOME
	export PATH=$PATH:JAVA_HOME/bin
	echo JAVA_HOME:${JAVA_HOME}
else
  echo "JAVA_HOME not set!!!"
  exit 1
fi

USER_VMARGS="-D64 -server -Xmx1g -Xms1g -Xmn521m -Xss256k "

JMX_PORT=""
JAVA_JMX_OPTS=""
if [ "${JMX_PORT}" != "" ] ; then
	JAVA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=${JMX_PORT} "
fi

JAVA_OPTS=""

PIDS=`ps -ef | grep java | grep "$CONF_DIR" |awk '{print $2}'`
if [ -n "$PIDS" ]; then
    echo "ERROR: The $SERVER_NAME already started!"
    echo "PID: $PIDS"
    exit 1
fi

if [ -n "$SERVER_PORT" ]; then
    SERVER_PORT_COUNT=`netstat -tln | grep $SERVER_PORT | wc -l`
    if [ $SERVER_PORT_COUNT -gt 0 ]; then
        echo "ERROR: The $SERVER_NAME port $SERVER_PORT already used!"
        exit 1
    fi
fi

LIB_JARS=${DEPLOY_DIR}/lib/*

echo "Using LIB_JARS: $LIB_JARS"
echo "Using CONF_DIR: $CONF_DIR"
echo "Using TRACE_LIB_JARS: $TRACE_LIB_JARS"
CLASSPATH=".:$CONF_DIR:$LIB_JARS:$TRACE_LIB_JARS"

EXEC_CMDLINE="${JAVA_HOME} -classpath ${CLASSPATH} ${TRACE_OPTS} ${USER_VMARGS} ${GC_OPTS} ${JAVA_JMX_OPTS} ${JAVA_DEBUG} ${JAVA_OPTS} com.example.cloud.CloudFileApplication"

echo "Start app command line: ${EXEC_CMDLINE}" >> $STDOUT_FILE
echo "Starting $SERVER_NAME ..."
echo "server port ${SERVER_PORT}"

nohup ${EXEC_CMDLINE} >> $STDOUT_FILE 2>&1 &

COUNT=0
while [ $COUNT -lt 120 ]; do
    echo -e ".\c"
    sleep 1
    IS_LISTENED=`netstat -an | grep -w LISTEN | grep -w $SERVER_PORT`
    let COUNT++
    if [ -n "$IS_LISTENED" ]; then
        COUNT=1000
    fi
done

echo "Console File: $STDOUT_FILE"
echo "--------start app $SERVER_NAME on $(uname -n) (pid=$$)--------"