# frozen_string_literal: true

# An active model for Creative Commons licenses.
class CreativeCommonsLicense
  include ActiveModel::Model

  attr_accessor :id, :name, :url, :code

  def self.all
    [
      new(id: '0', name: 'no Creative Commons license', url: nil),
      new(id: '1', name: 'CC Attribution license', url: 'https://creativecommons.org/licenses/by/3.0/legalcode',
          code: 'by'),
      new(id: '2', name: 'CC Attribution Share Alike license',
          url: 'https://creativecommons.org/licenses/by-sa/3.0/legalcode', code: 'by-sa'),
      new(id: '3', name: 'CC Attribution No Derivatives license',
          url: 'https://creativecommons.org/licenses/by-nd/3.0/legalcode', code: 'by-nd'),
      new(id: '4', name: 'CC Attribution Non-Commercial license',
          url: 'https://creativecommons.org/licenses/by-nc/3.0/legalcode', code: 'by-nc'),
      new(id: '5', name: 'CC Attribution Non-Commercial Share Alike license',
          url: 'https://creativecommons.org/licenses/by-nc-sa/3.0/legalcode', code: 'by-nc-sa'),
      new(id: '6', name: 'CC Attribution Non-Commercial No Derivatives license',
          url: 'https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode', code: 'by-nc-nd')
    ]
  end

  def self.find(id)
    all.find { |license| license.id == id }
  end
end
