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

  scenario 'User destroys a root-level comment with replies' do
    project = create :active_project
    root_comment = create(:comment, commentable: project)
    nested_comment = create(:comment, commentable: project, parent: root_comment, body: "Nested Comment")
    login_as root_comment.user

    visit project_path root_comment.commentable
    click_on 'Comments'
    page.should have_content root_comment.body

    click_on 'delete'
    click_on 'Comments'
    page.should have_content 'Add a comment'
    page.should_not have_content root_comment.body
    page.should have_content "[comment deleted]"
  end

  scenario 'User destroys a nested comment' do
    project = create :active_project
    root_comment = create(:comment, commentable: project)
    nested_comment = create(:comment, commentable: project, parent: root_comment, body: "Nested Comment")
    login_as nested_comment.user

    visit project_path nested_comment.commentable
    click_on 'Comments'
    page.should have_content nested_comment.body

    click_on 'delete'
    click_on 'Comments'
    page.should have_content 'Add a comment'
    page.should_not have_content nested_comment.body
    page.should_not have_content "[comment deleted]"
  end
end
