import '../models/api_response.dart';
import '../models/restaurant.dart';
import '../models/product.dart';
import 'api_service.dart';
import 'token_manager.dart';

class RestaurantService {
  /// Obtiene la lista de restaurantes con paginación
  static Future<ApiResponse<RestaurantListResponse>> getRestaurants({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/restaurants?page=$page&pageSize=$pageSize',
        ApiService.defaultHeaders,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        final restaurantData = response.data!['restaurants'];
        final paginationData = response.data!['pagination'];
        
        final restaurants = (restaurantData as List?)
            ?.map((restaurant) => Restaurant.fromJson(restaurant))
            .toList() ?? [];
        
        final pagination = Pagination.fromJson(paginationData);
        
        final restaurantListResponse = RestaurantListResponse(
          restaurants: restaurants,
          pagination: pagination,
        );

        return ApiResponse<RestaurantListResponse>(
          status: 'success',
          message: response.message,
          data: restaurantListResponse,
        );
      }

      return ApiResponse<RestaurantListResponse>(
        status: response.status,
        message: response.message,
        code: response.code,
        errors: response.errors,
      );
    } catch (e) {
      return ApiResponse<RestaurantListResponse>(
        status: 'error',
        message: 'Error al obtener restaurantes: ${e.toString()}',
      );
    }
  }

  /// Obtiene los detalles de un restaurante con su menú completo
  static Future<ApiResponse<RestaurantDetail>> getRestaurantDetail({
    required int restaurantId,
  }) async {
    try {
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/restaurants/$restaurantId',
        ApiService.defaultHeaders,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        final restaurantDetail = RestaurantDetail.fromJson(response.data!);

        return ApiResponse<RestaurantDetail>(
          status: 'success',
          message: response.message,
          data: restaurantDetail,
        );
      }

      return ApiResponse<RestaurantDetail>(
        status: response.status,
        message: response.message,
        code: response.code,
        errors: response.errors,
      );
    } catch (e) {
      return ApiResponse<RestaurantDetail>(
        status: 'error',
        message: 'Error al obtener detalles del restaurante: ${e.toString()}',
      );
    }
  }

  /// Obtiene restaurantes con autenticación (para usuarios logueados)
  static Future<ApiResponse<RestaurantListResponse>> getRestaurantsAuthenticated({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/restaurants?page=$page&pageSize=$pageSize',
        headers,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        final restaurantData = response.data!['restaurants'];
        final paginationData = response.data!['pagination'];
        
        final restaurants = (restaurantData as List?)
            ?.map((restaurant) => Restaurant.fromJson(restaurant))
            .toList() ?? [];
        
        final pagination = Pagination.fromJson(paginationData);
        
        final restaurantListResponse = RestaurantListResponse(
          restaurants: restaurants,
          pagination: pagination,
        );

        return ApiResponse<RestaurantListResponse>(
          status: 'success',
          message: response.message,
          data: restaurantListResponse,
        );
      }

      return ApiResponse<RestaurantListResponse>(
        status: response.status,
        message: response.message,
        code: response.code,
        errors: response.errors,
      );
    } catch (e) {
      return ApiResponse<RestaurantListResponse>(
        status: 'error',
        message: 'Error al obtener restaurantes: ${e.toString()}',
      );
    }
  }

  /// Obtiene detalles de restaurante con autenticación
  static Future<ApiResponse<RestaurantDetail>> getRestaurantDetailAuthenticated({
    required int restaurantId,
  }) async {
    try {
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/restaurants/$restaurantId',
        headers,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        final restaurantDetail = RestaurantDetail.fromJson(response.data!);

        return ApiResponse<RestaurantDetail>(
          status: 'success',
          message: response.message,
          data: restaurantDetail,
        );
      }

      return ApiResponse<RestaurantDetail>(
        status: response.status,
        message: response.message,
        code: response.code,
        errors: response.errors,
      );
    } catch (e) {
      return ApiResponse<RestaurantDetail>(
        status: 'error',
        message: 'Error al obtener detalles del restaurante: ${e.toString()}',
      );
    }
  }
}
