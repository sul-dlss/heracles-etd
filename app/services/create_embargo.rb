# frozen_string_literal: true

# Creates embargo on an ETD DOR object. You must call save after running this.
class CreateEmbargo
  # Create embargo if embargo_date is in the future
  def self.call(...)
    new(...).call
  end

  def initialize(druid, embargo_date)
    @druid = druid
    @embargo_date = embargo_date
  end

  def call
    return unless embargo_date&.future?

    item_hash = cocina_item.to_h
    item_hash[:access][:embargo] = Cocina::Models::Embargo.new(
      releaseDate: embargo_date.to_datetime, view: 'world', download: 'world'
    )

    object_client.update(params: cocina_item.class.new(item_hash))
  end

  private

  attr_reader :druid, :embargo_date

  def object_client
    @object_client ||= Dor::Services::Client.object(druid)
  end

  def cocina_item
    @cocina_item ||= object_client.find
  end
end
