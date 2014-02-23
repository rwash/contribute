require 'routing'

module ProjectActions
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
end
