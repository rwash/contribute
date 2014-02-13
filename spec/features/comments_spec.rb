require 'spec_helper'
require 'integration_helper'

feature 'comments', :js do
  scenario 'User creates a comment' do
    project = create :active_project
    comment = build :comment
    login_as create :user

    visit project_path project
    fill_in :comment_body, with: comment.body
    click_on "Post Comment"

    page.should have_content comment.body
  end

  scenario 'User deletes a comment' do
    project = create :active_project
    comment = create(:comment, project: project)
    login_as comment.user

    visit project_path comment.project
    page.should have_content comment.body

    click_on 'delete'
    page.should have_content 'Add a comment'
    page.should_not have_content comment.body
    page.should_not have_content "[comment deleted]"
  end
end
