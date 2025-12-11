import 'package:equatable/equatable.dart';
import '../../../../core/core_export.dart';

abstract class EarningEvent extends Equatable {
  const EarningEvent();

  @override
  List<Object> get props => [];
}

class FetchEarningDataEvent extends EarningEvent {
  final String fromDate;
  final String toDate;

  const FetchEarningDataEvent({required this.fromDate, required this.toDate});

  @override
  List<Object> get props => [fromDate, toDate];
}


class FetchTransactionsEvent extends EarningEvent {
  final int limit;
  final int offset;
  final Map<String, dynamic> filterParams;

  const FetchTransactionsEvent({
    required this.limit,
    required this.offset,
    required this.filterParams,
  });

  @override
  List<Object> get props => [limit, offset, filterParams];
}

class FetchCommissionsEvent extends EarningEvent {
  final int limit;
  final int offset;
  final Map<String, dynamic> filterParams;

  const FetchCommissionsEvent({
    required this.limit,
    required this.offset,
    required this.filterParams,
  });
   @override
  List<Object> get props => [limit, offset, filterParams];
}

class ChangeTabEvent extends EarningEvent {
  final int tabIndex;
  const ChangeTabEvent(this.tabIndex);

  @override
  List<Object> get props => [tabIndex];
}

class UpdateDateEvent extends EarningEvent {
  final String fromDate;
  final String toDate;

  const UpdateDateEvent({required this.fromDate, required this.toDate});
    @override
  List<Object> get props => [fromDate, toDate];

}
