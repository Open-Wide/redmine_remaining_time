module RedmineRemainingTime
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      render_on :view_layouts_base_html_head,
                :partial => 'hook/base_html_header'
#      def view_layouts_base_html_head(context={})
#        return stylesheet_link_tag(:redmine_remaining_time, :plugin => 'redmine_remaining_time')
#        return javascript_link_tag('jquery.stickytableheaders.min', :plugin => 'redmine_remaining_time')
#        return javascript_link_tag(:redmine_remaining_time, :plugin => 'redmine_remaining_time')
#      end
    end
  end
end