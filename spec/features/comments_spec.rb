require 'spec_helper'
require 'integration_helper'

feature 'comments', :js do
  # TODO feature for creating root-level comments
  # TODO feature for creating reply comments

  scenario 'User deletes a root-level comment' do
    project = create :active_project
    comment = create(:comment, commentable: project)
    login_as comment.user

    visit project_path comment.commentable
    click_on 'Comments'
    page.should have_content comment.body

    click_on 'delete'
    click_on 'Comments'
    page.should have_content 'Add a comment'
    page.should_not have_content comment.body
    page.should_not have_content "[comment deleted]"
  end
end
