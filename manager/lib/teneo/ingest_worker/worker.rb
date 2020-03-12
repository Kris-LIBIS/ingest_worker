require 'docker-api'

Docker::API_VERSION
module Teneo
  module IngestWorker
    class Worker

      IMAGE = 'ingest_worker:latest'.freeze
      LABEL = 'be.libis.teneo.ingester.worker'

      class << self

        def list
          begin
            Docker::Container.all(all: true, filters: {label: [LABEL]}.to_json)
          rescue Docker::Error::NotFoundError
            []
          end.map do |container|
            container.info['Names'].grep(/^\/ingest_worker\./).first.split('.').last
          rescue
            nil
          end.compact.freeze
        end

        def build
          build!
        rescue Docker::Error::ClientError
          nil
        end

        def build!
          Docker::Image.build_from_dir(
            '../worker',
            t: IMAGE,
            forcerm: true,
            labels: { LABEL => nil }.to_json,
            buildargs: {
              UID: ENV['USER_ID'],
              GID: ENV['GROUP_ID']
            }.to_json
          )
        end

        def image_exist?
          Docker::Image.exist?(IMAGE)
        end

      end

      attr_reader :name, :queues, :threads

      def initialize(name:)
        @name = name
        @queues = nil
        @threads = nil
        @error = nil

        # Check validity of name
        valid_name?
      end

      def error
        x, @error = @error, nil
        x
      end

      def valid_name?
        unless @name.is_a?(String) && !@name.empty?
          raise ArgumentError, "Worker name should be a string (is '#{@name}')"
        end
      end

      def valid_queues?
        @queues = [@queues.to_s] if @queues.is_a?(String) || @queues.is_a?(Symbol)
        @queues = Hash[@queues.zip [1]] if @queues.is_a?(Array)
        unless @queues.is_a?(Hash) && !@queues.empty? &&
            @queues.keys.all? { |x| x.is_a?(String) } &&
            @queues.values.all? { |x| x.is_a?(Integer) && x > 0 }
          raise ArgumentError, "Queue name list should be Hash[String, Integer > 0] (is '#{@queues}')"
        end
      end

      def valid_threads?
        unless @threads.is_a?(Integer) && @threads > 0
          raise ArgumentError, "Threads should be a positive integer (is '#{@threads}')"
        end
      end

      def exist?
        !!get_container
      end

      def started?
        get_container&.status
      end

      def start
        start!
      rescue Docker::Error::DockerError => e
        @error ||= e.message
        nil
      end

      def start!
        self.class.build unless self.class.image_exist?
        container = get_container || Docker::Container.create(
            name: "ingest_worker.#{name}",
            'Image' => IMAGE,
            'Env' => ["NAME=#{name}"],
            'HostConfig' => {
              'Binds' => [
                "#{ROOT_DIR}/../worker:/teneo"
              ]
            }
        )
        #noinspection RubyStringKeysInHashInspection
        container.update('RestartPolicy' => { 'MaximumRetryCount' => 0, 'Name' => 'unless-stopped' })
        container.start
        container
      end

      def stop
        stop!
      rescue Docker::Error::DockerError => e
        @error ||= e.message
        false
      end

      def stop!
        return nil unless (container = get_container)
        container.stop(t: 60)
        container.remove
        true
      end

      def logs
        logs!
      rescue Docker::Error::DockerError => e
        @error ||= e.message
        nil
      end

      def logs!
        return nil unless (container = get_container)
        container.streaming_logs(stdout: true, **opts).split("\n")
      end

      def processes
        processes!
      rescue Docker::Error::DockerError => e
        @error ||= e.message
        nil
      end

      def processes!
        return nil unless (container = get_container)
        container.top(**opts)
      end

      def info
        info!
      rescue Docker::Error::DockerError => e
        @error ||= e.message
        nil
      end

      def info!
        return nil unless (container = get_container)
        container.json
      end

      protected

      def get_container
        @container ||= Docker::Container.get("ingest_worker.#{name}")
      rescue Docker::Error::DockerError => e
        @error ||= e.message
        nil
      end

      private

=begin
      def xxx
        # Set root dir
        dir = Dir.pwd
        Dir.chdir(Teneo::IngestWorker::ROOT_DIR)

        # Cleanup files
        FileUtils.mv(log_file_name, log_file_name + '.bak') if File.exist?(log_file_name)
        FileUtils.rm(pid_file_name) if File.exist?(pid_file_name)

        # Collect SideKiq server arguments
        options = [
            '-C', 'config/sidekiq.yml',
            '-g', @name,
            '-c', @threads.to_s,
            '-r', 'server.rb'
        ]
        @queues.each { |queue| options << '-q' << queue }


        # Launch the
        pid = Process.spawn 'bundle', 'exec', 'sidekiq', *options
        Process.wait(pid)

        # Check for registered server
        0.upto(10).each do
          ::Sidekiq::ProcessSet.new.each do |process|
            if process['tag'] == tag
              pid = process['pid']
              if check_pid(pid)
                return pid
              end
            end
          end
          sleep(1)
        end
        nil
      ensure
        Dir.chdir(dir)
      end

      def x
        start_process 'bundle', 'exec', 'sidekiq', *options
        sleep(1)
        0.upto(50).each do
          get_processes.each do |process|
            if process['tag'] == tag
              pid = process['pid']
              if check_pid(pid)
                puts "Sidekiq #{tag} process #{pid} started."
                return pid
              end
            end
          end
          sleep(0.2)
        end
        puts "Sidekiq #{tag} failed to start."
        nil
      end
=end

    end
  end
end