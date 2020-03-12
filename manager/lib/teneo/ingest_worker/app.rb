# frozen_string_literal: true

require 'roda'
require 'awesome_print'
require 'ostruct'
require 'json'

require_relative 'api'

module Teneo
  module IngestWorker

    class App < Roda

      plugin :public, root: 'static'
      plugin :empty_root
      plugin :heartbeat, path: '/status'
      plugin :json
      plugin :json_parser
      plugin :all_verbs
      plugin :halt
      plugin :request_headers

      plugin :hash_routes

      route do |r|
        r.hash_routes
      end

    end

  end
end
