class CloneController < ApplicationController
  unloadable

  def index
    @project = Project.find(params[:project_id])
    if Setting.plugin_redmine_clone_by_version.has_key?("target_version")
      @issues = Issue.where("fixed_version_id = " + Setting.plugin_redmine_clone_by_version['target_version'].at(0))
    else
      @issues = {}
    end
    if Setting.plugin_redmine_clone_by_version.has_key?("group")
      @users = User.find_all_by_type('User')
    else
      @users = User.where("type = 'User'").all
    end
  end
  
  def doclone
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
        @created_issues << clone
      end
    end
  end

end