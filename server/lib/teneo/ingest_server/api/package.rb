module Teneo
  module IngestServer
    class App < Roda

      plugin :hash_routes

      hash_branch :api, 'packages' do |r|

        r.is do

          if (flow_id = r.params['flow_id'])
            workflow = Teneo::DataModel::IngestWorkflow.find_by(id: flow_id)
            r.halt 412, [{ error: 'Workflow not found' }] unless workflow
            r.halt 401 unless current_user.is_authorized?(ROLE, workflow)
            workflow
          elsif (agr_id = r.params['agr_id'])
            agreement = Teneo::DataModel::IngestAgreement.find_by(id: agr_id)
            r.halt 412, [{ error: 'Agreement not found' }] unless agreement
            r.halt 401 unless current_user.is_authorized?(ROLE, agreement)
            agreement
          else
            r.halt 412, [{ error: 'Missing agr_id or flow_id' }]
          end.packages.map do |package|
            {
                id: package.id,
                name: package.name,
                workflow: package.ingest_workflow.name,
            }
          end
        end

        r.on Integer do |id|
          package = Teneo::DataModel::Package.find_by(id: id)
          r.halt 404 unless package
          r.halt 401 unless current_user.is_authorized?(ROLE, package)

          r.get 'runs' do
            package.runs.map do |run|
              {
                  id: run.id,
                  name: run.name,
                  status: run.last_status.to_s
              }
            end
          end

          r.post 'runs' do
            unless package.runs.map(&:last_status).all? { |status| Libis::Workflow::Base::StatusEnum.done?(status) }
              r.halt 409, [{error: 'A run is already started for this package'}]
            end
            run = package.make_run
            {
                id: run.id
            }
          end

          r.is do
            {
                id: package.id,
                name: package.name,
                workflow: {
                    id: package.ingest_workflow.id,
                    name: package.ingest_workflow.name
                },
                options: package.options,
                parameters: package.parameter_values.transform_keys { |key| key.gsub(/^.*#/, '') }
            }
          end

        end

      end

    end
  end
end