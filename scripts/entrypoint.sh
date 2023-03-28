#!/bin/sh

set -e

# if squid_user isn't set
if [ -z "${squid_user}" ]; then
    squid_user="squid"
fi

# if log dir isn't set, setting the default one
if [ -z "${log_dir}" ]; then
    log_dir="/var/log/squid" 
fi

# if cache dir isn't set, setting the default one
if [ -z "${cache_dir}" ]; then
    cache_dir="/var/spool/squid" 
fi

# if exposed port isn't set
if [ -z "${squid_http_port}" ]; then
    squid_http_port=3128
fi

access_log="$log_dir/access.log"
cache_log="$log_dir/cache.log"
default_conf="/etc/squid/squid.conf"

# creating for initial access
touch "$access_log"
touch "$cache_log"


# creating log dir, changing permissions and changing ownership
create_log_dir() {
    mkdir -p "$log_dir"
    chmod -R 755 "$log_dir"
    chown -R "$squid_user":"$squid_user" "$log_dir"
}


# creating cache dir, changing permissions and changing ownership
create_cache_dir() {
    mkdir -p "$cache_dir"
    chmod -R 755 "$cache_dir"
    chown -R "$squid_user":"$squid_user" "$cache_dir"
}


create_log_dir

create_cache_dir


# if configuration location isn't set, setting the default one
if [ -z "${squid_configuration}" ]; then
    squid_configuration=$default_conf
fi

printf "The configuration is located at: %s \n\n" "$squid_configuration"

# displaying the config without the comments
grep -o '^[^#]*' "$squid_configuration"

echo "Initializing cache directory"

# create swap (cache) dir
squid -zN -f "$squid_configuration"

echo "Running the server now. "

# squid \
#  -f "$squid_configuration" \
#  -a "$squid_http_port" \  # This will produce error `FATAL: vector::_M_range_check: __n (which is 1) >= this->size() (which is 0)`
 

# start squid
# the default port (3128) is used for now, changing the environment variable won't change that
# this is because of the above error
squid -f "$squid_configuration"

# continue logging cache log and access log
exec tail -vf "$access_log" "$cache_log"     #       display the logs
