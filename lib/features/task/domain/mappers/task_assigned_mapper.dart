import 'package:presshop/features/task/data/models/task_assigned_response_model.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';

extension TaskAssignedMapper on TaskAssignedDataModel {
  TaskAssignedEntity toEntity() {
    return TaskAssignedEntity(
      code: code,
      task: task,
      resp: resp,
    );
  }
}

extension TaskItemMapper on TaskAssignedItemModel {
  TaskAssignedDetailEntity toEntity() => this;
}

extension MediaHouseMapper on MediaHouseDataModel {
  MediaHouseEntity toEntity() => this;
}

extension AddressLocationMapper on AddressLocationDataModel {
  AddressLocationEntity toEntity() => this;
}

extension TaskContentMapper on TaskContentDataModel {
  TaskContentEntity toEntity() => this;
}

extension ChatRoomMapper on ChatRoomDataModel {
  ChatRoomEntity toEntity() => this;
}
