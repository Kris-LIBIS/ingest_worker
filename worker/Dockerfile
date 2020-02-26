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
ENV LD_LIBRARY_PATH /teneo/oracle/instantclient_12_2
RUN ["bundle", "install"]

CMD ["bundle", "exec", "sidekiq", "-C", "./config/sidekiq.yml", "-r", "run.rb" ]
