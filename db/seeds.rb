Category.delete_all

Category.create(short_description: 'Music',
	long_description: 'This category is dedicated for written compositions',
	created_at: '1/25/2012',
	updated_at: '1/26/2012')

Category.create(short_description: 'Movie',
	long_description: 'This category is dedicated for film productions',
	created_at: '1/25/2012',
	updated_at: '1/26/2012')

ContributionStatus.delete_all

ContributionStatus.create(id: 1, name: 'None')
ContributionStatus.create(id: 2, name: 'Success')
ContributionStatus.create(id: 3, name: 'Pending')
ContributionStatus.create(id: 4, name: 'Failed')
ContributionStatus.create(id: 5, name: 'Cancelled')
ContributionStatus.create(id: 6, name: 'Retry_Pay')
ContributionStatus.create(id: 7, name: 'Retry_Cancel')
