# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Dissertation Files
ActiveRecord::Base.connection.execute("INSERT INTO uploaded_files (file_name, type, label, created_at, updated_at) VALUES ('dissertation_gc000wz0001.pdf', 'DissertationFile', 'Dissertation for gc000wz0001', NOW(), NOW());")
result = ActiveRecord::Base.connection.execute("SELECT LASTVAL();")
new_id = result.first['lastval']
ActiveRecord::Base.connection.execute("INSERT INTO attachments (submission_id, uploaded_file_id, created_at, updated_at) VALUES (1, #{new_id}, NOW(), NOW());")
ActiveRecord::Base.connection.execute("INSERT INTO uploaded_files (file_name, type, label, created_at, updated_at) VALUES ('dissertation_tg000xw0005.pdf', 'DissertationFile', 'Dissertation for tg000xw0005', NOW(), NOW());")
result = ActiveRecord::Base.connection.execute("SELECT LASTVAL();")
new_id = result.first['lastval']
ActiveRecord::Base.connection.execute("INSERT INTO attachments (submission_id, uploaded_file_id, created_at, updated_at) VALUES (5, #{new_id}, NOW(), NOW());")
# ActiveRecord::Base.connection.execute("INSERT INTO uploaded_files (file_name, type, label) VALUES ('dissertation_sy000ww0006.pdf', 'DissertationFile', 'Dissertation for sy000ww0006');")

# Supplemental Files
ActiveRecord::Base.connection.execute("INSERT INTO uploaded_files (file_name, type, label, created_at, updated_at) VALUES ('supplemental_file_1_gc000wz0001.pdf', 'SupplementalFile', 'Supplemental File 1 for gc000wz0001', NOW(), NOW());")
result = ActiveRecord::Base.connection.execute("SELECT LASTVAL();")
new_id = result.first['lastval']
ActiveRecord::Base.connection.execute("INSERT INTO attachments (submission_id, uploaded_file_id, created_at, updated_at) VALUES (1, #{new_id}, NOW(), NOW());")
ActiveRecord::Base.connection.execute("INSERT INTO uploaded_files (file_name, type, label, created_at, updated_at) VALUES ('supplemental_file_2_gc000wz0001.pdf', 'SupplementalFile', 'Supplemental File 2 for gc000wz0001', NOW(), NOW());")
result = ActiveRecord::Base.connection.execute("SELECT LASTVAL();")
new_id = result.first['lastval']
ActiveRecord::Base.connection.execute("INSERT INTO attachments (submission_id, uploaded_file_id, created_at, updated_at) VALUES (1, #{new_id}, NOW(), NOW());")
ActiveRecord::Base.connection.execute("INSERT INTO uploaded_files (file_name, type, label, created_at, updated_at) VALUES ('supplemental_file_1_tg000xw0005.pdf', 'SupplementalFile', 'Supplemental File 1 for tg000xw0005', NOW(), NOW());")
result = ActiveRecord::Base.connection.execute("SELECT LASTVAL();")
new_id = result.first['lastval']
ActiveRecord::Base.connection.execute("INSERT INTO attachments (submission_id, uploaded_file_id, created_at, updated_at) VALUES (5, #{new_id}, NOW(), NOW());")
ActiveRecord::Base.connection.execute("INSERT INTO uploaded_files (file_name, type, label, created_at, updated_at) VALUES ('supplemental_file_2_tg000xw0005.pdf', 'SupplementalFile', 'Supplemental File 2 for tg000xw0005', NOW(), NOW());")
result = ActiveRecord::Base.connection.execute("SELECT LASTVAL();")
new_id = result.first['lastval']
ActiveRecord::Base.connection.execute("INSERT INTO attachments (submission_id, uploaded_file_id, created_at, updated_at) VALUES (5, #{new_id}, NOW(), NOW());")
# ActiveRecord::Base.connection.execute("INSERT INTO uploaded_files (file_name, type, label) VALUES ('supplemental_file_1_sy000ww0006.pdf', 'SupplementalFile', 'Supplemental for sy000ww0006');")

# Permission Files
ActiveRecord::Base.connection.execute("INSERT INTO uploaded_files (file_name, type, label, created_at, updated_at) VALUES ('permission_file_1_gc000wz0001.pdf', 'PermissionFile', 'Permission File 1 for gc000wz0001', NOW(), NOW());")
result = ActiveRecord::Base.connection.execute("SELECT LASTVAL();")
new_id = result.first['lastval']
ActiveRecord::Base.connection.execute("INSERT INTO attachments (submission_id, uploaded_file_id, created_at, updated_at) VALUES (1, #{new_id}, NOW(), NOW());")
ActiveRecord::Base.connection.execute("INSERT INTO uploaded_files (file_name, type, label, created_at, updated_at) VALUES ('permission_file_2_gc000wz0001.pdf', 'PermissionFile', 'Permission File 2 for gc000wz0001', NOW(), NOW());")
result = ActiveRecord::Base.connection.execute("SELECT LASTVAL();")
new_id = result.first['lastval']
ActiveRecord::Base.connection.execute("INSERT INTO attachments (submission_id, uploaded_file_id, created_at, updated_at) VALUES (1, #{new_id}, NOW(), NOW());")
ActiveRecord::Base.connection.execute("INSERT INTO uploaded_files (file_name, type, label, created_at, updated_at) VALUES ('permission_file_1_tg000xw0005.pdf', 'PermissionFile', 'Permission File 1 for tg000xw0005', NOW(), NOW());")
result = ActiveRecord::Base.connection.execute("SELECT LASTVAL();")
new_id = result.first['lastval']
ActiveRecord::Base.connection.execute("INSERT INTO attachments (submission_id, uploaded_file_id, created_at, updated_at) VALUES (5, #{new_id}, NOW(), NOW());")
ActiveRecord::Base.connection.execute("INSERT INTO uploaded_files (file_name, type, label, created_at, updated_at) VALUES ('permission_file_2_tg000xw0005.pdf', 'PermissionFile', 'Permission File 2 for tg000xw0005', NOW(), NOW());")
result = ActiveRecord::Base.connection.execute("SELECT LASTVAL();")
new_id = result.first['lastval']
ActiveRecord::Base.connection.execute("INSERT INTO attachments (submission_id, uploaded_file_id, created_at, updated_at) VALUES (5, #{new_id}, NOW(), NOW());")
# ActiveRecord::Base.connection.execute("INSERT INTO uploaded_files (file_name, type, label) VALUES ('permission_file_1_sy000ww0006.pdf', 'PermissionFile', 'Permission for sy000ww0006');")
