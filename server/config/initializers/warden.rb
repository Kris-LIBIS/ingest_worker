#require 'warden/jwt_auth'
#
#Warden::JWTAuth.configure do |config|
#  config.secret(File.read(File.expand_path('../../key.bin', __dir__), mode: 'rb'))
#  config.mappings = { default: Teneo::IngestServer::Account }
#  config.dispatch_requests = [['POST', %r{^/api/login$}]]
#  config.revocation_requests = [['DELETE', %r{^/api/logout$}]]
#  config.revocation_strategies = { default: Teneo::IngestServer::Account }
#end
