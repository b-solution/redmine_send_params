require_dependency 'wiki'
module  RedmineCommet
  module  Patches
    module WikiPatch
      def self.included(base)
        base.class_eval do
          after_save :send_data_to_commet

          def send_data_to_commet
            webhook = self.project.webhook_settings.where(send_wiki: true).first

            if webhook
              require 'net/http'
              url = webhook.url
              uri = URI(url)
              params = {title: '',
                        body: '',
                        url: '',
                        createdAt: '',
                        type: 'Wiki'
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
