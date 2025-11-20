# frozen_string_literal: true

namespace :assign_doi do
  desc 'Assign DOIs to previously registered ETDs for the given year'
  task :by_year, %i[year dryrun] => :environment do |_t, args|
    year = Date.strptime(args[:year], '%Y')
    dryrun = (args[:dryrun] != 'false') && true

    puts '**** DRY RUN ****' if dryrun
    Submission.where(created_at: year.all_year).find_each do |submission|
      puts "Processing #{submission.druid}"
      object_client = Dor::Services::Client.object(submission.druid)
      dro = object_client.find

      next if dro.identification.doi.present?

      ## Add the DOI identifier
      dro.new(
        identification: dro.identification.new(
          doi: "#{Settings.datacite.prefix}/#{submission.druid.delete_prefix('druid:')}"
        )
      )

      ## Add the required resource type for DataCite ETDs
      dro.new(
        description: dro.description.new(
          form: dro.description.form.push(
            {
              source: {
                value: 'DataCite resource types'
              },
              type: 'resource type',
              value: 'Dissertation'
            },
            {
              source: {
                value: 'Stanford self-deposit resource types'
              },
              type: 'resource type',
              structuredValue: [{ type: 'subtype', value: 'Academic thesis' }]
            }
          )
        )
      )

      next if dryrun
      next unless object_client.version.openable?

      object_client.version.open(description: 'Assigning DOI and resource type')
      object_client.update(params: dro)
      object_client.version.close
    end
  end
end
