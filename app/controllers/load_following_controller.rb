class LoadFollowingController < ApplicationController
  
  before_filter :find_project_by_project_id
  
  helper :issues
  include IssuesHelper
  
  accept_api_auth :index
  
  def index
    @rows = @project.issues.order("#{Issue.table_name}.root_id", "#{Issue.table_name}.lft ASC")
    if Setting.display_subprojects_issues?
      for subproject in @project.descendants
        @rows << subproject
        @rows += subproject.issues.order("#{Issue.table_name}.root_id", "#{Issue.table_name}.lft ASC")
      end
    end
  end

  def find_project_by_project_id
    if params[:project_id]
      @project = Project.find_by_identifier(params[:project_id])
      render_404 unless @project
    end
  end

end
