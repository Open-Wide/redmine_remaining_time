require_dependency 'project'

module RedmineRemainingTime
  module ProjectPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def sold_hours
        if Setting.display_subprojects_issues?
          @sold_hours ||= self_and_descendants.sum{ |p| p.issues.sum(:sold_hours) } || 0
        else
          @sold_hours ||= issues.sum(:sold_hours) || 0
        end
      end
      
      def estimated_hours
        if Setting.display_subprojects_issues?
          @estimated_hours ||= self_and_descendants.sum{ |p| p.issues.where('parent_id IS NULL').sum(:estimated_hours) } || 0
        else
          @estimated_hours ||= issues.where('parent_id IS NULL').sum(:estimated_hours) || 0
        end
      end
      
      def remaining_hours
        if Setting.display_subprojects_issues?
          @remaining_hours ||= self_and_descendants.sum{ |p| p.issues.where('parent_id IS NULL').sum(:remaining_hours) } || 0
        else
          @remaining_hours ||= issues.where('parent_id IS NULL').sum(:remaining_hours) || 0
        end
      end
  
      def remaining_hours_previous_week
        @remaining_hours_previous_week ||= nil
      end
      
      def spent_hours
        if Setting.display_subprojects_issues?
          @spent_hours ||= self_and_descendants.sum{ |p| p.time_entries.sum(:hours) } || 0
        else
          @spent_hours ||= time_entries.sum(:hours) || 0
        end
      end
  
      def spent_hours_previous_week
        @spent_hours_previous_week ||= spent_hours - spent_hours_current_week || 0
      end
  
      def spent_hours_current_week
        if Setting.display_subprojects_issues?
          @spent_hours_current_week ||= self_and_descendants.sum{ |p| p.time_entries.where('spent_on >= ?', Issue.currentw_startdate).sum(:hours) } || 0
        else
          @spent_hours_current_week ||= time_entries.where('spent_on >= ?', Issue.currentw_startdate).sum(:hours) || 0
        end
      end
      
      def total_hours
          @total_hours ||= remaining_hours + spent_hours || 0
      end 
      
      def delta_hours
          @delta_hours ||= total_hours - estimated_hours || 0
      end
      
      def delta_hours_previous_week
        @delta_hours_previous_week ||= nil
      end
      
      def delta_hours_current_week
        @delta_hours_current_week ||=nil
      end
      
      def done_ratio
        if Setting.display_subprojects_issues?
          @done_ratio ||= self_and_descendants.sum{ |p| p.issues.where('parent_id IS NULL').sum(:done_ratio) } / self_and_descendants.sum{ |p| p.issues.where('parent_id IS NULL').count } || 0
        else
          @done_ratio ||= issues.where('parent_id IS NULL').sum(:done_ratio) / issues.where('parent_id IS NULL').count || 0
        end
      end
    end
  end
end

unless Project.included_modules.include? RedmineRemainingTime::ProjectPatch
  Project.send(:include, RedmineRemainingTime::ProjectPatch)
end
