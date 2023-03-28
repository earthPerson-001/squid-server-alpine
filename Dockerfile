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
ARG entrypoint_script_host="./scripts/entrypoint.sh"

# environment variables
ENV squid_configuration="/etc/squid/squid_new.conf"
# Remember to change exposed port manually in the squid configuration file
ENV squid_http_port=3128

ENV entrypoint_script="/opt/entrypoint.sh"

# accessing of directories will be through this user
ENV squid_user="squid" 

# The squid package
RUN apk add --no-cache squid

# Copying the squid configuration from the host
COPY $squid_configuration_host $squid_configuration
RUN echo "Using configuration under $squid_configuration_host." \
    && echo "The configuration is available at ${squid_configuration} in the container"

# Opening this ports ( allowing incoming connections )
# The exposed port doesn't correspond to that used in the configuration file (if changed here)
# this is because of the error which is mentioned in the entrypoint.sh script
EXPOSE $squid_http_port

# changing the http_port in the squid config
# this is a bit hacky
RUN sed -i -e "s/http_port 3128/http_port ${squid_http_port}/g" "$squid_configuration"

# copying the entrypoint script
COPY "$entrypoint_script_host" "$entrypoint_script"
RUN chmod -R 755 "$entrypoint_script" \
    && chown -R "${squid_user}":"${squid_user}" "${entrypoint_script}"

ENTRYPOINT ${entrypoint_script} 
