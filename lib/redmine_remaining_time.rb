ActionDispatch::Reloader.to_prepare do  
  require_dependency 'redmine_remaining_time/issue_patch'
  require_dependency 'redmine_remaining_time/issue_query_patch'
end

require_dependency 'redmine_remaining_time/views_layouts_hook'