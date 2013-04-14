class ApprovalStatus < ClassyEnum::Base
end

class ApprovalStatus::Pending < ApprovalStatus
end

class ApprovalStatus::Approved < ApprovalStatus
end

class ApprovalStatus::Rejected < ApprovalStatus
end
