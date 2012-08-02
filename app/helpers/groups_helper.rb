module GroupsHelper
	def project_name(item)
		Project.find_by_id(item.itemable_id).name
	end
	
	def project_path_from_item(item)
		project_path(Project.find_by_id(item.itemable_id))
	end
end