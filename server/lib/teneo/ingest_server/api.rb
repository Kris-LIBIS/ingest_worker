require_relative 'api/organization'
require_relative 'api/agreement'
require_relative 'api/workflow'
require_relative 'api/package'
require_relative 'api/run'

module Teneo
  module IngestServer
    class App < Roda

      plugin :hash_routes

      hash_branch 'api' do |r|

        r.halt 406, 'Unsupported Accept header value' unless r.headers['Accept'] =~ %r{^application/json}
        r.halt 405, 'Unsupported Content-Type header value' unless r.headers['Content-Type'] =~ %r{^application/json}

        r.post 'login' do
          account = Account.authenticate(r.params['email'], r.params['password'])
          user = account&.user
          r.halt 401 unless user
          session.clear
          session[:user_id] = user.uuid
          {
              name: user.name,
              orgs: user.member_organizations.each_with_object({}) do |(org, roles), hash|
                hash[org.name] = { id: org.id, roles: roles }
              end
          }
        end

        # @return [Teneoo::IngestServer::Accout]
        def current_user
          @current_user ||= Teneo::DataModel::User.find_by(uuid: session[:user_id])
        end

        r.delete 'logout' do
          user = current_user
          session.clear
          {
              message: user ? "User #{user.name} logged out" : "Not logged in"
          }
        end

        r.halt 401 unless current_user

        r.on 'user' do

          r.is do
            { first_name: current_user.first_name, last_name: current_user.last_name, email: current_user.email }
          end

        end

        r.hash_routes :api

      end
    end
  end
end
