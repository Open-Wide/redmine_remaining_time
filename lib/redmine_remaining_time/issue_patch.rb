require_dependency 'issue'

module RedmineRemainingTime
  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        Issue.safe_attributes 'remaining_hours', 'sold_hours'
        unloadable
        alias_method_chain :recalculate_attributes_for, :remaining_hours
        alias_method_chain :css_classes, :remaining_hours
        
        before_save :update_done_ratio_from_remaining_hours
      end

    end
  end

  module ClassMethods
  
    def self.use_status_for_done_ratio?
      false
    end
  end

  module InstanceMethods
  
    def total_hours
      @total_hours ||= ( self.total_spent_hours.to_f + self.remaining_hours.to_f ).round(2) || 0
    end
  
    def delta_hours
      @delta_hours ||= ( self.total_hours.to_f - self.estimated_hours.to_f ).round(2) || 0
    end
    
    def delta_hours_status
      if self.delta_hours.to_f > 0
        'less'
      elsif self.delta_hours.to_f < 0
        'more'
      else  
        'exact'
      end
    end
    
    def update_done_ratio_from_remaining_hours
      leaves_count = self.leaves.count
      if leaves_count > 0
        average = self.leaves.where("estimated_hours > 0").average(:estimated_hours).to_f
        if average == 0
          average = 1
        end
        done = self.leaves.joins(:status).
          sum("COALESCE(CASE WHEN estimated_hours > 0 THEN estimated_hours ELSE NULL END, #{average}) " +
            "* (CASE WHEN is_closed = #{connection.quoted_true} THEN 100 ELSE COALESCE(done_ratio, 0) END)").to_f
        progress = done / (average * leaves_count)
        self.done_ratio = progress.round
      else
        if self.remaining_hours.eql? 0.0
          self.done_ratio = 100
        else
          if ( self.total_hours ) != 0
            self.done_ratio = self.total_spent_hours.to_f / ( self.total_hours ) * 100
          else
            self.done_ratio = 0
          end
        end
      end
    end

    def recalculate_attributes_for_with_remaining_hours(issue_id)
      if issue_id && p = Issue.find_by_id(issue_id)
        # remaining = sum of leaves remaining
        p.remaining_hours = p.leaves.sum(:remaining_hours).to_f.round(2)
        p.remaining_hours = nil if p.remaining_hours == 0.0

        p.save(:validate => false)
      end
      recalculate_attributes_for_without_remaining_hours(issue_id)
    end
    
    def css_classes_with_remaining_hours(user=User.current)
      s = css_classes_without_remaining_hours( user )
      s << ' delta-hours-' + self.delta_hours_status
      s
    end
  end
end

unless Issue.included_modules.include? RedmineRemainingTime::IssuePatch
Issue.send(:include, RedmineRemainingTime::IssuePatch)
end
