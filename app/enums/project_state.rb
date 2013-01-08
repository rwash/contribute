class ProjectState < ClassyEnum::Base
end

class ProjectState::Unconfirmed < ProjectState
end

class ProjectState::Inactive < ProjectState
end

class ProjectState::Active < ProjectState
end

class ProjectState::Funded < ProjectState
end

class ProjectState::Nonfunded < ProjectState
end

class ProjectState::Cancelled < ProjectState
end
