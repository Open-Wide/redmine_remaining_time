ActionDispatch::Reloader.to_prepare do  
  require_dependency 'redmine_remaining_time/issue_patch'
  require_dependency 'redmine_remaining_time/issue_query_patch'
#  require_dependency 'redmine_remaining_time/project_patch'
end

require_dependency 'redmine_remaining_time/views_layouts_hook'
require_dependency 'redmine_remaining_time/layout_hooks'