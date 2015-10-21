include ContextMenusHelper

module RedmineRemainingTime
  module Hooks
    class LayoutHook < Redmine::Hook::ViewListener

      def view_issues_sidebar_planning_bottom(context={ })
        begin
          return '' if User.current.anonymous?

          project = context[:project]

          return '' unless project && !project.blank?
          
          return %{
            <div id="remaining_time_view_issues_sidebar">
              <h3>#{l(:project_times)}</h3>
              <ul>
                <li>#{l(:field_sold_hours)}: #{l_hours(project.sold_hours)}</li>
                <li>#{l(:field_estimated_hours)}: #{l_hours(project.estimated_hours)}</li>
                <li>#{l(:field_remaining_hours)}: #{l_hours(project.remaining_hours)}</li>
                <li>#{l(:label_spent_time)}: #{l_hours(project.spent_hours)}</li>
                <li>#{l(:label_delta_estimated_time)}: #{l_hours(project.delta_hours)}</li>
              </ul>
            </div>
          }
        rescue => e
          exception(context, e)
          return ''
        end
      end


    end
  end
end
