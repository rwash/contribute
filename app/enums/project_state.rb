class ProjectState < ClassyEnum::Base

  # Returns true if the public can view the project.
  # The public can view projects that are active, nonfunded, or funded.
  def public_can_view?() false end

  # Returns true if the project is editable.
  # To edit a project, it must be unconfirmed or inactive.
  def can_edit?() false end

  # Returns true if the current user can update the project.
  # For a user to update a project, they must own the project,
  # and the project must be active, funded, or nonfunded.
  def can_update?() false end

  # Returns true if users can comment on the project.
  # The project must be active, funded, or non-funded.
  def can_comment?() false end
end

class ProjectState::Unconfirmed < ProjectState
  def can_edit?() true end
end

class ProjectState::Inactive < ProjectState
  def can_edit?() true end
end

class ProjectState::Active < ProjectState
  def public_can_view?() true end
  def can_update?() true end
  def can_comment?() true end
end

class ProjectState::Funded < ProjectState
  def public_can_view?() true end
  def can_update?() true end
  def can_comment?() true end
end

class ProjectState::Nonfunded < ProjectState
  def public_can_view?() true end
  def can_update?() true end
  def can_comment?() true end
end

class ProjectState::Cancelled < ProjectState
end
