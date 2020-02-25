require 'docker-api'
require 'logger'
# Docker::API_VERSION = '1.40'
Docker.options = {debug_request: true, debug_response: true}
Docker.logger = Logger.new(STDOUT)
