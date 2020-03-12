module Teneo
  module IngestServer
    class App < Roda

      plugin :hash_routes

      hash_branch :api, 'runs' do |r|

        r.is do
          pkg_id = r.params['pkg_id']
          r.halt 412, [{ error: 'Missing pkg_id' }] unless pkg_id
          package = Teneo::DataModel::Package.find_by(id: pkg_id)
          r.halt 412, [{ error: 'Agreement not found' }] unless package
          r.halt 401 unless current_user.is_authorized?(ROLE, package)

          package.runs.map do |run|
            {
                id: run.id,
                name: run.name,
                status: run.last_status.to_s
            }
          end
        end

        r.on Integer do |id|
          run = Teneo::DataModel::Run.find_by(id: id)
          r.halt 404 unless run
          r.halt 401 unless current_user.is_authorized?(ROLE, run)

          r.post do
            case r.params['action']
            when 'start'
              queue = Teneo::Ingester::Queue.find_by(id: r.params['queue_id'])
              queue ||= Teneo::Ingester::Queue.find_by(name: r.params['queue_name'])
              priority = r.params['priority'] || 100
              r.halt(412) unless queue
              run = package.make_run
              work = Teneo::Ingester::Work.create(
                  queue: queue, priority: priority, subject: run, action: 'start',
                  work_status: Teneo::Ingester::WorkStatus.find_by(name: 'new')
              )
              {
                  work_id: work.id,
                  package_id: package.id,
                  run_id: run.id,
                  action: 'start'
              }
            else
              r.halt(400)
            end
          end

          r.is do
            {
                id: run.id,
                name: run.name,
                start: run.start_date&.strftime('%Y/%m/%d %H:%M:%S.%L'),
                config: run.config,
                options: run.options,
                properties: run.properties,
                status: run.last_status.to_s
            }
          end

        end
      end

    end
  end
end