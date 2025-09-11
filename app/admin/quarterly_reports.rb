# frozen_string_literal: true

ActiveAdmin.register Submission, as: 'Quarterly Reports' do
  menu false
  actions :index, only: true

  config.clear_action_items! # This removes "new quarterly report"
  config.current_filters = false # Disable current filters and use filters defined below
  config.paginate = false # product owner does not need it, and it causes undercounts in the side panels

  timezone_label = Time.zone.now.strftime('%Z')

  filter :last_registrar_action_at, as: :date_range,
                                    label: I18n.t('activerecord.attributes.submission.last_registrar_action_at',
                                                  timezone_label:)

  index_columns = %i[dissertation_id druid folio_instance_hrid etd_type schoolname department name
                     title cclicensetype embargo embargo_release_date]

  index download_links: [:csv], title: proc { |_report| "Quarterly Report: #{params['label']}" } do
    index_columns.each do |index_column|
      case index_column
      when :dissertation_id
        column 'Dissertation', :dissertation_id
      when :druid
        column 'Druid', sortable: :druid do |submission|
          link_to submission.bare_druid, purl(submission.bare_druid)
        end
      when :folio_instance_hrid
        column 'Folio HRID', sortable: :folio_instance_hrid do |submission|
          if submission.folio_instance_hrid.present?
            link_to submission.folio_instance_hrid,
                    searchworks_url(submission.folio_instance_hrid)
          end
        end
      when :title
        column 'Title', sortable: :title do |submission|
          link_to submission.title, pdf_url(submission) if submission.dissertation_file.present?
        end
      when :cclicensetype
        column 'CC', sortable: :cclicensetype do |submission|
          cc_code(submission.cclicense)
        end
      when :embargo_release_date
        column 'Release', :embargo_release_date do |submission|
          embargo_release_as_day(submission)
        end
      else
        column index_column
      end
    end
  end

  sidebar :etds, only: :index do
    render partial: 'etd_summary', locals: { data: etd_summary(collection) }
  end

  sidebar :licenses, only: :index do
    render partial: 'cc_summary', locals: { data: cc_summary(collection) }
  end

  sidebar :embargoes, only: :index do
    render partial: 'embargo_summary', locals: { data: embargo_summary(collection) }
  end

  csv_columns = %i[dissertation_id druid purl folio_instance_hrid searchworks_url etd_type schoolname department name
                   title pdf_url cclicensetype embargo embargo_release_date]
  csv col_sep: '|' do
    csv_columns.each do |csv_column|
      case csv_column
      when :purl
        column 'Purl' do |submission|
          purl(submission.bare_druid)
        end
      when :searchworks_url
        column 'Searchworks URL' do |submission|
          searchworks_url(submission.folio_instance_hrid) if submission.folio_instance_hrid.present?
        end
      when :pdf_url
        column 'pdf URL' do |submission|
          pdf_url(submission) if submission.dissertation_file.present?
        end
      when :cclicensetype
        column 'CC License' do |submission|
          cc_code(submission.cclicense)
        end
      when :embargo_release_date
        column 'Release Date' do |submission|
          embargo_release_as_day(submission)
        end
      else
        column csv_column
      end
    end
  end
end

def cc_code(cclicense)
  Settings.cc_option_to_code_map.to_h.key(cclicense)
end

def purl(bare_druid)
  "#{Settings.purl.url}/#{bare_druid}"
end

# caller checks that catalog_record_id isn't blank
def searchworks_url(catalog_record_id)
  format(Settings.searchworks_uri, catalog_record_id:)
end

# caller checks that submission.dissertation_file isn't blank
def pdf_url(submission)
  format(Settings.stacks_uri, druid: submission.druid, aug_diss_file_name: submission.augmented_dissertation_file_name)
end

def embargo_release_as_day(submission)
  submission.embargo_release_date&.to_date&.iso8601
end

def etd_summary(collection)
  {
    thesis: collection.where(etd_type: 'Thesis').count,
    dissertation: collection.where(etd_type: 'Dissertation').count
  }
end

def cc_summary(collection)
  CreativeCommonsLicense.all.map do |cc_license|
    count = collection.where(cclicense: cc_license.id).count
    {
      code: cc_license.code,
      count:,
      pct: number_to_percentage(count / collection.count.to_f * 100, precision: 1)
    }
  end
end

def embargo_summary(collection)
  total = collection.count.to_f
  [].tap do |summary|
    immediate_count = collection.where(embargo: ['Immediately', '', nil]).count
    summary << { embargo_release: 'Immediately',
                 count: immediate_count,
                 pct: number_to_percentage(immediate_count / total * 100, precision: 1) }
    ['6 months', '1 year', '2 years'].each do |embargo_term|
      count = collection.where(embargo: embargo_term).count
      summary << { embargo_release: embargo_term,
                   count:,
                   pct: number_to_percentage(count / total * 100, precision: 1) }
    end
  end
end
