require 'routing'

module ProjectActions
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
