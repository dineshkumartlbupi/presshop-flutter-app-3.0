import 'package:equatable/equatable.dart';
import '../../../../core/core_export.dart';

abstract class EarningEvent extends Equatable {
  const EarningEvent();

  @override
  List<Object> get props => [];
}

class FetchEarningDataEvent extends EarningEvent {

  const FetchEarningDataEvent({required this.fromDate, required this.toDate});
  final String fromDate;
  final String toDate;

  @override
  List<Object> get props => [fromDate, toDate];
}


class FetchTransactionsEvent extends EarningEvent {

  const FetchTransactionsEvent({
    required this.limit,
    required this.offset,
    required this.filterParams,
  });
  final int limit;
  final int offset;
  final Map<String, dynamic> filterParams;

  @override
  List<Object> get props => [limit, offset, filterParams];
}

class FetchCommissionsEvent extends EarningEvent {

  const FetchCommissionsEvent({
    required this.limit,
    required this.offset,
    required this.filterParams,
  });
  final int limit;
  final int offset;
  final Map<String, dynamic> filterParams;
   @override
  List<Object> get props => [limit, offset, filterParams];
}

class ChangeTabEvent extends EarningEvent {
  const ChangeTabEvent(this.tabIndex);
  final int tabIndex;

  @override
  List<Object> get props => [tabIndex];
}

class UpdateDateEvent extends EarningEvent {

  const UpdateDateEvent({required this.fromDate, required this.toDate});
  final String fromDate;
  final String toDate;
    @override
  List<Object> get props => [fromDate, toDate];

}
