# frozen_string_literal: true

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'teneo-ingest_worker'

#noinspection RubyResolve
Dir[File.join(File.expand_path('initializers', __dir__), '*.rb')].each { |f| require f }
