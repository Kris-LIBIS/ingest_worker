FROM ruby:slim

ARG RUBY_ENV=production
ARG HOME_DIR=/teneo

ARG UID=1000
ARG GID=1000

RUN addgroup --quiet --gid ${GID} teneo
RUN adduser --quiet --disabled-password --home ${HOME_DIR} --uid ${UID} --gid ${GID} --gecos "" teneo

ADD . /teneo

USER teneo
WORKDIR ${HOME_DIR}
ENV RUBY_ENV $RUBY_ENV

CMD ["bundle", "exec", "puma"]