# frozen_string_literal: true
require 'dotenv'
#noinspection RubyArgCount
Dotenv.load

require_relative 'config/environment'

#require 'warden/jwt_auth'
#
#use Warden::Manager do |manager|
#  manager.default_strategies(:jwt)
#  manager.failure_app = ->(_env) { [401, {}, ['unauthorized']] }
#end
#
#use Warden::JWTAuth::Middleware

run Teneo::IngestServer::App.app.freeze
