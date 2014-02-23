require 'routing'

module ProjectActions
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
end
