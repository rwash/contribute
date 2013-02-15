class ListKind < ClassyEnum::Base
  # sorts a list of projects
  def sort(projects)
    projects.sort {|a,b| b.created_at <=> a.created_at }
  end

  # Options:
  # limit - optional limit to number of projects you want
  # as_owner - whether or not the list is being viewed by its owner.
  #     If true, then all projects are displayed, even unconfirmed, inactive, and cancelled ones
  def sorted_projects(options)
    limit = options[:limit] || Project.count
    projects = []
    if owner.listable == User.find_by_id(1)
      projects << Project.find_by_state(:active) if owner.show_active
      projects << Project.find_by_state(:funded) if owner.show_funded
      projects << Project.find_by_state(:nonfunded) if owner.show_nonfunded
    else
      projects << owner.listable.projects.where(state: :active) if owner.show_active
      projects << owner.listable.projects.where(state: :funded) if owner.show_funded
      projects << owner.listable.projects.where(state: :nonfunded) if owner.show_nonfunded
      if options[:as_owner]
        projects << owner.listable.projects.where(state: :unconfirmed)
        projects << owner.listable.projects.where(state: :inactive)
        projects << owner.listable.projects.where(state: :cancelled)
      end
    end
    projects.flatten!
    projects.compact! # remove nil elements

    sort(projects).slice!(0,limit)
  end
end

class ListKind::Default < ListKind
end

class ListKind::Manual < ListKind
  def sort(projects)
    owner.listings.order("position DESC").map { |listing| listing.item }
  end
end

class ListKind::CreatedAtDescending < ListKind
  def sort(projects)
    projects.sort {|a,b| b.created_at <=> a.created_at }
  end
end

class ListKind::CreatedAtAscending < ListKind
  def sort(projects)
    projects.sort {|a,b| a.created_at <=> b.created_at }
  end
end

class ListKind::EndDateDescending < ListKind
  def sort(projects)
    projects.sort {|a,b| b.end_date <=> a.end_date }
  end
end

class ListKind::EndDateAscending < ListKind
  def sort(projects)
    projects.sort {|a,b| a.end_date <=> b.end_date }
  end
end

class ListKind::FundingGoalDescending < ListKind
  def sort(projects)
    projects.sort {|a,b| b.funding_goal <=> a.funding_goal }
  end
end

class ListKind::FundingGoalAscending < ListKind
  def sort(projects)
    projects.sort {|a,b| a.funding_goal <=> b.funding_goal }
  end
end

class ListKind::AmountLeftToGoalInDollarsDescending < ListKind
  def sort(projects)
    projects.sort {|a,b| b.left_to_goal <=> a.left_to_goal }
  end
end

class ListKind::AmountLeftToGoalInDollarsAscending < ListKind
  def sort(projects)
    projects.sort {|a,b| a.left_to_goal <=> b.left_to_goal }
  end
end

class ListKind::AmountLeftToGoalAsPercentDescending < ListKind
  def sort(projects)
    projects.sort {|a,b| a.contributions_percentage <=> b.contributions_percentage }
  end
end

class ListKind::AmountLeftToGoalAsPercentAscending < ListKind
  def sort(projects)
    projects.sort {|a,b| b.contributions_percentage <=> a.contributions_percentage }
  end
end

class ListKind::AmountDonatedInDollarsDescending < ListKind
  def sort(projects)
    projects.sort {|a,b| b.contributions_total <=> a.contributions_total }
  end
end

class ListKind::AmountDonatedInDollarsAscending < ListKind
  def sort(projects)
    projects.sort {|a,b| a.contributions_total <=> b.contributions_total }
  end
end

class ListKind::AmountDonatedAsPercentOfGoalDescending < ListKind
  def sort(projects)
    projects.sort {|a,b| b.contributions_percentage <=> a.contributions_percentage }
  end
end

class ListKind::AmountDonatedAsPercentOfGoalAscending < ListKind
  def sort(projects)
    projects.sort {|a,b| a.contributions_percentage <=> b.contributions_percentage }
  end
end

class ListKind::RandomDescending < ListKind
  def sort(projects)
    projects.shuffle
  end
end

class ListKind::RandomAscending < ListKind
  def sort(projects)
    projects.shuffle
  end
end
