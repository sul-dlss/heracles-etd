# frozen_string_literal: true

# Temporary model for a submission
class Submission
  include ActiveModel::API

  attr_accessor :name, :dissertation_id, :schoolname, :department, :degree, :major, :degreeconfyr, :title, :abstract

  def first_name
    name.split(', ').last
  end

  def id
    dissertation_id
  end

  def persisted?
    true
  end
  # t.string "druid", null: false
  #   t.string "name"
  #   t.string "prefix"
  #   t.string "suffix"
  #   t.string "major"
  #   t.string "degree"
  #   t.string "advisor"
  #   t.string "etd_type", null: false
  #   t.string "title"
  #   t.text "abstract"
  #   t.string "containscopyright"
  #   t.string "sulicense"
  #   t.string "cclicense"
  #   t.string "cclicensetype"
  #   t.string "embargo"
  #   t.string "external_visibility"
  #   t.string "term"
  #   t.string "sub"
  #   t.string "univid"
  #   t.string "sunetid", null: false
  #   t.string "ps_career"
  #   t.string "ps_program"
  #   t.string "ps_plan"
  #   t.string "ps_subplan"
  #   t.string "dissertation_id", null: false
  #   t.string "provost"
  #   t.string "degreeconfyr"
  #   t.string "schoolname"
  #   t.string "department"
  #   t.string "readerapproval"
  #   t.string "readercomment"
  #   t.string "readeractiondttm"
  #   t.string "regapproval"
  #   t.string "regcomment"
  #   t.string "regactiondttm"
  #   t.string "documentaccess"
  #   t.string "submit_date"
  #   t.string "citation_verified"
  #   t.string "abstract_provided"
  #   t.string "dissertation_uploaded"
  #   t.string "supplemental_files_uploaded"
  #   t.string "permissions_provided"
  #   t.string "permission_files_uploaded"
  #   t.string "rights_selected"
  #   t.string "cc_license_selected"
  #   t.string "submitted_to_registrar"
  #   t.datetime "created_at", precision: nil, null: false
  #   t.datetime "updated_at", precision: nil, null: false
  #   t.string "format_reviewed"
  #   t.datetime "submitted_at", precision: nil
  #   t.string "catkey"
  #   t.datetime "last_registrar_action_at", precision: nil
  #   t.datetime "last_reader_action_at", precision: nil
  #   t.datetime "ils_record_updated_at", precision: nil
  #   t.datetime "accessioning_started_at", precision: nil
  #   t.string "folio_instance_hrid"
  #   t.datetime "ils_record_created_at"
end
