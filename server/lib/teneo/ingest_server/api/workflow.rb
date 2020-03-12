module Teneo
  module IngestServer
    class App < Roda

      plugin :hash_routes

      hash_branch :api, 'workflows' do |r|

        r.is do
          agr_id = r.params['agr_id']
          r.halt 412, [{ error: 'Missing agr_id' }] unless agr_id
          agreement = Teneo::DataModel::IngestAgreement.find_by(id: agr_id)
          r.halt 412, [{ error: 'Agreement not found' }] unless agreement
          r.halt 401 unless current_user.is_authorized?(ROLE, agreement)

          agreement.ingest_workflows.map do |workflow|
            {
                id: workflow.id,
                name: workflow.name
            }
          end
        end

        r.on Integer do |id|
          workflow = Teneo::DataModel::IngestWorkflow.find_by(id: id)
          r.halt 404 unless workflow
          r.halt 401 unless current_user.is_authorized?(ROLE, workflow)

          r.get 'packages' do
            workflow.packages.map do |package|
              {
                  id: package.id,
                  name: package.name,
                  workflow: package.ingest_workflow.name
              }
            end
          end

          r.is do
            {
                name: workflow.name,
                description: workflow.description,
                stages: workflow.ingest_stages.each_with_object({}) do |stage, hash|
                  hash[stage.name] = {
                      id: stage.id,
                      autorun: stage.autorun,
                      name: stage.stage_workflow.name,
                      description: stage.stage_workflow.description
                  }
                end
            }
          end

        end

      end

    end
  end
end