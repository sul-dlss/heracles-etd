# frozen_string_literal: true

# Decorator for Submission that provides methods to help determine when steps are done.
class SubmissionPresenter < SimpleDelegator
  def initialize(submission:)
    super(submission)
  end

  def step_done?(step)
    public_send("step#{step}_done?")
  end

  def all_done?
    # All done excluding step 7
    @all_done ||= (1..6).all? { |step| step_done?(step) }
  end

  def step1_done?
    citation_verified == 'true'
  end

  def step2_done?
    abstract_provided == 'true'
  end

  def step3_done?
    format_reviewed == 'true'
  end

  def step4_done?
    true
  end

  def step5_done?
    true
  end

  def step6_done?
    rights_selected == 'true'
  end

  def step7_done?
    submitted_at.present?
  end
end
