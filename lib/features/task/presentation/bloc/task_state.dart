import 'package:equatable/equatable.dart';
import 'package:presshop/features/task/data/models/manage_task_chat_model.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/features/task/domain/entities/task.dart';
import 'package:presshop/features/task/domain/entities/task_all.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';
import 'package:presshop/features/task/domain/entities/task_detail.dart';
import 'package:presshop/features/task/domain/entities/task_media.dart';
import 'package:presshop/features/task/data/models/task_assigned_response_model.dart';

enum TaskStatus { initial, loading, success, failure }

class TaskState extends Equatable {

  const TaskState({
    this.taskDetail,
    this.allTasks = const [],
    this.localTasks = const [],
    this.chatList = const [],
    this.transactions = const [],
    this.uploadResponse,
    this.roomId,
    this.hopperAcceptedCount,
    this.allTasksStatus = TaskStatus.initial,
    this.localTasksStatus = TaskStatus.initial,
    this.taskDetailStatus = TaskStatus.initial,
    this.actionStatus = TaskStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  factory TaskState.initial() => const TaskState();
  final TaskAssignedEntity? taskDetail;
  final List<TaskAll> allTasks;
  final List<Task> localTasks;
  final List<ManageTaskChatModel> chatList;
  final List<EarningTransactionDetail> transactions;
  final Map<String, dynamic>? uploadResponse;
  final String? roomId;
  final String? hopperAcceptedCount;
  final TaskStatus allTasksStatus;
  final TaskStatus localTasksStatus;
  final TaskStatus taskDetailStatus;
  final TaskStatus actionStatus;
  final String? errorMessage;
  final String? successMessage;

  TaskState copyWith({
    TaskAssignedEntity? taskDetail,
    List<TaskAll>? allTasks,
    List<Task>? localTasks,
    List<ManageTaskChatModel>? chatList,
    List<EarningTransactionDetail>? transactions,
    Map<String, dynamic>? uploadResponse,
    String? roomId,
    String? hopperAcceptedCount,
    TaskStatus? allTasksStatus,
    TaskStatus? localTasksStatus,
    TaskStatus? taskDetailStatus,
    TaskStatus? actionStatus,
    String? errorMessage,
    String? successMessage,
    bool clearTaskDetail = false,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
    bool clearRoomId = false,
  }) {
    return TaskState(
      taskDetail: clearTaskDetail ? null : (taskDetail ?? this.taskDetail),
      allTasks: allTasks ?? this.allTasks,
      localTasks: localTasks ?? this.localTasks,
      chatList: chatList ?? this.chatList,
      transactions: transactions ?? this.transactions,
      uploadResponse: uploadResponse ?? this.uploadResponse,
      roomId: clearRoomId ? null : (roomId ?? this.roomId),
      hopperAcceptedCount: hopperAcceptedCount ?? this.hopperAcceptedCount,
      allTasksStatus: allTasksStatus ?? this.allTasksStatus,
      localTasksStatus: localTasksStatus ?? this.localTasksStatus,
      taskDetailStatus: taskDetailStatus ?? this.taskDetailStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        taskDetail,
        allTasks,
        localTasks,
        chatList,
        transactions,
        uploadResponse,
        roomId,
        hopperAcceptedCount,
        allTasksStatus,
        localTasksStatus,
        taskDetailStatus,
        actionStatus,
        errorMessage,
        successMessage,
      ];

  Map<String, dynamic> toJson() {
    return {
      'taskDetail': taskDetail != null ? _serialize(taskDetail) : null,
      'allTasks': allTasks.map((e) => _serialize(e)).toList(),
      'localTasks': localTasks.map((e) => _serialize(e)).toList(),
      'chatList': chatList.map((e) => _serialize(e)).toList(),
      'transactions': transactions.map((e) => _serialize(e)).toList(),
      'uploadResponse': uploadResponse,
      'roomId': roomId,
      'hopperAcceptedCount': hopperAcceptedCount,
      'allTasksStatus': allTasksStatus.name,
      'localTasksStatus': localTasksStatus.name,
      'taskDetailStatus': taskDetailStatus.name,
      'actionStatus': actionStatus.name,
      'errorMessage': errorMessage,
      'successMessage': successMessage,
    };
  }

  dynamic _serialize(dynamic obj) {
    if (obj == null) return null;
    if (obj is Map || obj is List || obj is String || obj is num || obj is bool) {
      return obj;
    }
    if (obj is DateTime) {
      return obj.toIso8601String();
    }
    try {
      return obj.toJson();
    } catch (_) {}
    try {
      return obj.toLocalJson();
    } catch (_) {}

    if (obj is TaskAssignedEntity) {
      return {
        'code': obj.code,
        'task': _serialize(obj.task),
        'resp': _serialize(obj.resp),
      };
    }
    if (obj is TaskAssignedDetailEntity) {
      return {
        'id': obj.id,
        'mediahouse_id': _serialize(obj.mediaHouse),
        'deadline_date': obj.deadlineDate.toIso8601String(),
        'heading': obj.heading,
        'description': obj.description,
        'location': obj.location,
        'address_location': _serialize(obj.addressLocation),
        'status': obj.status,
        'is_draft': obj.isDraft,
        'paid_status': obj.paidStatus,
        'createdAt': obj.createdAt.toIso8601String(),
        'updatedAt': obj.updatedAt.toIso8601String(),
        'content': obj.content.map((e) => _serialize(e)).toList(),
        'isNeedPhoto': obj.isNeedPhoto,
        'isNeedVideo': obj.isNeedVideo,
        'isNeedInterview': obj.isNeedInterview,
        'photoPrice': obj.photoPrice,
        'videoPrice': obj.videoPrice,
        'interviewPrice': obj.interviewPrice,
        'currency': obj.currency,
        'currencySymbol': obj.currencySymbol,
        'hopperInfo': obj.hopperInfo.map((e) => _serialize(e)).toList(),
        'hopperTaskAmount': obj.hopperTaskAmount,
        'acceptedHoppers': obj.acceptedHoppers,
        'distance': obj.distance,
        'walkTime': obj.walkTime,
        'driveTime': obj.driveTime,
        'specialRequirements': obj.specialRequirements,
        'preferences': obj.preferences,
        'latitude': obj.latitude,
        'longitude': obj.longitude,
        'hopperLocation': obj.hopperLocation != null ? _serialize(obj.hopperLocation) : null,
        'activeHoppersCount': obj.activeHoppersCount,
        'activeHoppersLocations': obj.activeHoppersLocations.map((e) => _serialize(e)).toList(),
      };
    }
    if (obj is MediaHouseEntity) {
      return {
        '_id': obj.id,
        'first_name': obj.firstName,
        'last_name': obj.lastName,
        'email': obj.email,
        'phone': obj.phone,
        'role': obj.role,
        'profile_image': obj.profileImage,
      };
    }
    if (obj is AddressLocationEntity) {
      return {
        'type': obj.type,
        'coordinates': obj.coordinates,
      };
    }
    if (obj is TaskContentEntity) {
      return {
        'media': obj.media,
        'media_type': obj.mediaType,
        'watermark': obj.watermark,
        'hopper_id': obj.hopperId,
        'imageId': obj.imageId,
        'time_stamp': obj.timeStamp.toIso8601String(),
      };
    }
    if (obj is ChatRoomEntity) {
      return {
        '_id': obj.id,
        'participants': obj.participants,
        'type': obj.type,
        'room_id': obj.roomId,
        'sender_id': obj.senderId,
        'task_id': obj.taskId,
        'createdAt': obj.createdAt.toIso8601String(),
      };
    }
    if (obj is HopperInfoEntity) {
      return {
        'id': obj.id,
        'type': obj.type,
        'count': obj.count,
        'hours': obj.hours,
      };
    }
    if (obj is HopperLocationModel) {
      return {
        'id': obj.id,
        'latitude': obj.latitude,
        'longitude': obj.longitude,
        'avatarImage': obj.avatar,
      };
    }
    if (obj is Task) {
      return {
        'status': obj.status,
        'totalAmount': obj.totalAmount,
        'statusColor': obj.statusColor,
        'statusText': obj.statusText,
        if (obj is TaskPending) ...{
          'title': obj.title,
          'body': obj.body,
          'broadCastId': obj.broadCastId,
          'isAvailableForAccept': obj.isAvailableForAccept,
          'taskDetail': obj.taskDetail != null ? _serialize(obj.taskDetail) : null,
        },
        if (obj is TaskMy) ...{
          'taskDetail': obj.taskDetail != null ? _serialize(obj.taskDetail) : null,
        }
      };
    }
    if (obj is TaskDetail) {
      return {
        'id': obj.id,
        'need_photos': obj.isNeedPhoto,
        'need_videos': obj.isNeedVideo,
        'need_interview': obj.isNeedInterview,
        'mode': obj.mode,
        'type': obj.type,
        'status': obj.status,
        'paid_status': obj.paidStatus,
        'deadline_date': obj.deadLine.toIso8601String(),
        'mediaHouseId': obj.mediaHouseId,
        'mediaHouseImage': obj.mediaHouseImage,
        'mediaHouseName': obj.mediaHouseName,
        'company_name': obj.companyName,
        'heading': obj.title,
        'task_description': obj.description,
        'accepted_by': obj.acceptedBy,
        'any_spcl_req': obj.specialReq,
        'location': obj.location,
        'hopper_photo_price': obj.photoPrice,
        'hopper_videos_price': obj.videoPrice,
        'hopper_interview_price': obj.interviewPrice,
        'received_amount': obj.receivedAmount,
        'latitude': obj.latitude,
        'longitude': obj.longitude,
        'role': obj.role,
        'category_id': obj.categoryId,
        'user_id': obj.userId,
        'createdAt': obj.createdAt,
        'discountPercent': obj.discountPercent,
        'miles': obj.miles,
        'byFeet': obj.byFeet,
        'byCar': obj.byCar,
        'content': obj.mediaList.map((e) => _serialize(e)).toList(),
        'broadcastLocation': obj.broadcastLocation,
        'room_id': obj.roomId,
        'minimumPriceRange': obj.minimumPriceRange,
        'maximumPriceRange': obj.maximumPriceRange,
        'currency': obj.currency,
        'currency_symbol': obj.currencySymbol,
        'hopperInfo': obj.hopperInfo,
        'hopperTaskAmount': obj.hopperTaskAmount,
        'active_hoppers': obj.activeHoppersCount,
        'active_hoppers_locations': obj.activeHoppersLocations,
        'preferences': obj.preferences,
      };
    }
    if (obj is TaskMedia) {
      return {
        '_id': obj.id,
        'media_type': obj.type,
        'watermark': obj.thumbnail,
        'media': obj.imageVideoUrl,
        'paid_status': obj.paidStatus,
        'amount_paid': obj.amount,
        'paid_status_to_hopper': obj.paidStatusToHopper,
        'amount_paid_to_hopper': obj.paidAmount,
        'amount_payable_to_hopper': obj.payableAmount,
        'commition_to_payable': obj.commitionAmount,
      };
    }
    if (obj is TaskAll) {
      return {
        '_id': obj.id,
        'hopper_id': obj.userId,
        'deadline_date': obj.deadlineDate?.toIso8601String(),
        'heading': obj.heading,
        'createdAt': obj.createdAt,
        'task_description': obj.description,
        'location': obj.location,
        'status': obj.status,
        'is_available_for_accept': obj.isAvailableForAccept,
        'isLive': obj.isLive,
        'ctaName': obj.ctaName,
        'ctaColorCode': obj.ctaColorCode,
        'ctaTextColorCode': obj.ctaTextColorCode,
        'task_accepted_count': obj.taskAcceptedCount,
        'status_color': obj.statusColor,
        'status_text': obj.statusText,
        'mediahouse_id': obj.mediaHouseDetails != null ? _serialize(obj.mediaHouseDetails) : null,
        'acceptedTasks': obj.acceptedTasks.map((e) => _serialize(e)).toList(),
        'uploadContents': obj.uploadContents != null ? _serialize(obj.uploadContents) : null,
        'need_photos': obj.isNeedPhoto,
        'need_videos': obj.isNeedVideo,
        'need_interview': obj.isNeedInterview,
        'hopper_photo_price': obj.photoPrice,
        'hopper_videos_price': obj.videoPrice,
        'hopper_interview_price': obj.interviewPrice,
        'currency': obj.currency,
        'currency_symbol': obj.currencySymbol,
        'address_location': {
          'coordinates': [obj.latitude, obj.longitude]
        },
      };
    }
    if (obj is MediaHouseDetailsEntity) {
      return {
        '_id': obj.id,
        'full_name': obj.fullName,
        'profile_image': obj.profileImage,
      };
    }
    if (obj is UploadContentsEntity) {
      return {
        '_id': obj.id,
        'videothubnail': obj.videothubnail,
        'type': obj.type,
        'imageAndVideo': obj.imageAndVideo,
      };
    }
    if (obj is AcceptedTaskEntity) {
      return {
        '_id': obj.id,
        'task_id': obj.taskId,
        'task_status': obj.taskStatus,
        'hopper_id': obj.hopperId,
        'createdAt': obj.createdAt,
        'updatedAt': obj.updatedAt,
      };
    }
    if (obj is EarningTransactionDetail) {
      return {
        '_id': obj.id,
        'paid_status_for_hopper': obj.paidStatus,
        'amount': obj.amount,
        'total_received_from_stripe': obj.allAmount,
        'hopper_price': obj.totalEarningAmt,
        'payable_to_hopper': obj.payableT0Hopper,
        'presshop_commission': obj.payableCommission,
        'stripe_fee': obj.stripefee,
        'type': obj.type,
        'typeofcontent': obj.typesOfContent ? "exclusive" : "shared",
        'createdAt': obj.createdAT,
        'Due_date': obj.dueDate,
        'updatedAt': obj.updatedAT,
        'task_id': obj.contentId,
        'currency': obj.currency,
        'currency_symbol': obj.currencySymbol,
        'userFirstName': obj.userFirstName,
        'userLastName': obj.userLastName,
        'userEmail': obj.userEmail,
        'userPhone': obj.userPhone,
        'userAddress': obj.userAddress,
        'hopperAvatar': obj.hopperAvatar,
        'hopperBankName': obj.hopperBankName,
        'hopperBankLogo': obj.hopperBankLogo,
        'contentImage': obj.contentImage,
        'contentTitle': obj.contentTitle,
      };
    }

    try {
      return obj.toString();
    } catch (_) {
      return null;
    }
  }
}

// Keep a few type-safe markers if needed for listener logic, or just use properties
class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskError extends TaskState {
  const TaskError(String message)
      : super(errorMessage: message, actionStatus: TaskStatus.failure);
}
