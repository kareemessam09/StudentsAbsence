import '../config/api_config.dart';
import '../models/student_model.dart';
import 'api_service.dart';

/// Student Service
/// Handles all student related API calls
class StudentService {
  final ApiService _apiService;

  StudentService(this._apiService);

  /// Get all students
  /// GET /students
  Future<Map<String, dynamic>> getAllStudents({
    String? search,
    String? classId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (classId != null && classId.isNotEmpty) {
        queryParams['classId'] = classId;
      }

      final response = await _apiService.get(
        ApiEndpoints.students,
        queryParameters: queryParams,
      );

      final students = (response.data['students'] as List)
          .map((json) => StudentModel.fromJson(json))
          .toList();

      return {
        'success': true,
        'students': students,
        'total': response.data['total'] ?? students.length,
        'page': response.data['page'] ?? page,
        'totalPages': response.data['totalPages'] ?? 1,
      };
    } catch (e) {
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
        'students': <StudentModel>[],
      };
    }
  }

  /// Get student by ID
  /// GET /students/:id
  Future<Map<String, dynamic>> getStudentById(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.studentById(id));

      final student = StudentModel.fromJson(response.data);

      return {'success': true, 'student': student};
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Get students by class ID
  /// GET /students/class/:classId
  Future<Map<String, dynamic>> getStudentsByClass(String classId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.studentsByClass(classId),
      );

      // Backend returns nested structure: { status, results, data: { students: [...] } }
      final responseData = response.data;
      final studentsData = responseData['data']['students'] as List;

      final students = studentsData
          .map((json) => StudentModel.fromJson(json))
          .toList();

      return {'success': true, 'students': students};
    } catch (e) {
      print('Error in getStudentsByClass: $e');
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
        'students': <StudentModel>[],
      };
    }
  }

  /// Create a new student
  /// POST /students
  Future<Map<String, dynamic>> createStudent({
    required String nama,
    required String studentCode,
    String? classId,
  }) async {
    try {
      final data = {'nama': nama, 'studentCode': studentCode};

      if (classId != null && classId.isNotEmpty) {
        data['classId'] = classId;
      }

      final response = await _apiService.post(
        ApiEndpoints.students,
        data: data,
      );

      final student = StudentModel.fromJson(response.data);

      return {
        'success': true,
        'student': student,
        'message': 'Student created successfully',
      };
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Update student
  /// PUT /students/:id
  Future<Map<String, dynamic>> updateStudent({
    required String id,
    String? nama,
    String? studentCode,
    String? classId,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (nama != null) data['nama'] = nama;
      if (studentCode != null) data['studentCode'] = studentCode;
      if (classId != null) {
        data['classId'] = classId.isEmpty ? null : classId;
      }

      final response = await _apiService.put(
        ApiEndpoints.studentById(id),
        data: data,
      );

      final student = StudentModel.fromJson(response.data);

      return {
        'success': true,
        'student': student,
        'message': 'Student updated successfully',
      };
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Delete student
  /// DELETE /students/:id
  Future<Map<String, dynamic>> deleteStudent(String id) async {
    try {
      await _apiService.delete(ApiEndpoints.studentById(id));

      return {'success': true, 'message': 'Student deleted successfully'};
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Bulk import students
  /// POST /students/bulk
  Future<Map<String, dynamic>> bulkImport({
    required List<Map<String, dynamic>> students,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.bulkImportStudents,
        data: {'students': students},
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Students imported successfully',
        'imported': response.data['imported'] ?? 0,
        'failed': response.data['failed'] ?? 0,
        'errors': response.data['errors'] ?? [],
      };
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }
}
