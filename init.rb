Redmine::Plugin.register :redmine_clone_by_version do
  name 'Redmine Clone by Version'
  author 'Mauricio Camayo'
  description 'During test, we use to clone the test issues in order to confirm regresion. This plugin helps to clone from a given version (test) to the current version to multiple users'
  version '0.0.1'
  url 'https://github.com/mauricio-camayo/redmine_clone_by_version'
  author_url 'https://github.com/mauricio-camayo'
  
  settings :default => {'empty' => true}, :partial => 'settings/clone_version_settings'
  
  permission :clone_testing_issues, { :clone => :index }, :public => false
  menu :project_menu, :redmine_clone_by_version, {controller: 'clone', action: 'index'}, :caption => :permission_clone_testing_issues, :after => :issues, :param => :project_id
end
