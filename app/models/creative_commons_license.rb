# frozen_string_literal: true

# An active model for Creative Commons licenses.
class CreativeCommonsLicense
  include ActiveModel::Model

  attr_accessor :id, :name, :url, :code, :signature_text

  def image_path
    Rails.root.join('app', 'assets', 'images', image)
  end

  def image
    "cc_#{code.tr('-', '_')}.png"
  end

  def cc_license?
    id != '0'
  end

  def self.all
    [
      new(id: '0', name: 'no Creative Commons license', url: nil),
      new(id: '1', name: 'CC Attribution license', url: 'https://creativecommons.org/licenses/by/4.0/legalcode',
          code: 'by', signature_text: '4.0 International License'),
      new(id: '2', name: 'CC Attribution Share Alike license',
          signature_text: 'Share Alike 4.0 International License',
          url: 'https://creativecommons.org/licenses/by-sa/4.0/legalcode', code: 'by-sa'),
      new(id: '3', name: 'CC Attribution No Derivatives license',
          signature_text: 'No Derivative Works 4.0 International License',
          url: 'https://creativecommons.org/licenses/by-nd/4.0/legalcode', code: 'by-nd'),
      new(id: '4', name: 'CC Attribution Non-Commercial license',
          signature_text: 'Noncommercial 4.0 International License',
          url: 'https://creativecommons.org/licenses/by-nc/4.0/legalcode', code: 'by-nc'),
      new(id: '5', name: 'CC Attribution Non-Commercial Share Alike license',
          url: 'https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode', code: 'by-nc-sa',
          signature_text: 'Noncommercial-Share Alike 4.0 International License'),
      new(id: '6', name: 'CC Attribution Non-Commercial No Derivatives license',
          url: 'https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode', code: 'by-nc-nd',
          signature_text: 'Noncommercial-No Derivative Works 4.0 International License')
    ]
  end

  def self.find(id)
    all.find { |license| license.id == id }
  end
end
