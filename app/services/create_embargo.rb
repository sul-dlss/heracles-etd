# frozen_string_literal: true

# Creates embargo on an ETD DOR object. You must call save after running this.
class CreateEmbargo
  # Create embargo if embargo_date is in the future
  def self.call(druid, embargo_date)
    return unless embargo_date&.future?

    object_client = Dor::Services::Client.object(druid)
    dro = object_client.find
    dro_as_hash = dro.to_h
    dro_as_hash[:access][:embargo] =
      Cocina::Models::Embargo.new(releaseDate: embargo_date.to_datetime, view: 'world', download: 'world')
    object_client.update(params: dro.class.new(dro_as_hash))
  end
end
