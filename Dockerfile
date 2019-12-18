FROM dxdx/php-laravel-basic:v0.0.1
WORKDIR /app
USER root
RUN sed -is "s/memory_limit = 128M/memory_limit = 512M/gi" /opt/bitnami/php/lib/php.ini
RUN sed -is "s/memory_limit = 128M/memory_limit = 512M/gi" /opt/bitnami/php/etc/php.ini
# Uncomment if need easier debug options
#RUN apt-get update \
#    && apt-get install -y iputils-ping vim telnet redis-server default-mysql-client curl \
#    && rm -rf /var/lib/apt/lists/*
ADD entrypoint.sh  ./
ADD debug.php  ./
RUN chmod +x entrypoint.sh
USER www-data
ENV fprocess="/app/entrypoint.sh php artisan serve --host=0.0.0.0 --port=8090"
ENV write_debug="true"
ENV mode=http
ENV upstream_url=http://127.0.0.1:8090
ENV port=8080
# Hard timeout for process exec'd for each incoming request (in seconds). Disabled if set to 0
ENV exec_timeout=120
# HTTP timeout for reading the payload from the client caller (in seconds)
ENV read_timeout=90
# HTTP timeout for writing a response body from your function (in seconds)
ENV write_timeout=90
# True by default - combines stdout/stderr in function response, when set to false stderr is written to the container logs and stdout is used for function response
ENV combine_output="true"
# Limit the maximum number of requests in flight
# max_inflight=1
HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1
CMD ["fwatchdog"]
