module Teneo
  module IngestServer
    class App < Roda

      plugin :hash_routes

      hash_branch :api, 'agreements' do |r|

        r.is do
          org_id = r.params['org_id']
          r.halt 412, [{ error: 'Missing org_id' }] unless org_id
          organization = Teneo::DataModel::Organization.find_by(id: org_id)
          r.halt 412, [{ error: 'Organization not found' }] unless organization
          r.halt 401 unless current_user.is_authorized?(ROLE, organization)

          organization.ingest_agreements.each_with_object([]) do |agr, arr|
            arr << {
                id: agr.id,
                name: agr.name,
                description: agr.description,
            }
          end
        end

        r.on Integer do |id|
          agreement = Teneo::DataModel::IngestAgreement.find_by(id: id)
          r.halt 404 unless agreement
          r.halt 401 unless current_user.is_authorized?(ROLE, agreement)

          r.get 'workflows' do
            agreement.ingest_workflows.map do |workflow|
              {
                  id: workflow.id,
                  name: workflow.name
              }
            end
          end

          r.get 'packages' do
            agreement.packages.each_with_object([]) do |package, arr|
              arr << {
                  id: package.id,
                  name: package.name,
                  workflow: package.ingest_workflow.name
              }
            end
          end

          r.is do
            {
                name: agreement.name,
                description: agreement.description,
                project_name: agreement.project_name,
                collection_name: agreement.collection_name,
                collection_description: agreement.collection_description,
                contact_ingest: agreement.contact_ingest,
                contact_collection: agreement.contact_collection,
                contact_system: agreement.contact_system,
            }
          end

        end

      end

    end
  end
end