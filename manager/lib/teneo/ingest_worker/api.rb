require_relative 'api/workers'

module Teneo
  module IngestWorker
    class App < Roda

      plugin :hash_routes

      hash_branch 'api' do |r|

        r.halt 406, 'Unsupported Accept header value' unless r.headers['Accept'] =~ %r{^application/json}

        r.halt 405, 'Unsupported Content-Type header value' unless r.get? || r.delete? ||
            r.headers['Content-Type'] =~ %r{^application/json}

        @api_key = r.headers['ApiKey']

        # TODO: replace with key mechanism
        # Q: how to get and validate key
        # Need to extract user from key -> JWT?
=begin

        # @return [Teneoo::IngestServer::Accout]
        def current_user
          @current_user ||= Teneo::DataModel::User.find_by(uuid: session[:user_id])
        end

        r.halt 401 unless current_user
=end

        r.hash_routes :api

        r.is do
          'IngestWorker API v1.0'
        end
      end

    end
  end
end