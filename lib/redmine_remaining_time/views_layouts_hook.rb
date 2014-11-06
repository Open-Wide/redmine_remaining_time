module RedmineRemainingTime
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        return stylesheet_link_tag(:redmine_remaining_time, :plugin => 'redmine_remaining_time')
      end
    end
  end
end