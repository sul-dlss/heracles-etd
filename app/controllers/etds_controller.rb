# frozen_string_literal: true

# Controller for ETD endpoints used by Peoplesoft to transfer data to the ETD system
class EtdsController < ApplicationController
  # TODO: Establish token-based authentication for these endpoint
  skip_verify_authorized only: :index

  # GET /etds
  # only here for peoplesoft ping
  def index
    render html: 'OK'
  end

  def create; end
end
