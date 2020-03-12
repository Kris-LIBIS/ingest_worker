# frozen_string_literal: true

require 'teneo-data_model'
require 'teneo-ingester'

module Teneo
  module IngestServer
    ROOT_DIR = File.expand_path('../..', __dir__)
    RAKEFILE = File.join(File.expand_path(__dir__), 'ingest_server', 'rake', 'Rakefile')

    autoload :Account, 'teneo/ingest_server/account'
    autoload :App, 'teneo/ingest_server/app'
    autoload :SeedLoader, 'teneo/ingest_server/seed_loader'

    def self.root
      File.expand_path('../..', __dir__)
    end

    def self.migrations_path
      Teneo::Ingester.migrations_path << File.join(root, 'db', 'migrate')
    end

    def self.dba_migrations_path
      Teneo::Ingester.dba_migrations_path
    end

  end
end