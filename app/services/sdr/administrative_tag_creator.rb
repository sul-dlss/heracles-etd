# frozen_string_literal: true

module Sdr
  # Create administrative tags
  class AdministrativeTagCreator
    def self.create(etd)
      new(etd).create
    end

    def initialize(etd)
      @etd = etd
    end

    def create
      object_client.administrative_tags.create(tags: [administrative_tag])
    end

    private

    attr_reader :etd

    def administrative_tag
      "ETD : #{etd.etd_type}"
    end

    def object_client
      Dor::Services::Client.object(etd.druid)
    end
  end
end
