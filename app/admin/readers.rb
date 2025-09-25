# frozen_string_literal: true

ActiveAdmin.register Reader do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  permit_params :name, :prefix, :readerrole, :type, :suffix, :sunetid, :position, :finalreader, :submission_id
  # deliberately not including:  :univid
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :prefix, :suffix, :sunetid, :readerrole, :finalreader, :type, :position]
  #   permitted << :submission_id if (params[:action] == 'index' || params[:action] == 'show') && current_user.admin?
  #   permitted
  # end

  timezone_label = Time.zone.now.strftime('%Z')

  # filters: ordering / selecting
  filter :submission, label: 'Submission (Author)'
  filter :name, label: I18n.t('activerecord.attributes.reader.name')
  filter :sunetid
  filter :readerrole, as: :select, label: I18n.t('activerecord.attributes.reader.readerrole')
  filter :finalreader, as: :select, label: I18n.t('activerecord.attributes.reader.finalreader')
  filter :type, as: :select, label: I18n.t('activerecord.attributes.reader.type')
  filter :position
  filter :created_at, as: :date_range, label: I18n.t('activerecord.attributes.reader.created_at', timezone_label:)
  filter :updated_at, as: :date_range, label: I18n.t('activerecord.attributes.reader.updated_at', timezone_label:)

  index download_links: false do
    id_column
    %i[name sunetid readerrole finalreader type position].each do |index_column|
      column index_column
    end
    column 'Submission (Author)', sortable: :submission_id do |reader|
      link_to reader.submission.dissertation_id, admin_submission_path(reader.submission)
    end
    actions
  end

  show do
    attributes_table do
      %i[name prefix suffix sunetid readerrole finalreader type position].each { |r| row r }
      row 'Submission (dissertation ID)' do |reader|
        link_to reader.submission.dissertation_id, admin_submission_path(reader.submission)
      end
      row 'Created At', :created_at
      row 'Last Updated At', :updated_at
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs do
      %i[name prefix suffix sunetid].each do |form_column|
        input form_column
      end
      input :readerrole,
            label: 'Role',
            as: :select,
            collection: Reader::ADVISOR_ROLES + Reader::NON_ADVISOR_ROLES
      input :finalreader, label: 'Final Reader', as: :select, collection: %w[Yes No]
      input :type, as: :select, collection: %w[int ext]
      input :position, label: 'Position in list of Readers'
      input :submission_id, label: 'Submission (ETD database id)'
    end
    f.actions # adds the 'Submit' and 'Cancel' buttons
  end
end
