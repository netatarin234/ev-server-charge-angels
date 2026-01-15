FROM mongo:6

ARG mongodb_name
ARG mongodb_user
ARG mongodb_home
ARG export_file
ENV mongodb_name=${mongodb_name}
ENV mongodb_user=${mongodb_user}
ENV mongodb_home=${mongodb_home}
ENV export_file=${export_file}

COPY initdb/*.js ./docker-entrypoint-initdb.d/
COPY initdb/*.sh ./docker-entrypoint-initdb.d/
RUN mkdir -p ${mongodb_home} && chown ${mongodb_user}:${mongodb_user} ${mongodb_home}
COPY initdb/${export_file} ${mongodb_home}
RUN chown ${mongodb_user}:${mongodb_user} ${mongodb_home}/${export_file}
RUN set -eux; \
  apt-get -y update; \
  apt-get -y install --no-install-recommends flip openssl unzip; \
  rm -rf /var/lib/apt/lists/*
RUN openssl rand -base64 756 > /etc/mongo-keyfile \
  && chown mongodb:mongodb /etc/mongo-keyfile \
  && chmod 600 /etc/mongo-keyfile
RUN flip -u ./docker-entrypoint-initdb.d/*.sh

CMD ["mongod", "--replSet", "rs0", "--keyFile", "/etc/mongo-keyfile"]
