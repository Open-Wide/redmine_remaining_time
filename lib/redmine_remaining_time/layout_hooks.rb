include ContextMenusHelper

module RedmineRemainingTime
  module Hooks
    class LayoutHook < Redmine::Hook::ViewListener

      def view_issues_sidebar_planning_bottom(context={ })
        begin
          return '' if User.current.anonymous?

          project = context[:project]

          return '' unless project && !project.blank?

          sold_hours = project.issues.sum(:sold_hours)
          estimated_hours = project.issues.where('parent_id IS NULL').sum(:estimated_hours)
          remaining_hours = project.issues.where('parent_id IS NULL').sum(:remaining_hours)
          spent_time = project.time_entries.sum(:hours)
          if project && !project.descendants.active.empty?
            sold_hours += project.descendants.sum{ |p| p.issues.sum(:sold_hours) }
            estimated_hours += project.descendants.sum{ |p| p.issues.where('parent_id IS NULL').sum(:estimated_hours) }
            remaining_hours += project.descendants.sum{ |p| p.issues.where('parent_id IS NULL').sum(:remaining_hours) }
            spent_time += project.descendants.sum{ |p| p.time_entries.sum(:hours) }
          end
          delta_sold_time = remaining_hours + spent_time - sold_hours
          delta_estimated_time = remaining_hours + spent_time - estimated_hours
          # Why can't I access protect_against_forgery?
          return %{
            <div id="remaining_time_view_issues_sidebar">
              <h3>#{l(:project_times)}</h3>
              <ul>
                <li>#{l(:field_sold_hours)}: #{sold_hours}</li>
                <li>#{l(:field_estimated_hours)}: #{estimated_hours.round(2)}</li>
                <li>#{l(:field_remaining_hours)}: #{remaining_hours.round(2)}</li>
                <li>#{l(:label_spent_time)}: #{spent_time.round(2)}</li>
                <li>#{l(:label_delta_sold_time)}: #{delta_sold_time.round(2)}</li>
                <li>#{l(:label_delta_estimated_time)}: #{delta_estimated_time.round(2)}</li>
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
