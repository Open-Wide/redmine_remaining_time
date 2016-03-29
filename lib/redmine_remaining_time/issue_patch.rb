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

    module ClassMethods
  
      def self.use_status_for_done_ratio?
        false
      end
      
      def first_wday
        case Setting.start_of_week.to_i
        when 1
          @first_wday ||= (1 - 1)%7 + 1
        when 6
          @first_wday ||= (6 - 1)%7 + 1
        when 7
          @first_wday ||= (7 - 1)%7 + 1
        else
          @first_wday ||= (l(:general_first_day_of_week).to_i - 1)%7 + 1
        end
      end

      def last_wday
        @last_wday ||= (Issue.first_wday + 5)%7 + 1
      end
      
      def load_following_startdate
        date  = Date.today
        @load_following_startdate ||= date - date.wday - 7
      end
      
      def load_following_enddate
        date = Date.today
        @load_following_enddate ||= date - date.wday - 1
      end
    end

    module InstanceMethods
  
      def total_hours
        @total_hours ||= ( self.total_spent_hours.to_f + self.remaining_hours.to_f ) || 0
      end
      
      def delta_hours
        if self.leaf?
          @delta_hours ||= ( ( sold_hours.nil? and self.total_hours.nil? ) ? nil : ( self.total_hours.to_f - sold_hours.to_f ) ) || nil
        else
          @delta_hours ||= ( ( sold_hours.nil? and self.spent_hours == 0.0 ) ? nil : ( self.spent_hours.to_f - sold_hours.to_f ) ) || nil
        end
        if !@delta_hours.is_a? Float
          @delta_hours = nil
        end
        @delta_hours
      end
    
      def delta_hours_status
        if !self.delta_hours.is_a? Float
          'none'
        else
          if self.delta_hours.to_f > 0
            'less'
          elsif self.delta_hours.to_f < 0
            'more'
          else  
            'exact'
          end
        end
      end
  
      def lf_total_hours
        if !lf_spent_hours.nil? or !lf_remaining_hours.nil?
          @lf_total_hours ||= ( lf_spent_hours.to_f + lf_remaining_hours.to_f ) || nil
        end
        @lf_total_hours ||= nil
      end
  
      def lf_total_hours_previous_week
        if !lf_spent_hours_previous_week.nil? or !lf_remaining_hours_previous_week.nil?
          @lf_total_hours_previous_week ||= ( lf_spent_hours_previous_week.to_f + lf_remaining_hours_previous_week.to_f ) || nil
        end
        @lf_total_hours_previous_week ||= nil
      end
      
      def lf_spent_hours
        @lf_spent_hours ||= time_entries.where('spent_on <= ?', Issue.load_following_enddate).sum(:hours) || nil
        if children? and @lf_spent_hours == 0.0
          @lf_spent_hours = nil
        end
        @lf_spent_hours
      end
  
      def lf_spent_hours_previous_week
        @lf_spent_hours_previous_week ||= lf_spent_hours.to_f - lf_spent_hours_current_week.to_f || nil
        if children? and @lf_spent_hours_previous_week == 0.0
          @lf_spent_hours_previous_week = nil
        end
        @lf_spent_hours_previous_week
      end
  
      def lf_spent_hours_current_week
        @lf_spent_hours_current_week ||= time_entries.where('spent_on BETWEEN ? AND ?', Issue.load_following_startdate, Issue.load_following_enddate).sum(:hours) || nil
        if children? and @lf_spent_hours_current_week == 0.0
          @lf_spent_hours_current_week = nil
        end
        @lf_spent_hours_current_week
      end
      
      def lf_remaining_hours
        if children?
          @lf_emaining_hours_previous_week ||= nil
        else
          journal = JournalDetail.select(:value).joins(:journal).where( :journals => { :created_on => (Issue.load_following_startdate..Issue.load_following_enddate), :journalized_id => id, :journalized_type => 'Issue' }, :prop_key => 'remaining_hours' ).order( 'journals.created_on DESC' ).first
          if journal
            @lf_remaining_hours ||= journal.value || self.remaining_hours
          else
            @lf_remaining_hours ||= self.remaining_hours
          end
        end
        @lf_remaining_hours ||= nil
      end
  
      def lf_remaining_hours_previous_week
        if children?
          @lf_emaining_hours_previous_week ||= nil
        else
          journal = JournalDetail.select(:old_value).joins(:journal).where( :journals => { :created_on => (Issue.load_following_startdate..Issue.load_following_enddate), :journalized_id => id, :journalized_type => 'Issue' }, :prop_key => 'remaining_hours' ).order( 'journals.created_on ASC' ).first
          if journal
            @lf_emaining_hours_previous_week ||= journal.old_value || self.remaining_hours
          else
            @lf_emaining_hours_previous_week ||= self.remaining_hours
          end
        end
        @lf_emaining_hours_previous_week ||= nil
      end
    
      def lf_delta_hours_status
        if !lf_delta_hours.is_a? Float
          'none'
        else
          if lf_delta_hours.to_f > 0
            'less'
          elsif lf_delta_hours.to_f < 0
            'more'
          else  
            'exact'
          end
        end
      end
      
      def lf_delta_hours
        if self.leaf?
          @lf_delta_hours ||= ( ( sold_hours.nil? and lf_total_hours.nil? ) ? nil : ( lf_total_hours.to_f - sold_hours.to_f ) ) || nil
        else
          @lf_delta_hours ||= ( ( sold_hours.nil? and lf_spent_hours.nil? ) ? nil : ( lf_spent_hours.to_f - sold_hours.to_f ) ) || nil
        end
        if !@lf_delta_hours.is_a? Float
          @lf_delta_hours = nil
        end
        @lf_delta_hours
      end
      
      def lf_delta_hours_previous_week
        if self.leaf?
          @lf_delta_hours_previous_week ||= ( ( sold_hours.nil? and lf_total_hours_previous_week.nil? ) ? nil : ( lf_total_hours_previous_week.to_f - sold_hours.to_f ) ) || nil
        else
          @lf_delta_hours_previous_week ||= ( ( sold_hours.nil? and lf_spent_hours_previous_week.nil? ) ? nil : ( lf_spent_hours_previous_week.to_f - sold_hours.to_f ) ) || nil
        end
        if !@lf_delta_hours_previous_week.is_a? Float
          @lf_delta_hours_previous_week = nil
        end
        @lf_delta_hours_previous_week
      end
      
      def lf_delta_hours_current_week
        @lf_delta_hours_current_week ||= ( lf_delta_hours.nil? and lf_delta_hours_previous_week.nil? ) ? nil : ( lf_delta_hours.to_f - lf_delta_hours_previous_week.to_f ) || nil
      end
    
      def lf_done_ratio
        if lf_remaining_hours.nil? and lf_total_hours.nil? and lf_spent_hours.nil?
          @lf_done_ratio = nil
        elsif lf_remaining_hours.to_f.eql? 0.0
          @lf_done_ratio = 100
        else
          if ( lf_total_hours ) != 0
            @lf_done_ratio = lf_spent_hours.to_f / ( lf_total_hours ) * 100
          end
        end
        @lf_done_ratio ||= nil
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
          
          # priority = highest priority of children
          if priority_position = p.children.joins(:priority).maximum("#{IssuePriority.table_name}.position")
            p.priority = IssuePriority.find_by_position(priority_position)
          end

          # start/due dates = lowest/highest dates of children
          p.start_date = p.children.minimum(:start_date)
          p.due_date = p.children.maximum(:due_date)
          if p.start_date && p.due_date && p.due_date < p.start_date
            p.start_date, p.due_date = p.due_date, p.start_date
          end

          # done ratio = weighted average ratio of leaves
          unless Issue.use_status_for_done_ratio? && p.status && p.status.default_done_ratio
            leaves_count = p.leaves.count
            if leaves_count > 0
              average = p.leaves.where("estimated_hours > 0").average(:estimated_hours).to_f
              if average == 0
                average = 1
              end
              done = p.leaves.joins(:status).
                sum("COALESCE(CASE WHEN estimated_hours > 0 THEN estimated_hours ELSE NULL END, #{average}) " +
                  "* (CASE WHEN is_closed = #{connection.quoted_true} THEN 100 ELSE COALESCE(done_ratio, 0) END)").to_f
              progress = done / (average * leaves_count)
              p.done_ratio = progress.round
            end
          end

          # estimate = sum of leaves estimates
          p.estimated_hours = p.leaves.sum(:estimated_hours).to_f
          p.estimated_hours = nil if p.estimated_hours == 0.0

          # ancestors will be recursively updated
          p.save(:validate => false)
        end
      end
    
      def css_classes_with_remaining_hours(user=User.current)
        s = css_classes_without_remaining_hours( user )
        s << ' delta-hours-' + self.delta_hours_status
        s
      end
    end
  end
end

unless Issue.included_modules.include? RedmineRemainingTime::IssuePatch
  Issue.send(:include, RedmineRemainingTime::IssuePatch)
end
