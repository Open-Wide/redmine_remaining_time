require_dependency 'issue_query'

module RedmineRemainingTime
  module IssueQueryPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        base.add_available_column(QueryColumn.new(:remaining_hours, :sortable => "#{Issue.table_name}.remaining_hours"))
        base.add_available_column(QueryColumn.new(:total_spent_hours,
            :sortable => "COALESCE((SELECT SUM(hours) FROM #{TimeEntry.table_name} time_entry LEFT JOIN #{Issue.table_name} child_issue ON time_entry.issue_id = child_issue.id WHERE #{TimeEntry.table_name}.issue_id = #{Issue.table_name}.id OR child_issue.parent_id IS NOT NULL), 0)",
            :default_order => 'desc',
            :caption => :label_total_spent_time
          ))
        base.add_available_column(QueryColumn.new(:total_hours,
            :sortable => "COALESCE((SELECT SUM(hours) FROM #{TimeEntry.table_name} time_entry LEFT JOIN #{Issue.table_name} child_issue ON time_entry.issue_id = child_issue.id WHERE #{TimeEntry.table_name}.issue_id = #{Issue.table_name}.id OR child_issue.parent_id IS NOT NULL), 0) - #{Issue.table_name}.remaining_hours",
            :default_order => 'desc',
            :caption => :label_total_time
          ))
      end
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
      
end

unless IssueQuery.included_modules.include? RedmineRemainingTime::IssueQueryPatch
  IssueQuery.send(:include, RedmineRemainingTime::IssueQueryPatch)
end