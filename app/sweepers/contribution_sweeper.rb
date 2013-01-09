class ContributionSweeper < ActionController::Caching::Sweeper
  observe Contribution

  def after_create(contribution)
    expire_cache_for(contribution)
  end

  def after_update(contribution)
    expire_cache_for(contribution)
  end

private
  def expire_cache_for(contribution)
    Rails.cache.delete("#{contribution.project_id}_contributions_total")
    Rails.cache.delete("#{contribution.project_id}_contributions_percentage")
  end
end
