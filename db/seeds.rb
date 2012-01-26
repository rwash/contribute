Project.delete_all

Project.create(name: 'Art Proj1',
	shortDescription: 'this is a short desc',
	longDescription: 'this is a long desc',
	endDate: '11/23/2012',
	created_at: '1/25/2012',
	updated_at: '1/27/2012',
	categoryId: 1,
	fundingGoal: 1500,
	active: true)

Project.create(name: 'Art Proj2',
	shortDescription: 'this is a short desc for proj 2',
	longDescription: 'this is a long desc for proj 2',
	endDate: '11/23/2013',
	created_at: '3/12/2012',
	updated_at: '2/06/2012',
	categoryId: 2,
	fundingGoal: 2000,
	active: true)

Category.delete_all

Category.create(shortDescription: 'Music',
	longDescription: 'This category is dedicated for written compositions',
	created_at: '1/25/2012',
	updated_at: '1/26/2012')

Category.create(shortDescription: 'Movie',
	longDescription: 'This category is dedicated for film productions',
	created_at: '1/25/2012',
	updated_at: '1/26/2012')




