Redmine::Plugin.register :redmine_send_params do
  name 'Redmine send params plugin'
  author 'Bilel KEDIDI'
  description 'This is a plugin for Redmine that send created issue with CFs that meet saved queries'
  version '0.0.1'

  project_module :redmine_send_params do
    permission :manage_urls,
               :webhook_settings => [:index, :new, :create,
                                     :show, :edit, :update, :destroy],
               :require => :member
  end

  menu :project_menu, :redmine_send_params,
       { :controller => 'webhook_settings', :action => 'index' },
       :caption => 'Commet webhooks', :after => :activity, :param => :project_id
end

Rails.application.config.to_prepare do
  Issue.send(:include, RedmineCommet::Patches::IssuePatch)
  Project.send(:include, RedmineCommet::Patches::ProjectPatch)

end
