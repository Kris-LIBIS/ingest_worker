# frozen_string_literal: true

namespace :teneo do
  namespace :db do

    desc 'Drop the database'
    task drop: 'teneo:db:drop_schema' do
    end

    desc 'Create the database'
    task create: 'teneo:db:environment' do
      Rake::Task['teneo:db:create_schema'].invoke
    end

  end
end
