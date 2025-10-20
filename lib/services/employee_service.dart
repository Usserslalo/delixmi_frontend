import 'package:flutter/foundation.dart';
import '../models/api_response.dart';
import 'api_service.dart';
import 'token_manager.dart';

class EmployeeService {
  /// Obtiene la lista de empleados del restaurante del owner autenticado
  static Future<ApiResponse<Map<String, dynamic>>> getEmployees({
    int page = 1,
    int pageSize = 15,
    int? roleId,
    String? status,
    String? search,
  }) async {
    try {
      debugPrint('👥 EmployeeService: Obteniendo lista de empleados...');
      debugPrint('👥 Parámetros - page: $page, pageSize: $pageSize, roleId: $roleId, status: $status, search: $search');
      
      final headers = await TokenManager.getAuthHeaders();
      
      // Construir query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      
      if (roleId != null) {
        queryParams['roleId'] = roleId.toString();
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      // Construir URL con query parameters
      String endpoint = '/restaurant/employees';
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
        endpoint += '?$queryString';
      }
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        endpoint,
        headers,
        null,
        null,
      );

      debugPrint('👥 EmployeeService: Respuesta recibida - status: ${response.status}');

      if (response.isSuccess) {
        debugPrint('✅ Lista de empleados obtenida exitosamente');
        return response;
      } else {
        debugPrint('❌ Error al obtener empleados: ${response.message}');
        return response;
      }
    } catch (e) {
      debugPrint('❌ Error inesperado en getEmployees: $e');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error inesperado al obtener empleados: ${e.toString()}',
      );
    }
  }

  /// Crea un nuevo empleado para el restaurante
  static Future<ApiResponse<Map<String, dynamic>>> createEmployee({
    required String email,
    required String password,
    required String name,
    required String lastname,
    required String phone,
    required int roleId,
  }) async {
    try {
      debugPrint('👥 EmployeeService: Creando nuevo empleado...');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final body = {
        'email': email,
        'password': password,
        'name': name,
        'lastname': lastname,
        'phone': phone,
        'roleId': roleId,
      };
      
      debugPrint('👥 Body enviado: $body');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'POST',
        '/restaurant/employees',
        headers,
        body,
        null,
      );

      debugPrint('👥 EmployeeService: Respuesta recibida - status: ${response.status}');

      if (response.isSuccess) {
        debugPrint('✅ Empleado creado exitosamente');
        return response;
      } else {
        debugPrint('❌ Error al crear empleado: ${response.message}');
        return response;
      }
    } catch (e) {
      debugPrint('❌ Error inesperado en createEmployee: $e');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error inesperado al crear empleado: ${e.toString()}',
      );
    }
  }

  /// Actualiza un empleado existente (rol y/o estado)
  static Future<ApiResponse<Map<String, dynamic>>> updateEmployee({
    required int assignmentId,
    int? roleId,
    String? status,
  }) async {
    try {
      debugPrint('👥 EmployeeService: Actualizando empleado con assignmentId: $assignmentId...');
      
      if (roleId == null && status == null) {
        return ApiResponse<Map<String, dynamic>>(
          status: 'error',
          message: 'Debe proporcionar al menos uno de los campos: roleId o status',
        );
      }
      
      final headers = await TokenManager.getAuthHeaders();
      
      final body = <String, dynamic>{};
      if (roleId != null) {
        body['roleId'] = roleId;
      }
      if (status != null) {
        body['status'] = status;
      }
      
      debugPrint('👥 Body enviado: $body');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'PATCH',
        '/restaurant/employees/$assignmentId',
        headers,
        body,
        null,
      );

      debugPrint('👥 EmployeeService: Respuesta recibida - status: ${response.status}');

      if (response.isSuccess) {
        debugPrint('✅ Empleado actualizado exitosamente');
        return response;
      } else {
        debugPrint('❌ Error al actualizar empleado: ${response.message}');
        return response;
      }
    } catch (e) {
      debugPrint('❌ Error inesperado en updateEmployee: $e');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error inesperado al actualizar empleado: ${e.toString()}',
      );
    }
  }
}
