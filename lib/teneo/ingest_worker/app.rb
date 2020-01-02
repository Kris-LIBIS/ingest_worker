# frozen_string_literal: true

require 'roda'
require 'awesome_print'
require 'ostruct'
require 'json'

module Teneo
  module IngestServer

    class App < Roda

      key = File.read(File.join(Teneo::IngestServer::ROOT_DIR, 'key.bin'), mode: 'rb')

      use Rack::Session::Cookie, secret: key

      plugin :public, root: 'static'
      plugin :empty_root
      plugin :heartbeat, path: '/status'
      plugin :json
      plugin :json_parser
      plugin :all_verbs
      plugin :halt
      plugin :request_headers
      plugin :sessions,
             cookie_options: {http_only: true, same_site: :strict},
             secret: key,
             key: 'teneo.ingester'

      route do |r|

        r.on 'api' do

          r.halt 406 unless r.headers['Accept'] =~ %r{^application/json}
          r.halt 405 unless r.headers['Content-Type'] =~ %r{^application/json}

          r.post 'login' do
            account = Account.authenticate(r.params['email'], r.params['password'])
            user = account&.user
            r.halt(401) unless user
            session.clear
            session[:user_id] = user.uuid
            {
                name: user.name,
                orgs: user.member_organizations.each_with_object({}) do |(org, roles), hash|
                  hash[org.name] = {id: org.id, roles: roles}
                end
            }
          end

          # @return [Teneoo::IngestServer::Accout]
          def current_user
            @current_user ||= Teneo::DataModel::User.find_by(uuid: session[:user_id])
          end

          r.delete 'logout' do
            user = current_user
            session.clear
            {
                message: user ? "User #{user.name} logged out" : "Not logged in"
            }
          end

          r.halt(401) unless current_user

          r.on 'user' do

            r.is do
              {first_name: current_user.first_name, last_name: current_user.last_name, email: current_user.email}
            end

          end

          r.on 'organizations' do

            user_orgs = current_user.member_organizations

            r.is do
              user_orgs.each_with_object([]) do |(org, roles), arr|
                arr << {
                    id: org.id,
                    name: org.name,
                    roles: roles
                }
              end
            end

            r.on Integer do |id|
              org = user_orgs.keys.find { |o| o.id == id }
              r.halt(404) unless org

              r.get do
                {
                    name: org.name,
                    description: org.description,
                    code: org.inst_code
                }
              end

              r.post do
                case r.params['action']
                when 'select'
                  session[:org_id] = org.id
                  {
                      id: org.id,
                      name: org.name,
                  }
                else
                  r.halt(400)
                end
              end
            end

          end

          # @return [Teneo::DataModel::Organization]
          def current_organization
            @current_organization ||= Teneo::DataModel::Organization.find_by(id: session[:org_id])
          end

          r.halt 412 unless current_organization

          r.on 'ingest_agreements' do

            org_agreements = current_organization&.ingest_agreements

            r.is do
              org_agreements.each_with_object([]) do |agr, arr|
                arr << {
                    id: agr.id,
                    name: agr.name,
                    description: agr.description,
                }
              end
            end

            r.on Integer do |id|
              agr = org_agreements.find_by(id: id)
              r.halt(404) unless agr

              r.get do
                {
                    name: agr.name,
                    description: agr.description,
                    project_name: agr.project_name,
                    collection_name: agr.collection_name,
                    collection_description: agr.collection_description,
                    contact_ingest: agr.contact_ingest,
                    contact_collection: agr.contact_collection,
                    contact_system: agr.contact_system,
                }
              end

              r.post do
                case (r.params['action'])
                when 'select'
                  session[:agr_id] = agr.id
                  {
                      id: agr.id,
                      name: agr.name,
                  }
                else
                  r.halt(400)
                end
              end

            end

          end

          # @return [Teneo::DataModel::Organization]
          def current_agreement
            @current_agreement ||= Teneo::DataModel::IngestAgreement.find_by(id: session[:agr_id])
          end

          r.halt 412 unless current_agreement

          r.on 'ingest_workflows' do

            workflows = current_agreement.ingest_workflows

            r.is do
              workflows.map do |workflow|
                {
                    id: workflow.id,
                    name: workflow.name
                }
              end
            end

            r.on Integer do |id|
              workflow = Teneo::DataModel::IngestWorkflow.find_by(id: id)
              r.halt(404) unless workflow

              r.get do
                {
                    name: workflows.name,
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

          r.on 'packages' do

            packages = current_agreement.packages

            r.is do
              packages.each_with_object([]) do |package, arr|
                arr << {
                    id: package.id,
                    name: package.name,
                    workflow: package.ingest_workflow.name
                }
              end
            end

            r.on Integer do |id|
              package = packages.find_by(id: id)
              r.halt(404) unless package

              r.get do
                {
                    id: package.id,
                    name: package.name,
                    workflow: {
                        id: package.ingest_workflow.id,
                        name: package.ingest_workflow.name
                    },
                    options: package.options,
                }
              end

              r.post do
                case r.params['action']
                when 'select'
                  session[:package_id] = package.id
                  {
                      id: package.id,
                      name: package.name,
                  }
                when 'start'
                  queue = Teneo::IngestServer::Queue.find_by(id: r.params['queue_id'])
                  queue ||= Teneo::IngestServer::Queue.find_by(name: r.params['queue_name'])
                  priority = r.params['priority'] || 100
                  r.halt(412) unless queue
                  run = package.make_run
                  work = Teneo::IngestServer::Work.create(
                      queue: queue, priority: priority, subject: run, action: 'start',
                      work_status: Teneo::IngestServer::WorkStatus.find_by(name: 'new')
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
            end

          end

          # @return [Teneo::DataModel::Organization]
          def current_package
            @current_package ||= Teneo::DataModel::Package.find_by(id: session[:package_id])
          end

          r.halt 412 unless current_package

          r.on 'runs' do

            runs = current_package.runs

            r.is do
              runs.each_with_object([]) do |run, arr|
                arr << {
                    id: run.id,
                    name: run.name,
                    status: run.last_status.to_s
                }
              end
            end

            r.on Integer do |id|
              run = run.find_by(id: id)
              r.halt(404) unless run

              r.get do
                {
                    id: run.id,
                    name: run.name,
                    start: run.start_date.strftime('%Y/%m/%d %H:%M:%S.%L'),
                    config: run.config,
                    options: run.options,
                    properties: run.properties,
                    status: run.last_status(run).to_s
                }
              end

            end
          end

        end

      end

    end

  end
end
