class CloneController < ApplicationController
  unloadable

  
  helper :issues
  helper :projects
  include ProjectsHelper
  helper :custom_fields
  include CustomFieldsHelper
  helper :issue_relations
  include IssueRelationsHelper
  helper :queries
  include QueriesHelper
  helper :sort
  include SortHelper
  include IssuesHelper
  
  def index
    #    javascript_include_tag('context_menu')
      
    @project = Project.find(params[:project_id])
    retrieve_query
    @issues = @query.issues
    if Setting.plugin_redmine_clone_by_version.has_key?("group")
      @users = User.status('1').in_group(Setting.plugin_redmine_clone_by_version["group"].at(0))
    else
      @users = User.where("type = 'User' and status = '1'").all
    end
    
    if params[:commit] == 'doclone'
      if !params['user_ids'] || params['user_ids'].count < 1 || !params['issue_ids'] || params['issue_ids'].count < 1
        flash.now[:error] = l(:selection_error)
      else
        @created_issues = Array.new
        if Setting.plugin_redmine_clone_by_version.has_key?("new_status")
          status = IssueStatus.find(Setting.plugin_redmine_clone_by_version['new_status'].at(0))
        else
          status = IssueStatus.find(1)
        end
        for u in params["user_ids"] 
          user = User.find(u.to_i)
          for i in params["issue_ids"]
            issue = Issue.find(i.to_i)
            clone = issue.dup
            clone.assigned_to = user
            clone.status = status
            clone.done_ratio = 0
            clone.closed_on = ""
            clone.author = User.current
            clone.fixed_version = Version.find(params["target_version"].at(0).to_i)
            clone.save
            clone.relations_from ||= []
            for j in issue.relations_from
              related = IssueRelation.find(j).dup
              related.issue_from_id = clone.id
              related.save
              clone.relations_from << related
            end
            for j in issue.relations_to
              related = IssueRelation.find(j).dup
              related.issue_to_id = clone.id
              related.save
              clone.relations_to << related
            end
            clone.save
            @created_issues << clone
          end
        end
        flash[:notice] = "#{@created_issues.count}" + l(:issues_cloned)
        @issues = @created_issues
      end
    end
  end

  private
  def retrieve_query

    if params[:set_filter] || session[:clone_query].nil? || session[:clone_query][:project_id] != (@project ? @project.id : nil)
      # Give it a name, required to be valid
      @query = CloneQuery.new(:name => "_")
      @query.project = @project
      @query.build_from_params(params)
      session[:clone_query] = {:project_id => @query.project_id,
        :filters => @query.filters,
        :group_by => @query.group_by,
        :column_names => @query.column_names}
    else
      # retrieve from session
      @query = CloneQuery.new(:name => "_",
        :filters => session[:clone_query][:filters] || session[:agile_query][:filters],
        :group_by => session[:clone_query][:group_by],
        :column_names => session[:clone_query][:column_names]
      )
      @query.project = @project
    end
    @chart = params[:chart] || "issues_burndown"
  end
end