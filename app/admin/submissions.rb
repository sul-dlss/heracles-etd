# frozen_string_literal: true

ActiveAdmin.register Submission do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  permit_params :druid, :name, :prefix, :suffix, :major, :degree,
                :etd_type, :title, :folio_instance_hrid, :abstract, :containscopyright,
                :sulicense, :cclicense, :cclicensetype,
                :embargo, :sub, :sunetid,
                :ps_career, :ps_subplan, :dissertation_id,
                :provost, :degreeconfyr, :schoolname, :department, :readerapproval,
                :readercomment, :last_reader_action_at, :regapproval, :regcomment,
                :last_registrar_action_at, :documentaccess, :submitted_at,
                :citation_verified, :abstract_provided, :dissertation_uploaded,
                :supplemental_files_uploaded, :permissions_provided,
                :permission_files_uploaded, :rights_selected, :cc_license_selected,
                :submitted_to_registrar, :format_reviewed, :ils_record_created_at,
                :ils_record_updated_at, :accessioning_started_at
  # deliberately not including:  :univid, :external_visibility

  timezone_label = Time.zone.now.strftime('%Z')

  # NOTE: These are the fields that are displayed as columns in the `index` view
  #       without any special behavior, e.g., linking & TZ labeling.
  index_columns = %i[
    etd_type embargo degreeconfyr schoolname department readerapproval regapproval
  ]

  # Only allow admins to create dummy submissions in QA, stage, and local dev
  if Rails.env.development? || (Rails.env.production? && %w[qa stage].include?(Honeybadger.config[:env]))
    collection_action :new_dummy_submission, method: :get do
      submission = Admin::DummySubmissionService.call(sunetid: current_user.sunetid)

      redirect_to edit_submission_path(submission)
    end

    action_item :new_dummy_submission, only: :index do
      link_to 'Create Dummy Submission', new_dummy_submission_admin_submissions_path
    end
  end

  scope 'Registered', :at_registered
  scope 'Submitted', :at_submitted
  scope 'Reader approved', :at_reader_approved
  scope 'Registrar approved', :at_registrar_approved
  scope 'Registrar approved', :at_registrar_approved
  scope 'Loaded into ILS', :at_ils_loaded
  scope 'Cataloged in ILS', :at_ils_cataloged
  scope 'Accessioning Started', :at_accessioning_started

  index do
    column 'Id', sortable: :id do |submission|
      link_to submission.id, admin_submission_path(submission)
    end
    column 'Druid (=> Argo)', sortable: :druid do |submission|
      link_to submission.druid, "#{Settings.argo_url}/view/#{submission.druid}"
    end
    column 'Dissertation ID (=> /submit)', sortable: :dissertation_id do |submission|
      link_to submission.dissertation_id, edit_submission_path(submission)
    end
    %i[name title].each do |c|
      column c.to_sym
    end
    column 'Folio Instance HRID (=> SearchWorks)', sortable: :folio_instance_hrid do |submission|
      if submission.folio_instance_hrid
        link_to submission.folio_instance_hrid,
                format(Settings.searchworks_uri,
                       catalog_record_id: submission.folio_instance_hrid)
      end
    end
    index_columns.each do |index_column|
      column index_column
    end
    column helpers.t('activerecord.attributes.submission.submitted_at', timezone_label:), :submitted_at
    column helpers.t('activerecord.attributes.submission.last_reader_action_at', timezone_label:),
           :last_reader_action_at
    column helpers.t('activerecord.attributes.submission.last_registrar_action_at', timezone_label:),
           :last_registrar_action_at
    column helpers.t('activerecord.attributes.submission.ils_record_created_at', timezone_label:),
           :ils_record_created_at
    column helpers.t('activerecord.attributes.submission.ils_record_updated_at', timezone_label:),
           :ils_record_updated_at
    column helpers.t('activerecord.attributes.submission.accessioning_started_at', timezone_label:),
           :accessioning_started_at
    actions
  end

  # Find submissions by disseration id, not id.
  controller do
    def find_resource
      Submission.find_by(dissertation_id: params[:id])
    end
  end

  # filters: ordering / selecting
  filter :druid, filters: %i[end cont eq]
  filter :dissertation_id, filters: [:end]
  filter :name
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
  filter :degree, as: :select # ["Ph.D.", "JSD", "DMA", "Engineering"]
  filter :sunetid
  filter :sub # submit deadline
  filter :submitted_to_registrar, as: :select
  filter :last_reader_action_at,
         as: :date_range,
         label: I18n.t('activerecord.attributes.submission.last_reader_action_at',
                       timezone_label:)
  filter :last_registrar_action_at,
         as: :date_range,
         label: I18n.t('activerecord.attributes.submission.last_registrar_action_at',
                       timezone_label:)
  filter :ils_record_created_at,
         as: :date_range,
         label: I18n.t('activerecord.attributes.submission.ils_record_created_at',
                       timezone_label:)
  filter :ils_record_updated_at,
         as: :date_range,
         label: I18n.t('activerecord.attributes.submission.ils_record_updated_at',
                       timezone_label:)
  filter :accessioning_started_at,
         as: :date_range,
         label: I18n.t('activerecord.attributes.submission.accessioning_started_at',
                       timezone_label:)
  filter :created_at, as: :date_range, label: I18n.t('activerecord.attributes.submission.created_at', timezone_label:)
  filter :updated_at, as: :date_range, label: I18n.t('activerecord.attributes.submission.updated_at', timezone_label:)
  # IGNORING:
  # prefix, suffix, abstract
  # ps_career # ["Graduate", "Graduate School of Business", "Law"]
  # containscopyright # ["false", "true", nil]
  # sulicense  # ["true", nil]
  # provost, :readercomment, :regcomment
  # :documentaccess # yes / no?
  # citation_verified, abstract_provided, format_reviewed, dissertation_uploaded, supplemental_files_uploaded
  # permissions_provided, permission_files_uploaded, rights_selected, cc_license_selected, cclicense, cclicensetype

  # NOTE: These are the fields that are displayed as columns in the `form` view
  #       without any special behavior, e.g., TZ labeling.
  form_columns = %i[
    dissertation_id druid name prefix suffix major degree etd_type title
    folio_instance_hrid abstract sub sunetid ps_career ps_subplan
    provost degreeconfyr schoolname department readerapproval readercomment
    regapproval regcomment documentaccess
  ]

  member_action :resubmit_to_registrar, method: :post do
    # Re-post submission to Registrar (via PeopleSoft)
    submission = Submission.find_by(dissertation_id: params[:id])
    message = begin
                SubmissionPoster.call(submission:)
              rescue StandardError => e # rubocop:disable Layout/RescueEnsureAlignment
                "ETD did not re-post to Registrar: #{e.message}"
              else
                'ETD successfully re-posted to Registrar'
              end # rubocop:disable Layout/BeginEndAlignment
    redirect_to admin_submission_path(submission), notice: message
  end

  action_item :resubmit_to_registrar, only: :show do
    if submission.all_required_steps_complete? && Settings.peoplesoft.enabled
      link_to 'Re-post to registrar', resubmit_to_registrar_admin_submission_path(submission),
              method: :post,
              data: { confirm: 'Are you sure you want to re-post to the registrar?' }
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs do
      form_columns.each do |form_column|
        input form_column
      end
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

  show do
    attributes_table do
      row 'Druid (=> Argo)' do |submission|
        link_to submission.druid, "#{Settings.argo_url}/view/#{submission.druid}"
      end
      row 'Dissertation ID (=> /submit)' do |submission|
        link_to submission.dissertation_id, submission_path(submission)
      end
      row 'Folio Instance HRID (=> Searchworks)' do |submission|
        if submission.folio_instance_hrid
          link_to submission.folio_instance_hrid,
                  format(Settings.searchworks_uri,
                         catalog_record_id: submission.folio_instance_hrid)
        end
      end
      rows(
        *active_admin_config.resource_columns.without(
          :druid,
          :dissertation_id,
          :folio_instance_hrid,
          :submitted_at,
          :last_reader_action_at,
          :last_registrar_action_at,
          :ils_record_created_at,
          :ils_record_updated_at,
          :accessioning_started_at,
          :created_at,
          :updated_at
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
    end

    panel 'Readers' do
      table_for submission.readers do
        column 'id' do |reader|
          link_to reader.id, admin_reader_path(reader)
        end
        column :name
        column :readerrole
        column :finalreader
      end
    end

    panel 'Files' do
      table_for [submission.dissertation_file] + submission.supplemental_files do
        column 'file_name', &:filename
        column 'type', &:content_type
        column 'size', &:byte_size
      end
    end
  end
end
