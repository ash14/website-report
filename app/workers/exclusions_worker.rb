require 'sidekiq-scheduler'
require 'net/http'

class ExclusionsWorker
  include Sidekiq::Worker

  def perform

    uri = URI(Rails.application.config.exclusions_url)
    response = Net::HTTP.get(uri)
    response = JSON.parse(response)

    response.each do |exclusion|
      exclusion_record = Exclusion.find_or_initialize_by(host: exclusion['host'])

      exclusion_record.update!(
          excluded_since: exclusion['excludedSince'],
          excluded_till: exclusion['excludedTill']
      )
    end
  end
end
