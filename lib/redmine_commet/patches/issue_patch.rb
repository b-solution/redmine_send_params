require_dependency 'issue'
module  RedmineCommet
  module  Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          after_save :send_data_to_commet
          def send_data_to_commet
            webhooks = self.project.webhook_settings
            webhooks.each do |webhook|
              cfs = self.visible_custom_field_values
              cfs_hash = cfs.inject({}){|hash, cf| hash[cf.custom_field.name]= cf.value; hash}
              params = self.attributes
              params.merge!({
                  project_name: self.project.name,
                  author: self.author.name,
                  tracker: self.tracker.name
                            })
              params.merge!(cfs_hash)

              issue_query = webhook.issue_query

              if issue_query and issue_query.issues.map(&:id).include?(self.id)
                if webhook.post?
                  send_post_webhook(params, webhook.url)
                else
                  send_get_webhook(params, webhook.url)
                end
              end
            end
          rescue
            Rails.logger "Error Issue Webhook #{self.id}"
          end

          # def send_post_webhook(params, url)
          #   require 'net/http'
          #
          #   uri = URI(url)
          #   http = Net::HTTP.new(uri.host, uri.port)
          #   res = http.post(uri.host, params.to_json) #uri.path was
          #   puts res.body
          # rescue StandardError=> e
          #   Rails.logger "Error #{e.message}"
          # end

          def send_post_webhook(params, url)
            uri = URI(url) #'https://www.google.tn/webhp?hl=fr#hl=fr'
            res = Net::HTTP.post_form(uri, params)
            puts res.body
          rescue Exception=> e
            Rails.logger "Error #{e.message}"
          end

          def send_get_webhook(params, url)
            uri = URI(url)
            uri.query = URI.encode_www_form(params)
            res = Net::HTTP.get_response(uri)
            puts res.body if res.is_a?(Net::HTTPSuccess)


          rescue Exception=> e
            Rails.logger "Error #{e.message}"
          end

        end
      end
    end
  end
end
