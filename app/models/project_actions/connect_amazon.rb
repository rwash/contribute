require 'routing'

module ProjectActions
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
end
