#escape=\

# The linux distribution and version to use
ARG distro="alpine"
ARG distro_version=3.17
FROM $distro:$distro_version

# some labels
LABEL Author="Bishal Neupane"
LABEL version="0.0.1"

# host machine locations
ARG squid_configuration_host="./configs/squid_alpine.conf"
ARG access_control_configuration_host="./configs/access_control.conf"
ARG entrypoint_script_host="./scripts/entrypoint.sh"

# environment variables
ENV squid_configuration="/etc/squid/squid_new.conf"
ENV access_control_configuration="/etc/squid/access_control.conf"
# Remember to change exposed port manually in the squid configuration file
ENV squid_http_port=3128
# Cache options
ENV cache_dir_fs="ufs"
ENV cache_dir="/var/spool/squid"
# Size in MB
ENV cache_max_size=1000
# volume for the cache
VOLUME [ "/var/spool/squid" ]


ENV entrypoint_script="/opt/entrypoint.sh"

# accessing of directories will be through this user
ENV squid_user="squid" 

# The squid package
RUN apk add --no-cache squid

# Copying the squid configuration from the host
COPY $squid_configuration_host $squid_configuration
RUN echo "Using configuration under $squid_configuration_host." \
    && echo "The configuration is available at ${squid_configuration} in the container"

# Copying the access control configuration from the host
COPY $access_control_configuration_host $access_control_configuration
RUN echo "Using configuration under $access_control_configuration_host." \
    && echo "The configuration is available at ${access_control_configuration} in the container"

# inserting the access control rules
# Assumes, the access control rules are under
    # INSERT YOUR OWN RULE(S) HERE TO ALLOW ACCESS FROM YOUR CLIENTS
# in the squid_*.conf
RUN sed -i -e "/# INSERT YOUR OWN RULE(S) HERE TO ALLOW ACCESS FROM YOUR CLIENTS/r ${access_control_configuration}" ${squid_configuration}

# Opening this ports ( allowing incoming connections )
# The exposed port doesn't correspond to that used in the configuration file (if changed here)
# this is because of the error which is mentioned in the entrypoint.sh script
EXPOSE $squid_http_port

# changing the http_port in the squid config
# this is a bit hacky
RUN sed -i -e "s/http_port 3128/http_port ${squid_http_port}/g" "$squid_configuration"

# setting the cache dir
RUN echo -e "cache_dir ${cache_dir_fs} ${cache_dir} ${cache_max_size} 16 256\n" >> ${squid_configuration}

# copying the entrypoint script
COPY "$entrypoint_script_host" "$entrypoint_script"
RUN chmod -R 755 "$entrypoint_script" \
    && chown -R "${squid_user}":"${squid_user}" "${entrypoint_script}"

ENTRYPOINT ${entrypoint_script} 
