# frozen_string_literal: true

# Service for registering a new ETD in the system
class RegisterService
  # @return [Cocina::Models::DRO] the newly registered DRO
  def self.register(submission:)
    source_id = "dissertation:#{submission.dissertation_id}"
    request_model = Cocina::Models.build_request({
                                                   'type' => Cocina::Models::ObjectType.document,
                                                   'version' => 1,
                                                   'administrative' => {
                                                     'hasAdminPolicy' => Settings.etd_apo
                                                   },
                                                   'description' => {
                                                     'title' => [
                                                       { value: submission.title }
                                                     ]
                                                   },
                                                   'identification' => {
                                                     'sourceId' => source_id
                                                   }
                                                 })
    Dor::Services::Client.objects.register(params: request_model).tap do |cocina_object|
      Dor::Services::Client.object(cocina_object.externalIdentifier).workflow('registrationWF').create(version: 1)
    end
  rescue Dor::Services::Client::ConflictResponse
    # A concurrent or retried Peoplesoft delivery for this dissertation already registered it with
    # SDR (see https://app.honeybadger.io/projects/55164/faults/132682151). Return the SDR object already
    # created for this source ID instead of erroring.
    Dor::Services::Client.objects.find(source_id:)
  end
end
