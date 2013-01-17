class ContributionStatus < ClassyEnum::Base
end

class ContributionStatus::None < ContributionStatus
end

class ContributionStatus::Success < ContributionStatus
end

class ContributionStatus::Pending < ContributionStatus
end

class ContributionStatus::Failure < ContributionStatus
end

class ContributionStatus::Cancelled < ContributionStatus
end

class ContributionStatus::RetryPay < ContributionStatus
end

class ContributionStatus::RetryCancel < ContributionStatus
end
