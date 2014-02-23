require 'routing'

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
end
