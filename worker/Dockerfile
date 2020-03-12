ARG RUBY_VERSION=2.6
FROM ruby:$RUBY_VERSION-slim-buster

# Silence apt
RUN dpkg-reconfigure debconf --frontend=noninteractive

# Install common packages
RUN apt-get update -qq \
    && apt-get install -qqy --no-install-recommends \
        build-essential \
        gnupg2 \
        curl \
        less \
        git \
        wget \
        libaio1 \
    && apt-get clean \
    && rm -fr /var/cache/apt/archives/* \
    && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp* \
    && truncate -s 0 /var/log/*log

ARG PG_VERSION=12

# Install PostgreSQL client
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/postgres.list \
    && apt-get update -qq \
    && apt-get install -qqy --no-install-recommends \
        libpq-dev \
        postgresql-client-$PG_VERSION \
    && apt-get clean \
    && rm -fr /var/cache/apt/archives/* \
    && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp* \
    && truncate -s 0 /var/log/*log

ARG BUNDLER_VERSION=2.1.4

# Upgrade RubyGems and install required Bundler version
RUN gem update --system && \
    gem install bundler:$BUNDLER_VERSION

# Create a directory for the app code
RUN mkdir -p /app

COPY . /app

WORKDIR /app

ENV LANG=C.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    LD_LIBRARY_PATH=/oracle-client \
    API_PORT=3000 \
    BUNDLE_PATH=/bundle-gems

VOLUME /oracle-client
VOLUME /bundle-gems

EXPOSE $API_PORT
CMD ["start.sh"]

FROM ruby:slim

RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends build-essential libpq-dev libaio1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG UID=1000
ARG GID=1000
ARG RUBY_ENV=production
ARG HOME_DIR=/teneo

RUN addgroup --quiet --gid ${GID} teneo
RUN adduser --quiet --disabled-password --home ${HOME_DIR} --uid ${UID} --gid ${GID} --gecos "" teneo

ADD . /teneo

USER teneo
WORKDIR ${HOME_DIR}
ENV RUBY_ENV $RUBY_ENV
ENV LD_LIBRARY_PATH /teneo/oracle/instantclient
RUN ["bundle", "install"]

CMD ["bundle", "exec", "sidekiq", "-C", "./config/sidekiq.yml", "-r", "run.rb" ]
