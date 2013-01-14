namespace :nightly do

  task :cleanup do
    at_exit do
      puts "Cleaning up"
      [spec_output, spec_errors, doc_output, email_message].each do |file|
        File.delete file if File.exists? file
      end
    end
  end

  def emails
    ['contribute@bitlab.cas.msu.edu']
  end

  def spec_output() 'tmp/contribute-nightly.test.tmp' end
  def doc_output() 'tmp/contribute-nightly.doc.tmp' end
  def email_message() 'tmp/contribute-nightly.msg.tmp' end

  def www_directory() '/var/www/contribute' end

  task :bundle do
    sh "bundle install"
  end

  file spec_output => [:bundle, 'db:test:prepare', :cleanup] do
    begin
      sh "bundle exec rspec > #{spec_output}"
    rescue
    ensure
      # Just in case we didn't generate the file...
      touch spec_output
    end
  end

  file doc_output => [:bundle, :cleanup] do
    sh "bundle exec rdoc app -all > #{doc_output}"
  end

  task :send_mail => [spec_output, doc_output, :cleanup] do
    # Generating email
    message = <<END_OF_MESSAGE
      <h1>Contribute Nightly Output</h1>

      See more: <br/>
      <a href='http://orithena.cas.msu.edu/contribute/coverage'>Test Coverage</a>,
      <a href='http://orithena.cas.msu.edu/contribute/specifications.html'>Project Specifications</a>, and
      <a href='http://orithena.cas.msu.edu/contribute/doc'>Documentation</a>

      <h2>RSpec Results</h2>
      #{File.read(spec_output).gsub("\n", "<br/>")}

      <h2>Documentation Results</h2>
      #{File.read(doc_output).gsub("\n", "<br/>")}
END_OF_MESSAGE

    puts File.read spec_output.gsub("\n", "<br/>")

    message_file = File.new(email_message, 'w')
    message_file.write message
    message_file.close

    puts "Sending emails"
    emails.each do |email|
      sh "mail -a 'Content-type: text/html' -s 'Contribute Nightly Output' #{email} < #{email_message}"
    end

  end

  task :publish_coverage => spec_output do
    sh "rm -rf #{www_directory}/coverage"
    sh "cp -r coverage #{www_directory}/coverage"
  end

  task :publish_docs => doc_output do
    sh "rm -rf #{www_directory}/doc"
    sh "cp -r doc #{www_directory}/doc"
  end

  task :publish_test_results => spec_output do
    sh "rm -rf #{www_directory}/public/specification.html"
    sh "cp -r public/specification.html #{www_directory}/public/specification.html"
  end

  task :publish => [:publish_coverage, :publish_docs, :publish_test_results]

  task :run => [:send_mail, :publish]
end
