import 'package:flutter/foundation.dart';
import '../models/api_response.dart';
import '../models/schedule_response.dart';
import 'api_service.dart';
import 'token_manager.dart';

class ScheduleService {
  /// Obtiene la lista de sucursales del restaurante del owner autenticado
  static Future<ApiResponse<List<dynamic>>> getBranches() async {
    try {
      debugPrint('📅 ScheduleService: Obteniendo lista de sucursales...');
      
      final headers = await TokenManager.getAuthHeaders();
      
      // Obtener la respuesta como Map para ver la estructura real
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/restaurant/branches',
        headers,
        null,
        null,
      );

      debugPrint('📅 ScheduleService: Respuesta recibida - status: ${response.status}');
      debugPrint('📅 ScheduleService: Respuesta data type: ${response.data.runtimeType}');
      debugPrint('📅 ScheduleService: Respuesta data: ${response.data}');

      if (response.isSuccess && response.data != null) {
        List<dynamic> branchesData;
        
        // response.data debería ser un Map<String, dynamic> que contiene el campo 'data'
        final responseData = response.data as Map<String, dynamic>;
        
        if (responseData.containsKey('data') && responseData['data'] is List) {
          branchesData = responseData['data'] as List<dynamic>;
        } else if (responseData.containsKey('branches') && responseData['branches'] is List) {
          branchesData = responseData['branches'] as List<dynamic>;
        } else if (response.data is List) {
          // Si response.data es directamente una lista
          branchesData = response.data as List<dynamic>;
        } else {
          debugPrint('❌ Estructura de respuesta inesperada: ${response.data}');
          return ApiResponse<List<dynamic>>(
            status: 'error',
            message: 'Estructura de respuesta inesperada del servidor',
          );
        }
        
        debugPrint('✅ Lista de sucursales obtenida: ${branchesData.length} sucursales');
        debugPrint('✅ Primera sucursal: ${branchesData.isNotEmpty ? branchesData[0] : 'Lista vacía'}');
        
        return ApiResponse<List<dynamic>>(
          status: 'success',
          message: response.message,
          data: branchesData,
        );
      } else {
        debugPrint('❌ Error al obtener sucursales: ${response.message}');
        debugPrint('❌ Código de error: ${response.code}');
        return ApiResponse<List<dynamic>>(
          status: response.status,
          message: response.message,
          code: response.code,
        );
      }
    } catch (e) {
      debugPrint('❌ ScheduleService.getBranches: Error inesperado: $e');
      return ApiResponse<List<dynamic>>(
        status: 'error',
        message: 'Error al obtener la lista de sucursales: ${e.toString()}',
      );
    }
  }

  /// Obtiene el horario semanal completo de una sucursal específica
  static Future<ApiResponse<ScheduleResponse>> getBranchSchedule(int branchId) async {
    try {
      debugPrint('📅 ScheduleService: Obteniendo horario de sucursal $branchId...');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/restaurant/branches/$branchId/schedule',
        headers,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        final scheduleData = ScheduleResponse.fromJson(response.data!);
        
        debugPrint('✅ Horario obtenido para sucursal ${scheduleData.branch.name}: ${scheduleData.schedules.length} días');
        
        return ApiResponse<ScheduleResponse>(
          status: 'success',
          message: response.message,
          data: scheduleData,
        );
      } else {
        debugPrint('❌ Error al obtener horario: ${response.message}');
        return ApiResponse<ScheduleResponse>(
          status: response.status,
          message: response.message,
          code: response.code,
        );
      }
    } catch (e) {
      debugPrint('❌ ScheduleService.getBranchSchedule: Error inesperado: $e');
      return ApiResponse<ScheduleResponse>(
        status: 'error',
        message: 'Error al obtener el horario de la sucursal: ${e.toString()}',
      );
    }
  }

  /// Actualiza el horario semanal completo de una sucursal
  static Future<ApiResponse<ScheduleResponse>> updateWeeklySchedule(
    int branchId,
    WeeklyScheduleUpdateRequest scheduleRequest,
  ) async {
    try {
      debugPrint('📅 ScheduleService: Actualizando horario semanal de sucursal $branchId...');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'PATCH',
        '/restaurant/branches/$branchId/schedule',
        headers,
        scheduleRequest.toJson(),
        null,
      );

      if (response.isSuccess && response.data != null) {
        final scheduleData = ScheduleResponse.fromJson(response.data!);
        
        debugPrint('✅ Horario semanal actualizado exitosamente para ${scheduleData.branch.name}');
        
        return ApiResponse<ScheduleResponse>(
          status: 'success',
          message: response.message,
          data: scheduleData,
        );
      } else {
        debugPrint('❌ Error al actualizar horario semanal: ${response.message}');
        return ApiResponse<ScheduleResponse>(
          status: response.status,
          message: response.message,
          code: response.code,
        );
      }
    } catch (e) {
      debugPrint('❌ ScheduleService.updateWeeklySchedule: Error inesperado: $e');
      return ApiResponse<ScheduleResponse>(
        status: 'error',
        message: 'Error al actualizar el horario semanal: ${e.toString()}',
      );
    }
  }

  /// Actualiza el horario de un día específico de una sucursal
  static Future<ApiResponse<SingleDayScheduleResponse>> updateSingleDaySchedule(
    int branchId,
    int dayOfWeek,
    {
    required String openingTime,
    required String closingTime,
    required bool isClosed,
  }) async {
    try {
      debugPrint('📅 ScheduleService: Actualizando horario del día $dayOfWeek de sucursal $branchId...');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final body = {
        'openingTime': openingTime,
        'closingTime': closingTime,
        'isClosed': isClosed,
      };
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'PATCH',
        '/restaurant/branches/$branchId/schedule/$dayOfWeek',
        headers,
        body,
        null,
      );

      if (response.isSuccess && response.data != null) {
        final scheduleData = SingleDayScheduleResponse.fromJson(response.data!);
        
        debugPrint('✅ Horario del día ${scheduleData.schedule.dayName} actualizado exitosamente');
        
        return ApiResponse<SingleDayScheduleResponse>(
          status: 'success',
          message: response.message,
          data: scheduleData,
        );
      } else {
        debugPrint('❌ Error al actualizar horario del día: ${response.message}');
        return ApiResponse<SingleDayScheduleResponse>(
          status: response.status,
          message: response.message,
          code: response.code,
        );
      }
    } catch (e) {
      debugPrint('❌ ScheduleService.updateSingleDaySchedule: Error inesperado: $e');
      return ApiResponse<SingleDayScheduleResponse>(
        status: 'error',
        message: 'Error al actualizar el horario del día: ${e.toString()}',
      );
    }
  }

  /// Obtiene el horario semanal de la sucursal principal automáticamente
  static Future<ApiResponse<ScheduleResponse>> getPrimaryBranchSchedule() async {
    try {
      final branchId = await TokenManager.getPrimaryBranchId();
      if (branchId == null) {
        return ApiResponse<ScheduleResponse>(
          status: 'error',
          message: 'No se encontró el ID de la sucursal principal',
        );
      }
      
      return await getBranchSchedule(branchId);
    } catch (e) {
      debugPrint('❌ ScheduleService.getPrimaryBranchSchedule: Error inesperado: $e');
      return ApiResponse<ScheduleResponse>(
        status: 'error',
        message: 'Error al obtener el horario de la sucursal principal: ${e.toString()}',
      );
    }
  }

  /// Actualiza el horario semanal de la sucursal principal automáticamente
  static Future<ApiResponse<ScheduleResponse>> updatePrimaryBranchWeeklySchedule(
    WeeklyScheduleUpdateRequest scheduleRequest,
  ) async {
    try {
      final branchId = await TokenManager.getPrimaryBranchId();
      if (branchId == null) {
        return ApiResponse<ScheduleResponse>(
          status: 'error',
          message: 'No se encontró el ID de la sucursal principal',
        );
      }
      
      return await updateWeeklySchedule(branchId, scheduleRequest);
    } catch (e) {
      debugPrint('❌ ScheduleService.updatePrimaryBranchWeeklySchedule: Error inesperado: $e');
      return ApiResponse<ScheduleResponse>(
        status: 'error',
        message: 'Error al actualizar el horario semanal de la sucursal principal: ${e.toString()}',
      );
    }
  }

  /// Actualiza el horario de un día específico de la sucursal principal automáticamente
  static Future<ApiResponse<SingleDayScheduleResponse>> updatePrimaryBranchSingleDaySchedule(
    int dayOfWeek,
    {
      required String openingTime,
      required String closingTime,
      required bool isClosed,
    }
  ) async {
    try {
      final branchId = await TokenManager.getPrimaryBranchId();
      if (branchId == null) {
        return ApiResponse<SingleDayScheduleResponse>(
          status: 'error',
          message: 'No se encontró el ID de la sucursal principal',
        );
      }
      
      return await updateSingleDaySchedule(
        branchId,
        dayOfWeek,
        openingTime: openingTime,
        closingTime: closingTime,
        isClosed: isClosed,
      );
    } catch (e) {
      debugPrint('❌ ScheduleService.updatePrimaryBranchSingleDaySchedule: Error inesperado: $e');
      return ApiResponse<SingleDayScheduleResponse>(
        status: 'error',
        message: 'Error al actualizar el horario del día de la sucursal principal: ${e.toString()}',
      );
    }
  }
}
