class LoadFollowingController < ApplicationController
  
  before_filter :find_project_by_project_id
  
  helper :issues
  include IssuesHelper
  
  accept_api_auth :index
  
  def index
    @subprojects = []
    if Setting.display_subprojects_issues?
      @subprojects = @project.descendants
    end
  end

  def find_project_by_project_id
    if params[:project_id]
      @project = Project.find_by_identifier(params[:project_id])
      render_404 unless @project
    end
  end

end
