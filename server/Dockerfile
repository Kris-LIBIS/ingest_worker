FROM libis/teneo-ruby:latest

# Create application user
ARG APP_USER=teneo
ARG UID=1000
ARG GID=1000
ARG HOME_DIR=/${APP_USER}

RUN groupadd --gid ${GID} ${APP_USER}
RUN useradd --home-dir ${HOME_DIR} --create-home --no-log-init --uid ${UID} --gid ${GID} ${APP_USER}

# Switch to application user
USER ${APP_USER}
WORKDIR ${HOME_DIR}

# Copy application data
COPY Gemfile server.sh config.ru Rakefile config db lib static .

# Application configuration
ARG API_PORT=3000
EXPOSE $API_PORT

# Run application
CMD ["server.sh"]
