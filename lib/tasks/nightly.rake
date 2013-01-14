namespace :nightly do

  def emails
    ['wright.grayson@gmail.com']
  end

  def spec_output
    '/tmp/contribute-nightly.test.tmp'
  end

  # Currently not used
  def spec_errors
    '/tmp/contribute-nightly.test_err.tmp'
  end

  def doc_output
    '/tmp/contribute-nightly.doc.tmp'
  end

  def email_message
    '/tmp/contribute-nightly.msg.tmp'
  end

  task :bundle do
    sh "bundle install"
  end

  file spec_output => [:bundle, 'db:test:prepare'] do
    begin
      sh "bundle exec rspec --format html> #{spec_output}"
    rescue
    ensure
      touch spec_output
    end
  end

  file doc_output => :bundle do
    sh "bundle exec rdoc app -all > #{doc_output}"
  end

  task :send_mail => [spec_output, doc_output] do
    # Generating email
    message = <<END_OF_MESSAGE
      <h1>Contribute Nightly Output</h1>

      See more: <br/>
      <a href='http://orithena.cas.msu.edu/contribute/coverage'>Test Coverage</a> and
      <a href='http://orithena.cas.msu.edu/contribute/doc'>Documentation</a>

      <h2>RSpec Results</h2>
      #{File.read spec_output}

      <h2>Documentation Results</h2>
      #{File.read(doc_output).gsub("\n", "<br/>")}
END_OF_MESSAGE

    message_file = File.new(email_message, 'w')
    message_file.write message
    message_file.close

    puts "Sending emails"
    emails.each do |email|
      sh "mail -a 'Content-type: text/html' -s 'Contribute Nightly Output' #{email} < #{email_message}"
    end

    # Cleanup
    puts "Cleaning up"
    [spec_output, spec_errors, doc_output, email_message].each do |file|
      sh "rm #{file}"
    end
  end

end
