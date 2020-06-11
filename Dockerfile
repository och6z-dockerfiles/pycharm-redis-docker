ARG PYTHON_VERSION

FROM python:${PYTHON_VERSION}

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    gcc \
    libc6-dev \
    make \
    libxtst-dev \
    libxext-dev \
    libxrender-dev \
    libfreetype6-dev \
    libfontconfig1 \
    libgtk2.0-0 \
    libxslt1.1 \
    libxxf86vm1 \
    && apt-get purge -y && apt-get autoremove -y && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*

ARG REDIS_VERSION
ARG REDIS_DOWNLOAD_URL=download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz
ENV REDIS_DOWNLOAD_URL ${REDIS_DOWNLOAD_URL}

RUN wget --output-document=redis.tar.gz ${REDIS_DOWNLOAD_URL} \
    && mkdir --parents /usr/src/redis \
    && tar -xzf redis.tar.gz --directory=/usr/src/redis --strip-components=1 \
    && rm redis.tar.gz \
    && make --directory=/usr/src/redis -j "$(nproc)" all \
    && make --directory=/usr/src/redis install \
    && REDIS_PORT=6379 \
       REDIS_CONFIG_FILE=/etc/redis/6379.conf \
       REDIS_LOG_FILE=/var/log/redis_6379.log \
       REDIS_DATA_DIR=/var/lib/redis/6379 \
       REDIS_EXECUTABLE=`command -v redis-server` /usr/src/redis/utils/install_server.sh

ARG PYCHARM_VERSION
ARG PYCHARM_DOWNLOAD_URL=https://download-cf.jetbrains.com/python/pycharm-community-${PYCHARM_VERSION}.tar.gz
ENV PYCHARM_DOWNLOAD_URL ${PYCHARM_DOWNLOAD_URL}

RUN wget --output-document=pycharm-community.tar.gz ${PYCHARM_DOWNLOAD_URL} \
    && mkdir --parents /opt/pycharm-community \
    && tar -xzf pycharm-community.tar.gz --directory=/opt/pycharm-community --strip-components=1 \
    && rm pycharm-community.tar.gz \
    && apt-get purge -y && apt-get autoremove -y && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/sh", "-c"]

CMD ["/opt/pycharm-community/bin/pycharm.sh"]
