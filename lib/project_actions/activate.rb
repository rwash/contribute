module Routing
  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers

  included do
    def default_url_options
      ActionMailer::Base.default_url_options
    end
  end
end

module ProjectActions
  class Activate
    include Routing

    def initialize project
      @project = project
    end

    def text
      'Activate your project to receive contributions'
    end

    # TODO formatting
    def description
      "Take some time to look over your project and make sure you're happy with it. Once you click 'activate' and start accepting contributions, you won't be able to change any information you've already entered."
    end

    def button_text
      "Activate Project"
    end

    def confirmation_text
      "Are you sure you want to activate this project?
        You will not be able to edit the project once it is active."
    end

    def route
      activate_project_path @project
    end

    def http_method
      :put
    end
  end

  class ConnectAmazon
    include Routing

    def initialize project
      @project = project
    end

    def text
      "Connect an Amazon account to receive payments"
    end

    # TODO formatting
    def description
      "We have partnered with Amazon to make getting money for projects and contributing to projects not only quick and easy, but also safe and secure. You will need to have an Amazon Payments account in order to give or receive money through Contribute. The good news is that it is very easy to get one. Just follow the instructions from Amazon and you will be ready to start using contribute in no time!"
    end

    def button_text
      "Connect an Amazon account"
    end

    def confirmation_text
    end

    def route
      new_project_amazon_payment_account_path(@project)
    end

    def http_method
      :get
    end

    def button_class
      'success-button'
    end
  end

  class Update
    include Routing

    def initialize project
      @project = project
    end

    def text
      "Create an update"
    end

    def description
      "Now that your project is collecting contributions, you may want to send a note out to your contributors with any status updates. This could be anything from a thank-you note to a description of the work you're doing on the project."
    end

    def button_text
      "Add an Update"
    end

    def confirmation_text
    end

    def route
      new_project_update_path @project
    end

    def http_method
      :get
    end

    def button_class
      'success-button'
    end
  end

  class Edit
    include Routing

    def initialize project
      @project = project
    end

    def text
      'Edit your Project'
    end

    # TODO formatting
    def description
      "Take some time to look over your project and make sure you're happy with it. In order to get a good number of contributions, you'll want to make sure that you have a project picture, a catchy and concise short description, and a detailed long description."
    end

    def button_text
      "Edit Project"
    end

    def confirmation_text
    end

    def route
      edit_project_path @project
    end

    def http_method
      :get
    end

    def button_class
    end
  end

  class Delete
    include Routing

    def initialize project
      @project = project
    end

    def text
      # This should never be recommended to the user
      raise NotImplementedError
    end

    def description
      # This should never be recommended to the user
      raise NotImplementedError
    end

    def button_text
      "Delete Project"
    end

    def confirmation_text
      "Are you sure you want to delete this project?
      You will not be able to recover it."
    end

    def route
      project_path @project
    end

    def http_method
      :delete
    end

    def button_class
      'danger-button'
    end
  end

  class Cancel
    include Routing

    def initialize project
      @project = project
    end

    def text
      # This should never be recommended to the user
      raise NotImplementedError
    end

    def description
      # This should never be recommended to the user
      raise NotImplementedError
    end

    def button_text
      "Cancel Project"
    end

    def confirmation_text
      "Are you sure you want to cancel this project?
      All contributions to it will also be cancelled."
    end

    def route
      project_path @project
    end

    def http_method
      :delete
    end

    def button_class
      'danger-button'
    end
  end
end
