require_dependency 'document'
module  RedmineCommet
  module  Patches
    module DocumentPatch
      def self.included(base)
        base.class_eval do
          after_save :send_data_to_commet

          def send_data_to_commet
            webhook = self.project.webhook_settings.where(send_document: true).first

            if webhook
              require 'net/http'
              url = webhook.url
              uri = URI(url)
              params= {title: self.title,
                       body: self.description,
                       url: document_path(self) ,
                       createdAt: self.created_on}.to_json
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
