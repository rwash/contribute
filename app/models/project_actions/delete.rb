require 'routing'

module ProjectActions
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
end
