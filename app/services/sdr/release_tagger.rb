# frozen_string_literal: true

module Sdr
  # Creates release tags for an ETD
  class ReleaseTagger
    # @param [String] druid druid of the submission to add release tags to
    # @return [Boolean] true if successful
    # @raise [Dor::Services::Client::NotFoundResponse] if response is a 404 (object not found)
    # @raise [Dor::Services::Client::UnexpectedResponse] if request is unsuccessful.
    def self.tag(druid:)
      new(druid:).tag
    end

    # @param [String] druid druid of the submission to add release tags to
    def initialize(druid:)
      @druid = druid
    end

    # @raise [Dor::Services::Client::NotFoundResponse] if response is a 404 (object not found)
    # @raise [Dor::Services::Client::UnexpectedResponse] if request is unsuccessful.
    def tag
      new_release_tags.each do |new_tag|
        object_client.release_tags.create(tag: new_tag)
      end
    end

    private

    attr_reader :druid

    def object_client
      Dor::Services::Client.object(druid)
    end

    def new_release_tags
      date = DateTime.now.utc.iso8601
      [
        Dor::Services::Client::ReleaseTag.new(to: 'Searchworks', who: 'caster', what: 'self', release: true, date:),
        Dor::Services::Client::ReleaseTag.new(to: 'PURL sitemap', who: 'caster', what: 'self', release: true, date:)
      ]
    end
  end
end
