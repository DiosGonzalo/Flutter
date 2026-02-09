import 'package:equatable/equatable.dart';

abstract class PeopleChangesEvent extends Equatable {
  const PeopleChangesEvent();

  @override
  List<Object?> get props => [];
}

class FetchPeopleChanges extends PeopleChangesEvent {
  final int page;
  final String? startDate;
  final String? endDate;

  const FetchPeopleChanges({
    this.page = 1,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [page, startDate, endDate];
}
