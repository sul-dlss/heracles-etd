# frozen_string_literal: true

# Service for registering a new ETD in the system
class RegisterService
  # @return [Cocina::Models::DRO] the newly registered DRO
  def self.register(submission:)
    request_model = Cocina::Models.build_request({
                                                   'type' => Cocina::Models::ObjectType.object,
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
                                                     'sourceId' => "dissertation:#{submission.dissertation_id}"
                                                   }
                                                 })
    Dor::Services::Client.objects.register(params: request_model).tap do |cocina_object|
      Dor::Services::Client.object(cocina_object.externalIdentifier).workflow('registrationWF').create(version: 1)
    end
  end
end
