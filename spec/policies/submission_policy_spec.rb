# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubmissionPolicy do
  let(:policy) { described_class.new(submission, user:) }
  let(:submission) { create(:submission, :with_readers, *submission_args) }
  let(:submission_args) { [] }
  let(:user) { User.new(remote_user: "#{submission.sunetid}@example.edu") }

  describe '#preview?' do
    it 'is an alias of :show?' do
      expect(:preview?).to be_an_alias_of(policy, :show?)
    end
  end

  describe '#edit?' do
    it 'is an alias of :update?' do
      expect(:edit?).to be_an_alias_of(policy, :update?)
    end
  end

  describe '#submit?' do
    it 'is an alias of :update?' do
      expect(:submit?).to be_an_alias_of(policy, :update?)
    end
  end

  describe '#review?' do
    it 'is an alias of :update?' do
      expect(:review?).to be_an_alias_of(policy, :update?)
    end
  end

  describe '#attach_supplemental_files?' do
    it 'is an alias of :update?' do
      expect(:attach_supplemental_files?).to be_an_alias_of(policy, :update?)
    end
  end

  describe '#show?' do
    subject { policy.apply(:show?) }

    context 'when user is the author' do
      it { is_expected.to be true }
    end

    context 'when user is in the DLSS group' do
      let(:user) { User.new(remote_user: 'random@example.edu', groups: [Settings.groups.dlss]) }

      it { is_expected.to be true }
    end

    context 'when user is in the registrar group' do
      let(:user) { User.new(remote_user: 'random@example.edu', groups: [Settings.groups.registrar]) }

      it { is_expected.to be true }
    end

    context 'when user is neither the author nor in any admin groups' do
      let(:user) { User.new(remote_user: 'random@example.edu') }

      it { is_expected.to be false }
    end

    context 'when user is a reader for the paper and it has not been submitted' do
      let(:user) { User.new(remote_user: "#{submission.readers.first.sunetid}@example.edu") }

      it { is_expected.to be false }
    end

    context 'when user is a reader for the paper and it has been submitted' do
      let(:submission_args) { [:submitted] }
      let(:user) { User.new(remote_user: "#{submission.readers.first.sunetid}@example.edu") }

      it { is_expected.to be true }
    end
  end

  describe '#update?' do
    subject { policy.apply(:update?) }

    context 'when user is the author' do
      it { is_expected.to be true }

      context 'with an already submitted submission' do
        let(:submission_args) { [:submitted] }

        it { is_expected.to be false }
      end
    end

    context 'when user is in the DLSS group' do
      let(:user) { User.new(remote_user: 'random@example.edu', groups: [Settings.groups.dlss]) }

      it { is_expected.to be false }
    end

    context 'when user is in the registrar group' do
      let(:user) { User.new(remote_user: 'random@example.edu', groups: [Settings.groups.registrar]) }

      it { is_expected.to be false }

      context 'with the uat environment' do
        before do
          allow(Honeybadger).to receive(:config).and_return({ env: 'uat' })
        end

        it { is_expected.to be true }

        context 'with an already submitted submission' do
          let(:submission_args) { [:submitted] }

          it { is_expected.to be false }
        end
      end
    end

    context 'when user is neither the author nor the registrar' do
      let(:user) { User.new(remote_user: 'random@example.edu') }

      it { is_expected.to be false }
    end

    context 'when user is a reader for the paper and it has not been submitted' do
      let(:user) { User.new(remote_user: "#{submission.readers.first.sunetid}@example.edu") }

      it { is_expected.to be false }
    end

    context 'when user is a reader for the paper and it has been submitted' do
      let(:submission_args) { [:submitted] }
      let(:user) { User.new(remote_user: "#{submission.readers.first.sunetid}@example.edu") }

      it { is_expected.to be false }
    end
  end

  describe '#reader_review?' do
    subject { policy.apply(:reader_review?) }

    context 'when user is the author' do
      it { is_expected.to be false }
    end

    context 'when user is in the DLSS group' do
      let(:user) { User.new(remote_user: 'random@example.edu', groups: [Settings.groups.dlss]) }

      it { is_expected.to be true }
    end

    context 'when user is in the registrar group' do
      let(:user) { User.new(remote_user: 'random@example.edu', groups: [Settings.groups.registrar]) }

      it { is_expected.to be true }
    end

    context 'when user is neither the author nor in any admin groups' do
      let(:user) { User.new(remote_user: 'random@example.edu') }

      it { is_expected.to be false }
    end

    context 'when user is a reader for the paper' do
      let(:user) { User.new(remote_user: "#{submission.readers.first.sunetid}@example.edu") }

      it { is_expected.to be true }
    end
  end
end
