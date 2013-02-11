require 'spec_helper'
require 'controller_helper'

describe PagesController do
  include Devise::TestHelpers

  # We'll perform these two tests for each of our static pages.
  # To test a new page, just add the name of the page to this list.
  %w(faq help terms).each do |page|
    context "on GET '/pages/#{page}'" do
      before { get :show, id: page }

      it { should respond_with :success }
      it { should render_template page }
    end
  end
end
