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
  end

  module ClassMethods
  end

  module InstanceMethods
    
    def sold_hours
      @sold_hours ||= self.issues.sum(:sold_hours) || 0
    end
    
  end
end

unless Project.included_modules.include? RedmineRemainingTime::ProjectPatch
Project.send(:include, RedmineRemainingTime::ProjectPatch)
end
