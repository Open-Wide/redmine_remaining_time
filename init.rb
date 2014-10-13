Redmine::Plugin.register :redmine_remaining_time do
  name 'Redmine Remaining time'
  author 'Madeline Veyrenc'
  author_url 'https://github.com/mveyrenc'
  description 'This is add a fiels for remaining time for issue'
  version '0.6.3'
  requires_redmine :version_or_higher => '2.1.0'
end

require 'redmine_remaining_time'
