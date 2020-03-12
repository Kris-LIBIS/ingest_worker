# frozen_string_literal: true

require 'teneo-ingest_server'
require 'bcrypt'

ON_TTY = false
# dir = File.join Teneo::DataModel.root, 'db', 'seeds'
# Teneo::DataModel::SeedLoader.new(dir)
dir = File.join Teneo::Ingester::ROOT_DIR, 'db', 'seeds'
Teneo::Ingester::SeedLoader.new(dir, tty: ON_TTY)

dir = File.join __dir__, 'seeds'
Teneo::IngestServer::SeedLoader.new(dir, tty: ON_TTY)

dir = File.join __dir__, 'seeds', 'code_tables'
Teneo::IngestServer::SeedLoader.new(dir, tty: ON_TTY)

dir = File.join __dir__, 'seeds', 'workflows'
Teneo::IngestServer::SeedLoader.new(dir, tty: ON_TTY)

dir = File.join __dir__, 'seeds', 'kadoc'
Teneo::IngestServer::SeedLoader.new(dir, tty: ON_TTY)

Teneo::IngestServer::Account.create_with(password: 'abc123').find_or_create_by(email_id: 'admin@libis.be')
Teneo::IngestServer::Account.create_with(password: '123abc').find_or_create_by(email_id: 'info@kadoc.be')
