# frozen_string_literal: true

# Migration to update the User model
# This migration renames the email column to email_address, drops the login and crypted_password
# columns, and adds orcid, name, and first_name columns.
# It is intended to align the User model with the current authentication patterns.
class UpdateUserModel < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :email, :email_address
    remove_column :users, :login
    remove_column :users, :crypted_password
    add_column :users, :orcid, :string
    add_column :users, :name, :string, null: false
    add_column :users, :first_name, :string, null: false
  end
end
