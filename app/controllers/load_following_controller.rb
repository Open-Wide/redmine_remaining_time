class LoadFollowingController < ApplicationController
  
  before_filter :find_project_by_project_id
  
  accept_api_auth :index
  
  def index
    @issues = @project.issues.where('parent_id IS NULL').all
    @subprojects = []
    @sum_sold_hours = @project.issues.sum(:sold_hours)
    @sum_estimated_hours = @project.issues.where('parent_id IS NULL').sum(:estimated_hours)
    @sum_remaining_hours = @project.issues.where('parent_id IS NULL').sum(:remaining_hours)
    @sum_spent_time = @project.time_entries.sum(:hours)
    if !@project.descendants.active.empty?
      subprojects = @project.descendants
      for subproject in subprojects
        @subprojects << {:project => subproject, :issues => subproject.issues.where('parent_id IS NULL').all} 
      end
      @sum_sold_hours += @project.descendants.sum{ |p| p.issues.sum(:sold_hours) }
      @sum_estimated_hours += @project.descendants.sum{ |p| p.issues.where('parent_id IS NULL').sum(:estimated_hours) }
      @sum_remaining_hours += @project.descendants.sum{ |p| p.issues.where('parent_id IS NULL').sum(:remaining_hours) }
      @sum_spent_time += @project.descendants.sum{ |p| p.time_entries.sum(:hours) }
    end
    if @project.descendants.active.empty?
    end
    @sum_total_hours = @sum_remaining_hours + @sum_spent_time
    @sum_delta_estimated_time = @sum_remaining_hours + @sum_spent_time - @sum_estimated_hours
    @sum_done_ration = @sum_spent_time / ( @sum_remaining_hours + @sum_spent_time ) * 100
  end

  def find_project_by_project_id
    if params[:project_id]
      @project = Project.find_by_identifier(params[:project_id])
      render_404 unless @project
    end
  end

end
