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
}
