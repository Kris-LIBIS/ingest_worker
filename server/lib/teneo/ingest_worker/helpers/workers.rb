require 'docker-api'

module Teneo
  module IngestWorker
    module Helpers
      module Workers

        LABEL = 'be.libis.teneo.ingester.worker'.freeze
        IMAGE = 'ingest_worker:latest'.freeze

        def build_worker
          Docker::Image.build_from_dir('../worker',
                                       t: IMAGE,
                                       forcerm: true,
                                       labels: "{\"#{LABEL}\": \"\"}"
          )
        rescue Docker::Error::ClientError
          nil
        end

        def image_exist?
          Docker::Image.exist?(IMAGE)
        end

        def container_name(container)
          container.info['Labels'][LABEL]
        end

        def get_workers
          get_containers.map {|c| container_name(c)}.freeze
        end

        def get_containers
          Docker::Container.all(all: true, filters: '{"label" : ["be.libis.teneo.ingester.worker"]}')
        rescue Docker::Error::NotFoundError
          []
        end

        def get_worker(name)
          container = get_container(name)
          return nil unless container
          container_name(container)
        end

        def get_container(name)
          Docker::Container.get("ingest_worker.#{name}")
        rescue Docker::Error::NotFoundError
          nil
        end

        def create_worker(name)
          build_worker unless image_exist?
          container = get_container(name) ||
              Docker::Container.create(
                  name: "ingest_worker.#{name}",
                  'Image' => IMAGE,
                  'Env' => ["NAME=#{name}"],
                  'Labels' => { LABEL => name }
              )
          #noinspection RubyStringKeysInHashInspection
          container.update('RestartPolicy' => { 'Name'=> 'unless-stopped' })
          container.start
          container
        # rescue Docker::Error::DockerError
        #   nil
        end

        def delete_worker(name)
          container = get_container(name)
          return nil unless container
          delete_container(container)
        end

        def delete_container(container)
          container.stop(t: 60)
          container.remove
        end

        def worker_logs(name)
          container = get_container(name)
          return nil unless container
          container_logs(container)
        end

        def container_logs(container)
          container.streaming_logs(stdout: true, tail: 50).split("\n")
        end

        def worker_processes(name)
          container = get_container(name)
          return nil unless container
          container_processes(container)
        end

        def container_processes(container)
          container.top
        end

      end
    end
  end
end