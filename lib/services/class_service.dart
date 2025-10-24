import '../config/api_config.dart';
import '../models/class_model.dart';
import 'api_service.dart';

/// Class Service
/// Handles all class related API calls
class ClassService {
  final ApiService _apiService;

  ClassService(this._apiService);

  /// Get all classes
  /// GET /classes
  Future<Map<String, dynamic>> getAllClasses({
    String? search,
    String? teacherId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (teacherId != null && teacherId.isNotEmpty) {
        queryParams['teacherId'] = teacherId;
      }

      final response = await _apiService.get(
        ApiEndpoints.classes,
        queryParameters: queryParams,
      );

      // Handle nested data structure from backend
      final responseData = response.data['data'] ?? response.data;
      final classes = (responseData['classes'] as List)
          .map((json) => ClassModel.fromJson(json))
          .toList();

      return {
        'success': true,
        'classes': classes,
        'total': response.data['total'] ?? classes.length,
        'page': response.data['page'] ?? page,
        'totalPages':
            response.data['pages'] ?? response.data['totalPages'] ?? 1,
      };
    } catch (e) {
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
        'classes': <ClassModel>[],
      };
    }
  }

  /// Get class by ID
  /// GET /classes/:id
  Future<Map<String, dynamic>> getClassById(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.classById(id));

      final classModel = ClassModel.fromJson(response.data);

      return {'success': true, 'class': classModel};
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Get classes by teacher ID
  /// GET /classes/teacher/:teacherId
  Future<Map<String, dynamic>> getClassesByTeacher(String teacherId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.classesByTeacher(teacherId),
      );

      final classes = (response.data as List)
          .map((json) => ClassModel.fromJson(json))
          .toList();

      return {'success': true, 'classes': classes};
    } catch (e) {
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
        'classes': <ClassModel>[],
      };
    }
  }

  /// Create a new class
  /// POST /classes
  Future<Map<String, dynamic>> createClass({
    required String name,
    required String teacherId,
    int? capacity,
    List<String>? studentIds,
  }) async {
    try {
      final data = <String, dynamic>{'name': name, 'teacherId': teacherId};

      if (capacity != null) data['capacity'] = capacity;
      if (studentIds != null) data['studentIds'] = studentIds;

      final response = await _apiService.post(ApiEndpoints.classes, data: data);

      final classModel = ClassModel.fromJson(response.data);

      return {
        'success': true,
        'class': classModel,
        'message': 'Class created successfully',
      };
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Update class
  /// PUT /classes/:id
  Future<Map<String, dynamic>> updateClass({
    required String id,
    String? name,
    String? teacherId,
    int? capacity,
    List<String>? studentIds,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (name != null) data['name'] = name;
      if (teacherId != null) data['teacherId'] = teacherId;
      if (capacity != null) data['capacity'] = capacity;
      if (studentIds != null) data['studentIds'] = studentIds;

      final response = await _apiService.put(
        ApiEndpoints.classById(id),
        data: data,
      );

      final classModel = ClassModel.fromJson(response.data);

      return {
        'success': true,
        'class': classModel,
        'message': 'Class updated successfully',
      };
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Assign/Unassign teacher to class (teacher self-assignment)
  /// PUT /classes/:id/assign-teacher
  Future<Map<String, dynamic>> assignTeacher({
    required String classId,
    required bool assign,
  }) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.assignTeacherToClass(classId),
        data: {'assign': assign},
      );

      // Backend returns: { status, message, data: { class: {...} } }
      final responseData = response.data;

      // Check if response is successful
      if (responseData['status'] == 'success') {
        final classData = responseData['data']['class'];
        final classModel = ClassModel.fromJson(classData);

        return {
          'success': true,
          'class': classModel,
          'message':
              responseData['message'] ??
              (assign
                  ? 'Successfully assigned to class'
                  : 'Successfully unassigned from class'),
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Operation failed',
        };
      }
    } catch (e) {
      print('Error in assignTeacher: $e');
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Delete class
  /// DELETE /classes/:id
  Future<Map<String, dynamic>> deleteClass(String id) async {
    try {
      await _apiService.delete(ApiEndpoints.classById(id));

      return {'success': true, 'message': 'Class deleted successfully'};
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Add student to class
  /// POST /classes/:id/students
  Future<Map<String, dynamic>> addStudent({
    required String classId,
    required String studentId,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.addStudentToClass(classId),
        data: {'studentId': studentId},
      );

      final classModel = ClassModel.fromJson(response.data);

      return {
        'success': true,
        'class': classModel,
        'message': 'Student added to class successfully',
      };
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Remove student from class
  /// DELETE /classes/:id/students/:studentId
  Future<Map<String, dynamic>> removeStudent({
    required String classId,
    required String studentId,
  }) async {
    try {
      final response = await _apiService.delete(
        ApiEndpoints.removeStudentFromClass(classId, studentId),
      );

      final classModel = ClassModel.fromJson(response.data);

      return {
        'success': true,
        'class': classModel,
        'message': 'Student removed from class successfully',
      };
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Get class statistics
  /// GET /classes/:id/stats
  Future<Map<String, dynamic>> getClassStats(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.classStats(id));

      return {'success': true, 'stats': response.data};
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }
}
