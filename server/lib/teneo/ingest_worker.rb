# frozen_string_literal: true

require 'teneo-data_model'
require 'teneo-ingester'

module Teneo
  module IngestWorker
    ROOT_DIR = File.expand_path('../..' , __dir__)
    RAKEFILE = File.join(File.expand_path(__dir__), 'ingest_worker', 'rake', 'Rakefile')

    autoload :App, 'teneo/ingest_worker/app'
    autoload :Worker, 'teneo/ingest_worker/worker'

    module Helpers
      autoload :Workers, 'teneo/ingest_worker/helpers/workers'
    end

  end
end