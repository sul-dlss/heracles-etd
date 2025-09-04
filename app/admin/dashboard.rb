# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    div do
      panel 'ETD Progress' do
        table do
          thead do
            tr do
              ['Last step processed', 'count'].each(&method(:th)) # rubocop:disable Performance/MethodObjectAsBlock
            end
          end
          tbody do
            tr do
              td 'Registered'
              td link_to(Submission.at_registered.count, "#{admin_submissions_path}?scope=registered")
            end
            tr do
              td 'Submitted (by student)'
              td link_to(Submission.at_submitted.count, "#{admin_submissions_path}?scope=submitted")
            end
            tr do
              td 'Reader approved'
              td link_to(Submission.at_reader_approved.count, "#{admin_submissions_path}?scope=reader_approved")
            end
            tr do
              td 'Registrar approved'
              td link_to(Submission.at_registrar_approved.count, "#{admin_submissions_path}?scope=registrar_approved")
            end
            tr do
              td 'Loaded into ILS ("check-marc" in etdSubmitWF)'
              td link_to(Submission.at_ils_loaded.count, "#{admin_submissions_path}?scope=loaded_into_ils")
            end
            tr do
              td 'Cataloged in ILS ("catalog-status" in etdSubmitWF)'
              td link_to(Submission.at_ils_cataloged.count, "#{admin_submissions_path}?scope=cataloged_in_ils")
            end
            tr do
              td 'Accessioning Started ("accessioning-started" in etdSubmitWF)'
              td link_to(Submission.at_accessioning_started.count,
                         "#{admin_submissions_path}?scope=accessioning_started")
            end
            tr do
              td 'Accessioning completed (not reported to ETD app)'
              td link_to('ETDs with status Accessioned in Argo',
                         "#{Settings.argo_url}/catalog?f[nonhydrus_apo_title_ssim][]=ETDs&f[processing_status_text_ssi][]=Accessioned") # rubocop:disable Layout/LineLength
            end
            tr do
              td 'Total number of ETDs in database'
              td link_to(Submission.count, admin_submissions_path)
            end
          end
        end
      end
      div do
        link_to('Argo workflow grid for ETDs registered via former ETD application',
                "#{Settings.argo_url}/report/workflow_grid?f%5Bnonhydrus_apo_title_ssim%5D%5B%5D=ETDs&f[processing_status_text_ssi][]=Registered") # rubocop:disable Layout/LineLength
      end
    end
  end
end
