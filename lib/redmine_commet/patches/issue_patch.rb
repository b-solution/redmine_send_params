require_dependency 'issue'
module  RedmineCommet
  module  Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          before_save :send_data_to_commet
          def send_data_to_commet
            webhooks = self.project.webhook_settings
            webhooks.each do |webhook|
              cfs = issue.visible_custom_field_values
              cfs_hash = cfs.inject({}){|hash, cf| hash[cf.custom_field.name]= cf.value; hash}
              params = {subject: self.subject }
              params.merge!(cfs_hash)

              if meet_saved_queries?
                if webhook.post?
                  send_post_webhook(params, webhook)
                else
                  send_get_webhook(params, webhook.url)
                end
              end
            end
          end

          def meet_saved_queries?
            IssueQuery.all.detect{|issue_query|
              issue_query.issue.map(&:id).include?(self.id)
            }.present?
          end

          def send_post_webhook(params, webhook)
            require 'net/http'
            url = webhook.url
            uri = URI(url)
            http = Net::HTTP.new(uri.host, uri.port)
            res = http.post(uri.host, params.to_json, {'Content-Type' =>'application/json'}) #uri.path was
            puts res.body
            if res.code == "200"
              return [true, res.code]
            else
              return [false, "Status for wenhook: #{res.code}"]
            end

          rescue StandardError=> e
            Rails.logger "Error #{e.message}"
          end

          def post_host
            uri = URI('https://www.google.tn/webhp?hl=fr#hl=fr')
            res = Net::HTTP.post_form(uri, 'q' => 'ruby', 'max' => '50')
            puts res.body
          end

          def send_get_webhook(params, url)
            uri = URI(url)
            uri.query = URI.encode_www_form(params)
            res = Net::HTTP.get_response(uri)
            puts res.body if res.is_a?(Net::HTTPSuccess)


          rescue StandardError=> e
            Rails.logger "Error #{e.message}"
          end

        end
      end
    end
  end
end
