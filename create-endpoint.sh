#/bin/bash
TEMP_SITE=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')


show_help () {
    echo "-u public url"
    echo "-p local port"
    echo "-h user@host"
}

while getopts "p:u:h:" opt; do
  case "$opt" in
    p)  LOCAL_PORT=$OPTARG
      ;;
    u)  PUBLIC_URL=$OPTARG
      ;;
    h)  HOST=$OPTARG
      ;;
    *)
      show_help
      exit 0
      ;;
  esac
done

shift $((OPTIND-1))

if [ -z "${LOCAL_PORT}" ] || [ -z "${PUBLIC_URL}" ] || [ -z "${HOST}" ]; then
    show_help
    exit 1
fi

echo "Mapping public endpoint ${TEMP_SITE}.${PUBLIC_URL} to local port ${LOCAL_PORT}"

#create temp folder if does not exist
if [ ! -d tmp ]; then
  mkdir -p tmp;
fi

# Find open port
PROXY_PORT=$(ssh "${HOST}" "comm -23 <(seq 49152 65535 | sort) <(ss -Htan | awk '{print $4}' | cut -d':' -f2 | sort -u) | shuf | head -n 1")
echo "Selectd proxy port is ${PROXY_PORT}"

# make config
sed "s,<public_url>,${TEMP_SITE}.${PUBLIC_URL},g;s,<port>,${PROXY_PORT},g" nginx-sites/tunnel.template > "./tmp/${TEMP_SITE}"

trap 'rm -rf -- "./tmp/$TEMP_SITE";' EXIT
# push config
scp -q "./tmp/${TEMP_SITE}" "${HOST}:/etc/nginx/sites-enabled/"

echo http://${TEMP_SITE}.${PUBLIC_URL}
ssh -R ${PROXY_PORT}:127.0.0.1:${LOCAL_PORT} "${HOST}" "nginx -s reload; trap 'rm -rf /etc/nginx/sites-enabled/${TEMP_SITE}; nginx -s reload' EXIT; echo 'Press enter to close the ${TEMP_SITE}.${PUBLIC_URL} tunnel to local port ${LOCAL_PORT}'; read -p ''"

