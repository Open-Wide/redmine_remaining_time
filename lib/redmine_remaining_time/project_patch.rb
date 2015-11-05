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
      
      def spent_hours
        if Setting.display_subprojects_issues?
          @spent_hours ||= self_and_descendants.sum{ |p| p.time_entries.sum(:hours) } || 0
        else
          @spent_hours ||= time_entries.sum(:hours) || 0
        end
        @spent_hours ||= nil
      end
      
      def total_hours
        @total_hours ||= remaining_hours + spent_hours || 0
      end 
      
      def delta_hours
        @delta_hours ||= total_hours - sold_hours || 0
      end
      
      def done_ratio
        if Setting.display_subprojects_issues?
          @done_ratio ||= self_and_descendants.sum{ |p| p.issues.where('parent_id IS NULL').sum(:done_ratio) } / self_and_descendants.sum{ |p| p.issues.where('parent_id IS NULL').count } || 0
        else
          @done_ratio ||= issues.where('parent_id IS NULL').sum(:done_ratio) / issues.where('parent_id IS NULL').count || 0
        end
      end
      
      def lf_spent_hours
        @lf_spent_hours ||= lf_spent_hours_previous_week + lf_spent_hours_current_week
      end
      
      def lf_total_hours
        @lf_total_hours ||= lf_remaining_hours.to_f + lf_spent_hours.to_f || 0
      end 
  
      def lf_spent_hours_previous_week
        if Setting.display_subprojects_issues?
          @lf_spent_hours_previous_week ||= self_and_descendants.sum{ |p| p.issues.sum{ |i| i.lf_spent_hours_previous_week.to_f } } || 0
        else
          @lf_spent_hours_previous_week ||= issues.sum{ |i| i.lf_spent_hours_previous_week.to_f } || 0
        end
        @lf_spent_hours_previous_week ||= nil
      end
  
      def lf_spent_hours_current_week
        if Setting.display_subprojects_issues?
          @lf_spent_hours_current_week ||= self_and_descendants.sum{ |p| p.issues.sum{ |i| i.lf_spent_hours_current_week.to_f } } || 0
        else
          @lf_spent_hours_current_week ||= issues.sum{ |i| i.lf_spent_hours_current_week.to_f } || 0
        end
        @lf_spent_hours_current_week ||= nil
      end
  
      def lf_remaining_hours
        if Setting.display_subprojects_issues?
          @lf_remaining_hours ||= self_and_descendants.sum{ |p| p.issues.sum{ |i| i.lf_remaining_hours.to_f } } || 0
        else
          @lf_remaining_hours ||= issues.sum{ |i| i.lf_remaining_hours.to_f } || 0
        end
        @lf_remaining_hours ||= nil
      end
      
      def lf_remaining_hours_previous_week
        if Setting.display_subprojects_issues?
          @lf_remaining_hours_previous_week ||= self_and_descendants.sum{ |p| p.issues.sum{ |i| i.lf_remaining_hours_previous_week.to_f } } || 0
        else
          @lf_remaining_hours_previous_week ||= issues.sum{ |i| i.lf_remaining_hours_previous_week.to_f } || 0
        end
        @lf_remaining_hours_previous_week ||= nil
      end
      
      def lf_delta_hours
        if Setting.display_subprojects_issues?
          @lf_delta_hours ||= self_and_descendants.sum{ |p| p.issues.sum{ |i| i.lf_delta_hours.to_f } } || 0
        else
          @lf_delta_hours ||= issues.sum{ |i| i.lf_delta_hours.to_f } || 0
        end
        @lf_delta_hours ||= nil
      end
      
      def lf_delta_hours_previous_week
        @lf_delta_hours_previous_week ||= lf_delta_hours - lf_delta_hours_current_week || nil
      end
      
      def lf_delta_hours_current_week
        if Setting.display_subprojects_issues?
          @lf_delta_hours_current_week ||= self_and_descendants.sum{ |p| p.issues.sum{ |i| i.lf_delta_hours_current_week.to_f } } || 0
        else
          @lf_delta_hours_current_week ||= issues.sum{ |i| i.lf_delta_hours_current_week.to_f } || 0
        end
        @lf_delta_hours_current_week ||= nil
      end
      
      def lf_done_ratio
        if lf_remaining_hours.to_f.eql? 0.0
          @lf_done_ratio = 100
        else
          if ( lf_total_hours ) != 0
            @lf_done_ratio = lf_spent_hours.to_f / ( lf_total_hours ) * 100
          end
        end
        @lf_done_ratio ||= nil
      end
    end
  end
end

unless Project.included_modules.include? RedmineRemainingTime::ProjectPatch
  Project.send(:include, RedmineRemainingTime::ProjectPatch)
end
