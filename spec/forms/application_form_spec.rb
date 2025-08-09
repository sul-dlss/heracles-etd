# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationForm do
  describe '.model_name' do
    let(:test_form_class) { Class.new(described_class) }

    before do
      stub_const('TestForm', test_form_class)
    end

    it 'returns a model name without the "Form" suffix' do
      expect(TestForm.model_name).to eq('Test')
    end
  end

  describe '.immutable_attributes' do
    let(:test_form_class) { Class.new(described_class) }

    before do
      stub_const('TestForm', test_form_class)
    end

    it 'returns an empty array' do
      expect(TestForm.immutable_attributes).to be_empty
    end
  end

  describe '.user_editable_attributes' do
    let(:test_form_class) do
      Class.new(described_class) do
        attribute :foo, :string
        attribute :bar, array: true
        attribute :baz, :string

        def self.immutable_attributes
          [:baz]
        end
      end
    end

    before do
      stub_const('TestForm', test_form_class)
    end

    it 'returns attributes not declared as immutable' do
      expect(TestForm.user_editable_attributes).to eq([:foo, { bar: [] }])
    end
  end

  describe '.loggable_errors' do
    subject(:form) { TestForm.new }

    let(:test_form_class) do
      Class.new(described_class) do
        attribute :foo, :string
        validates :foo, presence: true, on: :submit
      end
    end

    before do
      stub_const('TestForm', test_form_class)
    end

    it 'returns an empty array when there are no errors' do
      expect(form.valid?).to be true
      expect(form.loggable_errors).to be_empty
    end

    it 'returns loggable errors when there are errors' do
      expect(form.valid?(:submit)).to be false
      expect(form.loggable_errors).to eq ['Test foo: blank']
    end
  end
end
