# frozen_string_literal: true

ActiveAdmin.register Submission, as: 'Full Submissions' do
  menu false

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  permit_params :druid, :name, :prefix, :suffix, :major, :degree,
                :etd_type, :title, :folio_instance_hrid, :abstract,
                :sulicense, :cclicense, :cclicensetype,
                :embargo, :sub, :sunetid,
                :ps_career, :ps_subplan, :dissertation_id,
                :provost, :degreeconfyr, :schoolname, :department, :readerapproval,
                :readercomment, :last_reader_action_at, :regapproval, :regcomment,
                :last_registrar_action_at, :documentaccess, :submitted_at,
                :citation_verified, :abstract_provided, :dissertation_uploaded,
                :supplemental_files_uploaded, :permissions_provided,
                :permission_files_uploaded, :rights_selected,
                :submitted_to_registrar, :format_reviewed, :ils_record_created_at,
                :ils_record_updated_at, :accessioning_started_at
  # deliberately not including:  :univid, :external_visibility

  timezone_label = Time.zone.now.strftime('%Z')

  index_columns = %i[druid dissertation_id name prefix suffix title folio_instance_hrid etd_type
                     embargo degreeconfyr schoolname department readerapproval regapproval
                     sulicense cclicense cclicensetype external_visibility
                     sub univid sunetid major degree ps_career
                     ps_subplan provost readercomment readeractiondttm
                     regcomment regactiondttm documentaccess citation_verified
                     abstract_provided format_reviewed dissertation_uploaded supplemental_files_uploaded
                     permissions_provided permission_files_uploaded rights_selected
                     submitted_to_registrar]

  index do
    column 'Id', sortable: :id do |submission|
      link_to submission.id, admin_submission_path(submission.id)
    end
    index_columns.each do |index_column|
      column index_column
    end
    column helpers.t('activerecord.attributes.submission.submitted_at', timezone_label:), :submitted_at
    column helpers.t('activerecord.attributes.submission.last_reader_action_at', timezone_label:),
           :last_reader_action_at
    column helpers.t('activerecord.attributes.submission.last_registrar_action_at', timezone_label:),
           :last_registrar_action_at
    column helpers.t('activerecord.attributes.submission.ils_record_updated_at', timezone_label:),
           :ils_record_updated_at
    column helpers.t('activerecord.attributes.submission.accessioning_started_at', timezone_label:),
           :accessioning_started_at
    column helpers.t('activerecord.attributes.submission.created_at', timezone_label:), :created_at
    column helpers.t('activerecord.attributes.submission.updated_at', timezone_label:), :updated_at
  end

  filter :druid, filters: %i[end cont eq start]
  filter :dissertation_id, filters: %i[end cont eq start]
  filter :name
  filter :prefix
  filter :suffix
  filter :title
  filter :folio_instance_hrid, filters: [:eq]
  filter :embargo, as: :select
  filter :readerapproval, as: :select
  filter :regapproval, as: :select
  filter :submitted_at, as: :date_range,
                        label: I18n.t('activerecord.attributes.submission.submitted_at', timezone_label:)
  filter :degreeconfyr, as: :select
  filter :etd_type, as: :select
  filter :department
  filter :major
  filter :ps_subplan
  filter :schoolname, as: :select
  filter :degree, as: :select
  filter :sunetid
  filter :abstract
  filter :sub
  filter :submitted_to_registrar, as: :select
  filter :last_reader_action_at, as: :date_range,
                                 label: I18n.t('activerecord.attributes.submission.last_reader_action_at',
                                               timezone_label:)
  filter :last_registrar_action_at, as: :date_range,
                                    label: I18n.t('activerecord.attributes.submission.last_registrar_action_at',
                                                  timezone_label:)
  filter :ils_record_created_at, as: :date_range,
                                 label: I18n.t('activerecord.attributes.submission.ils_record_created_at',
                                               timezone_label:)
  filter :ils_record_updated_at, as: :date_range,
                                 label: I18n.t('activerecord.attributes.submission.ils_record_updated_at',
                                               timezone_label:)
  filter :accessioning_started_at, as: :date_range,
                                   label: I18n.t('activerecord.attributes.submission.accessioning_started_at',
                                                 timezone_label:)
  filter :created_at, as: :date_range, label: I18n.t('activerecord.attributes.submission.created_at',
                                                     timezone_label:)
  filter :updated_at, as: :date_range, label: I18n.t('activerecord.attributes.submission.updated_at',
                                                     timezone_label:)
  filter :sulicense
  filter :cclicense
  filter :cclicensetype
  filter :external_visibility
  filter :univid
  filter :ps_career
  filter :provost
  filter :readercomment
  filter :readeractiondttm
  filter :regcomment
  filter :regactiondttm
  filter :documentaccess
  filter :citation_verified
  filter :abstract_provided
  filter :format_reviewed
  filter :dissertation_uploaded
  filter :supplemental_files_uploaded
  filter :permissions_provided
  filter :permission_files_uploaded
  filter :rights_selected

  show title: :title do
    attributes_table do
      rows(
        *active_admin_config.resource_columns.without(
          :created_at,
          :updated_at,
          :submitted_at,
          :last_reader_action_at,
          :last_registrar_action_at,
          :ils_record_created_at,
          :ils_record_updated_at,
          :accessioning_started_at
        )
      )
      row helpers.t('activerecord.attributes.submission.submitted_at', timezone_label:), &:submitted_at
      row helpers.t('activerecord.attributes.submission.last_reader_action_at', timezone_label:),
          &:last_reader_action_at
      row helpers.t('activerecord.attributes.submission.last_registrar_action_at', timezone_label:),
          &:last_registrar_action_at
      row helpers.t('activerecord.attributes.submission.ils_record_created_at', timezone_label:),
          &:ils_record_created_at
      row helpers.t('activerecord.attributes.submission.ils_record_updated_at', timezone_label:),
          &:ils_record_updated_at
      row helpers.t('activerecord.attributes.submission.accessioning_started_at', timezone_label:),
          &:accessioning_started_at
      row helpers.t('activerecord.attributes.submission.created_at', timezone_label:), &:created_at
      row helpers.t('activerecord.attributes.submission.updated_at', timezone_label:), &:updated_at
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs do
      index_columns.each do |form_column|
        input form_column
      end
      f.input :abstract
      f.input :submitted_at, label: helpers.t('activerecord.attributes.submission.submitted_at', timezone_label:)
      f.input :last_reader_action_at,
              label: helpers.t('activerecord.attributes.submission.last_reader_action_at', timezone_label:)
      f.input :last_registrar_action_at,
              label: helpers.t('activerecord.attributes.submission.last_registrar_action_at', timezone_label:)
      f.input :ils_record_created_at,
              label: helpers.t('activerecord.attributes.submission.ils_record_created_at', timezone_label:)
      f.input :ils_record_updated_at,
              label: helpers.t('activerecord.attributes.submission.ils_record_updated_at', timezone_label:)
      f.input :accessioning_started_at,
              label: helpers.t('activerecord.attributes.submission.accessioning_started_at', timezone_label:)
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end
end
