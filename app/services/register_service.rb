# frozen_string_literal: true

# Service for registering a new ETD in the system
class RegisterService
  ETD_APO_DRUID = 'druid:bx911tp9024' # the APO that governs all ETDs

  # @return [Cocina::Models::DRO] the newly registered DRO
  def self.register(submission:)
    request_model = Cocina::Models.build_request({
                                                   'type' => Cocina::Models::ObjectType.object,
                                                   'version' => 1,
                                                   'label' => submission.title,
                                                   'administrative' => {
                                                     'hasAdminPolicy' => ETD_APO_DRUID
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
