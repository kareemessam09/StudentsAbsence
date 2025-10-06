import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../models/request_model.dart';
import 'request_state.dart';

class RequestCubit extends Cubit<RequestState> {
  RequestCubit() : super(RequestInitial()) {
    loadRequests();
  }

  final _uuid = const Uuid();

  void loadRequests() {
    emit(RequestLoading());
    try {
      // Load mock requests
      final requests = RequestModel.mockRequests;
      emit(RequestLoaded(requests));
    } catch (e) {
      emit(RequestError(e.toString()));
    }
  }

  void addRequest({
    required String studentName,
    required String className,
    required String createdBy,
  }) {
    final currentState = state;
    if (currentState is RequestLoaded) {
      final newRequest = RequestModel(
        id: _uuid.v4(),
        studentName: studentName,
        className: className,
        status: 'pending',
        createdBy: createdBy,
        createdAt: DateTime.now(),
      );

      final updatedRequests = [newRequest, ...currentState.requests];
      emit(RequestLoaded(updatedRequests));
    }
  }

  void updateRequestStatus({required String id, required String status}) {
    final currentState = state;
    if (currentState is RequestLoaded) {
      final updatedRequests = currentState.requests.map((request) {
        if (request.id == id) {
          return request.copyWith(status: status);
        }
        return request;
      }).toList();

      emit(RequestLoaded(updatedRequests));
    }
  }

  void deleteRequest(String id) {
    final currentState = state;
    if (currentState is RequestLoaded) {
      final updatedRequests = currentState.requests
          .where((request) => request.id != id)
          .toList();
      emit(RequestLoaded(updatedRequests));
    }
  }

  List<RequestModel> getPendingRequests() {
    final currentState = state;
    if (currentState is RequestLoaded) {
      return currentState.requests
          .where((request) => request.status == 'pending')
          .toList();
    }
    return [];
  }

  List<RequestModel> getRequestsByCreator(String createdBy) {
    final currentState = state;
    if (currentState is RequestLoaded) {
      return currentState.requests
          .where((request) => request.createdBy == createdBy)
          .toList();
    }
    return [];
  }

  List<RequestModel> getRequestsByClass(String className) {
    final currentState = state;
    if (currentState is RequestLoaded) {
      return currentState.requests
          .where((request) => request.className == className)
          .toList();
    }
    return [];
  }
}
