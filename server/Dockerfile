FROM libis/teneo-ruby:latest

# Create application user
ARG APP_USER=teneo
ARG UID=1000
ARG GID=1000
ARG HOME_DIR=/${APP_USER}

RUN groupadd --gid ${GID} ${APP_USER}
RUN useradd --home-dir ${HOME_DIR} --create-home --no-log-init --uid ${UID} --gid ${GID} ${APP_USER}

# Copy application data
COPY . ${HOME_DIR}
RUN chown -R ${APP_USER}:${APP_USER} ${HOME_DIR}

# Switch to application user
USER ${APP_USER}
WORKDIR ${HOME_DIR}

# Application configuration
ARG API_PORT=3000
EXPOSE $API_PORT

# Run application
CMD ["puma", "-p", "$API_PORT", "-e", "$RUBY_ENV", "--log-requests"]
