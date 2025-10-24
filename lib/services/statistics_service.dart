import '../config/api_config.dart';
import 'api_service.dart';

class StatisticsService {
  final ApiService _apiService;

  StatisticsService(this._apiService);

  /// Get manager dashboard overview statistics
  /// GET /statistics/overview
  Future<Map<String, dynamic>> getManagerOverview() async {
    try {
      final response = await _apiService.get(ApiEndpoints.statisticsOverview);

      // Backend returns nested structure: { status, data: { overview: {...} } }
      if (response.data['status'] == 'success') {
        return {
          'success': true,
          'overview': response.data['data']['overview'],
          'recentActivity': response.data['data']['recentActivity'],
          'timestamp': response.data['data']['timestamp'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to fetch statistics',
        };
      }
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// Get daily attendance statistics
  /// GET /statistics/daily-attendance?date=YYYY-MM-DD
  Future<Map<String, dynamic>> getDailyAttendance({String? date}) async {
    try {
      final queryParams = date != null ? '?date=$date' : '';
      final response = await _apiService.get(
        '${ApiEndpoints.dailyAttendance}$queryParams',
      );

      if (response.data['status'] == 'success') {
        return {'success': true, 'data': response.data['data']};
      } else {
        return {
          'success': false,
          'message':
              response.data['message'] ?? 'Failed to fetch daily attendance',
        };
      }
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }
}
