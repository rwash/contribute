def login(email, password)
	visit(root_path)
	click_link 'Sign In'

	fill_in 'Email', :with => email
	fill_in 'Password', :with => password
	click_button 'Sign in'

	page.should have_content('Signed in successfully')
end

def login_amazon(email, password)
	page.should have_content('Sign in with your Amazon account') 

	#Now we're in amazon's sign in
	fill_in 'ap_email', :with => email
	fill_in 'ap_password', :with => password
	click_on 'signInSubmit'
end

def click_amazon_continue()
	find('input.submit').click #This is an image without an id or value, so we have to find it!
end

def get_and_assert_project(project_name)
	project = Project.find_by_name(project_name)
	project.should_not be_nil

	return project
end

def get_and_assert_contribution(project_id)
	contribution = Contribution.find_by_project_id(project_id)
	contribution.should_not be_nil

	return contribution
end

def make_amazon_payment(user, password)
	login_amazon(user, password)

	#choose credit card radio button
	choose 'existingCard_0'
	click_amazon_continue

	#confirm again...
	click_amazon_continue
end

