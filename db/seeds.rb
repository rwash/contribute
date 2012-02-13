Project.delete_all

Project.create(name: 'Art Proj1',
	short_description: 'this is a short desc',
	long_description: 'this is a long desc',
	end_date: '11/23/2012',
	created_at: '1/25/2012',
	updated_at: '1/27/2012',
	category_id: 1,
	funding_goal: 1500,
	active: true,
	user_id: 3)

Project.create(name: 'Art Proj2',
	short_description: 'this is a short desc for proj 2',
	long_description: 'this is a long desc for proj 2',
	end_date: '11/23/2013',
	created_at: '3/12/2012',
	updated_at: '2/06/2012',
	category_id: 2,
	funding_goal: 2000,
	active: true,
	user_id: 3)

Category.delete_all

Category.create(short_description: 'Music',
	long_description: 'This category is dedicated for written compositions',
	created_at: '1/25/2012',
	updated_at: '1/26/2012')

Category.create(short_description: 'Movie',
	long_description: 'This category is dedicated for film productions',
	created_at: '1/25/2012',
	updated_at: '1/26/2012')




