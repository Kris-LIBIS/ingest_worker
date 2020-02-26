module Teneo
  module IngestWorker
    class App < Roda

      # include Teneo::IngestWorker::Helpers::Workers

      plugin :hash_routes

      hash_branch :api, 'workers' do |r|

        # Get list of workers
        r.is do
          Teneo::IngestWorker::Worker.list
        end

        r.post 'build' do
          r.halt 500, [{ success: false, message: 'Docker image build failed' }] unless Teneo::IngestWorker::Worker.build!
          { success: true, message: "Image #{Teneo::IngestWorker::Worker::IMAGE} created" }
        end

        # Worker name as part of path
        r.on String do |name|

          worker = Teneo::IngestWorker::Worker.new(name: name)

          # Create worker with given name
          r.post do
            !worker.exist? || r.halt(409, [{ success: false, message: "Worker #{name} already exists" }])
            worker.start!
            { success: true, message: "Worker #{name} created and started" }
          end

          # Actions below require container exists
          worker.exist? || r.halt(404, [{ success: false, message: "Worker #{name} not found" }])

          # Stop and remove the worker
          r.delete do
            worker.stop!
            { success: true, message: "Worker #{name} deleted" }
          end

          r.on 'logs' do
            worker.logs!
          end

          r.on 'processes' do
            worker.processes!
          end

          # Get worker information
          r.is do
            worker.info!
          end

        end

      rescue RuntimeError => e
        r.halt 500, [{ success: false, message: e.message, backtrace: e.backtrace }]
      end

    end
  end
end