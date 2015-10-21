Redmine::Plugin.register :redmine_remaining_time do
  name 'Redmine Remaining time'
  author 'Madeline Veyrenc'
  author_url 'https://github.com/mveyrenc'
  description 'This is add a fiels for remaining time for issue'
  version '0.3.4'
  requires_redmine :version_or_higher => '2.1.0'

  project_module :load_following do
    permission :view_load_following, { :load_following => [ :index ] }, :require => :member
  end
  
  menu :project_menu, :load_following, {:controller => 'load_following', :action => 'index'}, :caption => :project_module_load_following, :param => :project_id
  
end

require 'redmine_remaining_time'
