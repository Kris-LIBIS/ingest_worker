# frozen_string_literal: true
require 'dotenv'
#noinspection RubyArgCount
Dotenv.load

require_relative 'config/environment'

run Teneo::IngestWorker::App.app.freeze
