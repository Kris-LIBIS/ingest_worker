module Teneo
  module IngestServer
    class App < Roda

      plugin :hash_routes

      hash_branch :api, 'organizations' do |r|

        r.is do
          current_user.organizations_for(ROLE).map do |org|
            {
                id: org.id,
                name: org.name,
                roles: current_user.roles_for(org)
            }
          end
        end

        r.on Integer do |id|

          org = Teneo::DataModel::Organization.find_by(id: id)
          r.halt(404) unless org
          r.halt(401) unless current_user.is_authorized?(ROLE, org)

          r.is 'agreements' do
            agreements = org.ingest_agreements

            agreements.each_with_object([]) do |agr, arr|
              arr << {
                  id: agr.id,
                  name: agr.name,
                  description: agr.description,
              }
            end
          end

          r.get do
            {
                name: org.name,
                description: org.description,
                code: org.inst_code
            }
          end

        end

      end

    end
  end
end