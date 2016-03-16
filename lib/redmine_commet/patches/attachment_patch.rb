require_dependency 'issue'
module  RedmineCommet
  module  Patches
    module AttachmentPatch
      def self.included(base)
        base.class_eval do
          after_save :send_data_to_commet

          def send_data_to_commet
            return if self.container.nil?
            require 'base64'
            webhook = self.container.project.webhook_settings.where(send_file: true).first

            if webhook
              require 'net/http'
              url = webhook.url
              uri = URI(url)
              path = "#{Setting.plugin_redmine_commet[:redmine_domain]}#{Rails.application.routes.url_helpers.attachment_path(self)}"
              diff = File.new(self.diskfile, "rb")

              params = {title: self.filename,
                        body: Base64.encode64(diff.read),
                        url: path,
                        createdAt: self.created_on,
                        type: 'Attachment'
              }
              res = Net::HTTP.post_form(uri, params)
              puts res.body
            end

          rescue StandardError=> e
            return puts e.message
          end

        end
      end
    end
  end
end
