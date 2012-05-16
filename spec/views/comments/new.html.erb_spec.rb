require 'spec_helper'

describe "comments/new" do
  before(:each) do
    assign(:comment, stub_model(Comment,
      :userid => 1,
      :content => "MyText",
      :parentid => 1
    ).as_new_record)
  end

  it "renders new comment form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => comments_path, :method => "post" do
      assert_select "input#comment_userid", :name => "comment[userid]"
      assert_select "textarea#comment_content", :name => "comment[content]"
      assert_select "input#comment_parentid", :name => "comment[parentid]"
    end
  end
end
