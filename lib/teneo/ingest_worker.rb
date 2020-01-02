# frozen_string_literal: true

require 'teneo-data_model'
require 'teneo-ingester'

module Teneo
  module IngestServer
    ROOT_DIR = File.expand_path('../..' , __dir__)
    RAKEFILE = File.join(File.expand_path(__dir__), 'ingest_worker', 'rake', 'Rakefile')

    autoload :Account, 'teneo/ingest_worker/account'
    autoload :App, 'teneo/ingest_worker/app'
    autoload :Queue, 'teneo/ingest_worker/queue'
    autoload :SeedLoader, 'teneo/ingest_worker/seed_loader'
    autoload :Work, 'teneo/ingest_worker/work'
    autoload :Worker, 'teneo/ingest_worker/worker'
    autoload :WorkStatus, 'teneo/ingest_worker/work_status'

  end
end