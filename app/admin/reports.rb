# frozen_string_literal: true

ActiveAdmin.register Report do
  menu label: 'Quarterly Reports'

  config.filters = false

  permit_params :label, :description, :start_date, :end_date

  timezone_label = Time.zone.now.strftime('%Z')

  index download_links: false, title: 'Quarterly Reports' do
    id_column
    column 'Label' do |report|
      link_to report.label, format('quarterly_reports?q[last_registrar_action_at_gteq]=%<start_date>s&' \
                                   'q[last_registrar_action_at_lteq]=%<end_date>s&' \
                                   'commit=Filter&order=id_desc&label=%<label>s',
                                   start_date: report.start_date,
                                   end_date: report.end_date,
                                   label: report.label)
    end
    column :start_date
    column :end_date
    column :description
  end

  show do
    attributes_table do
      rows(
        *active_admin_config.resource_columns.without(:start_date, :end_date)
      )
      row helpers.t('activerecord.attributes.report.custom.start_date',
                    timezone_label: report.start_date.in_time_zone(Rails.application.config.time_zone).strftime('%Z')),
          &:start_date
      row helpers.t('activerecord.attributes.report.custom.end_date',
                    timezone_label: report.end_date.in_time_zone(Rails.application.config.time_zone).strftime('%Z')),
          &:end_date
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs do
      input :label
      input :description
      input :start_date, label: helpers.t('activerecord.attributes.report.custom.start_date', timezone_label:)
      input :end_date, label: helpers.t('activerecord.attributes.report.custom.end_date', timezone_label:)
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end

  sidebar 'Archive', only: :index do
    render partial: 'archive'
  end
end
