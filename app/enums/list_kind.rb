class ListKind < ClassyEnum::Base
end

class ListKind::Default < ListKind
end

class ListKind::Manual < ListKind
end

class ListKind::CreatedAtDescending < ListKind
end

class ListKind::CreatedAtAscending < ListKind
end

class ListKind::EndDateDescending < ListKind
end

class ListKind::EndDateAscending < ListKind
end

class ListKind::FundingGoalDescending < ListKind
end

class ListKind::FundingGoalAscending < ListKind
end

class ListKind::AmountLeftToGoalInDollarsDescending < ListKind
end

class ListKind::AmountLeftToGoalInDollarsAscending < ListKind
end

class ListKind::AmountLeftToGoalAsPercentDescending < ListKind
end

class ListKind::AmountLeftToGoalAsPercentAscending < ListKind
end

class ListKind::AmountDonatedInDollarsDescending < ListKind
end

class ListKind::AmountDonatedInDollarsAscending < ListKind
end

class ListKind::AmountDonatedAsPercentOfGoalDescending < ListKind
end

class ListKind::AmountDonatedAsPercentOfGoalAscending < ListKind
end

class ListKind::RandomDescending < ListKind
end

class ListKind::RandomAscending < ListKind
end
