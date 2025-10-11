import 'package:flutter/foundation.dart' hide Category;
import '../models/menu/menu_models.dart';
import '../models/api_response.dart';
import 'api_service.dart';
import 'token_manager.dart';

class MenuService {
  /// Obtiene todas las categorías globales disponibles
  static Future<ApiResponse<List<Category>>> getCategories() async {
    try {
      debugPrint('📚 MenuService: Obteniendo categorías globales...');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/categories',
        ApiService.defaultHeaders,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        final categoriesData = response.data!['categories'] as List;
        final categories = categoriesData.map((c) => Category.fromJson(c)).toList();
        
        debugPrint('✅ Categorías obtenidas: ${categories.length}');
        
        return ApiResponse<List<Category>>(
          status: 'success',
          message: response.message,
          data: categories,
        );
      } else {
        return ApiResponse<List<Category>>(
          status: response.status,
          message: response.message,
          code: response.code,
        );
      }
    } catch (e) {
      debugPrint('❌ MenuService.getCategories: Error: $e');
      return ApiResponse<List<Category>>(
        status: 'error',
        message: 'Error al obtener categorías: ${e.toString()}',
      );
    }
  }

  /// Obtiene las subcategorías del restaurante del owner
  static Future<ApiResponse<List<Subcategory>>> getSubcategories({
    int? categoryId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      debugPrint('📋 MenuService: Obteniendo subcategorías...');
      
      final headers = await TokenManager.getAuthHeaders();
      
      String endpoint = '/restaurant/subcategories?page=$page&pageSize=$pageSize';
      if (categoryId != null) {
        endpoint += '&categoryId=$categoryId';
      }
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        endpoint,
        headers,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        final subcategoriesData = response.data!['subcategories'] as List;
        final subcategories = subcategoriesData
            .map((s) => Subcategory.fromJson(s))
            .toList();
        
        debugPrint('✅ Subcategorías obtenidas: ${subcategories.length}');
        
        return ApiResponse<List<Subcategory>>(
          status: 'success',
          message: response.message,
          data: subcategories,
        );
      } else {
        return ApiResponse<List<Subcategory>>(
          status: response.status,
          message: response.message,
          code: response.code,
        );
      }
    } catch (e) {
      debugPrint('❌ MenuService.getSubcategories: Error: $e');
      return ApiResponse<List<Subcategory>>(
        status: 'error',
        message: 'Error al obtener subcategorías: ${e.toString()}',
      );
    }
  }

  /// Obtiene los productos del restaurante
  static Future<ApiResponse<List<MenuProduct>>> getProducts({
    int? subcategoryId,
    bool? isAvailable,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      debugPrint('🍕 MenuService: Obteniendo productos...');
      
      final headers = await TokenManager.getAuthHeaders();
      
      String endpoint = '/restaurant/products?page=$page&pageSize=$pageSize';
      if (subcategoryId != null) {
        endpoint += '&subcategoryId=$subcategoryId';
      }
      if (isAvailable != null) {
        endpoint += '&isAvailable=$isAvailable';
      }
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        endpoint,
        headers,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        final productsData = response.data!['products'] as List;
        final products = productsData
            .map((p) => MenuProduct.fromJson(p))
            .toList();
        
        debugPrint('✅ Productos obtenidos: ${products.length}');
        
        return ApiResponse<List<MenuProduct>>(
          status: 'success',
          message: response.message,
          data: products,
        );
      } else {
        return ApiResponse<List<MenuProduct>>(
          status: response.status,
          message: response.message,
          code: response.code,
        );
      }
    } catch (e) {
      debugPrint('❌ MenuService.getProducts: Error: $e');
      return ApiResponse<List<MenuProduct>>(
        status: 'error',
        message: 'Error al obtener productos: ${e.toString()}',
      );
    }
  }

  /// Obtiene los grupos de modificadores del restaurante
  static Future<ApiResponse<List<ModifierGroup>>> getModifierGroups() async {
    try {
      debugPrint('🔧 MenuService: Obteniendo grupos de modificadores...');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/restaurant/modifier-groups',
        headers,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        final groupsData = response.data!['modifierGroups'] as List;
        final groups = groupsData
            .map((g) => ModifierGroup.fromJson(g))
            .toList();
        
        debugPrint('✅ Grupos de modificadores obtenidos: ${groups.length}');
        
        return ApiResponse<List<ModifierGroup>>(
          status: 'success',
          message: response.message,
          data: groups,
        );
      } else {
        return ApiResponse<List<ModifierGroup>>(
          status: response.status,
          message: response.message,
          code: response.code,
        );
      }
    } catch (e) {
      debugPrint('❌ MenuService.getModifierGroups: Error: $e');
      return ApiResponse<List<ModifierGroup>>(
        status: 'error',
        message: 'Error al obtener grupos de modificadores: ${e.toString()}',
      );
    }
  }

  /// Crea una nueva subcategoría
  static Future<ApiResponse<Subcategory>> createSubcategory({
    required int categoryId,
    required String name,
    int displayOrder = 0,
  }) async {
    try {
      debugPrint('➕ MenuService: Creando subcategoría...');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'POST',
        '/restaurant/subcategories',
        headers,
        {
          'categoryId': categoryId,
          'name': name,
          'displayOrder': displayOrder,
        },
        null,
      );

      if (response.isSuccess && response.data != null) {
        final subcategory = Subcategory.fromJson(response.data!['subcategory']);
        
        debugPrint('✅ Subcategoría creada: ${subcategory.name}');
        
        return ApiResponse<Subcategory>(
          status: 'success',
          message: response.message,
          data: subcategory,
        );
      } else {
        return ApiResponse<Subcategory>(
          status: response.status,
          message: response.message,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ MenuService.createSubcategory: Error: $e');
      return ApiResponse<Subcategory>(
        status: 'error',
        message: 'Error al crear subcategoría: ${e.toString()}',
      );
    }
  }

  /// Actualiza una subcategoría existente
  static Future<ApiResponse<Subcategory>> updateSubcategory({
    required int subcategoryId,
    int? categoryId,
    String? name,
    int? displayOrder,
  }) async {
    try {
      debugPrint('🔄 MenuService: Actualizando subcategoría ID: $subcategoryId');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final Map<String, dynamic> body = {};
      if (categoryId != null) body['categoryId'] = categoryId;
      if (name != null) body['name'] = name;
      if (displayOrder != null) body['displayOrder'] = displayOrder;
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'PATCH',
        '/restaurant/subcategories/$subcategoryId',
        headers,
        body.isNotEmpty ? body : null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        final subcategory = Subcategory.fromJson(response.data!['subcategory']);
        
        debugPrint('✅ Subcategoría actualizada: ${subcategory.name}');
        
        return ApiResponse<Subcategory>(
          status: 'success',
          message: response.message,
          data: subcategory,
        );
      } else {
        return ApiResponse<Subcategory>(
          status: response.status,
          message: response.message,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ MenuService.updateSubcategory: Error: $e');
      return ApiResponse<Subcategory>(
        status: 'error',
        message: 'Error al actualizar subcategoría: ${e.toString()}',
      );
    }
  }

  /// Elimina una subcategoría
  static Future<ApiResponse<void>> deleteSubcategory(int subcategoryId) async {
    try {
      debugPrint('🗑️ MenuService: Eliminando subcategoría ID: $subcategoryId');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'DELETE',
        '/restaurant/subcategories/$subcategoryId',
        headers,
        null,
        null,
      );

      if (response.isSuccess) {
        debugPrint('✅ Subcategoría eliminada exitosamente');
        
        return ApiResponse<void>(
          status: 'success',
          message: response.message,
          data: null,
        );
      } else {
        return ApiResponse<void>(
          status: response.status,
          message: response.message,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ MenuService.deleteSubcategory: Error: $e');
      return ApiResponse<void>(
        status: 'error',
        message: 'Error al eliminar subcategoría: ${e.toString()}',
      );
    }
  }

  /// Crea un nuevo producto con sus modificadores asociados
  static Future<ApiResponse<MenuProduct>> createProduct({
    required int subcategoryId,
    required String name,
    String? description,
    String? imageUrl,
    required double price,
    bool isAvailable = true,
    List<int> modifierGroupIds = const [],
  }) async {
    try {
      debugPrint('➕ MenuService: Creando producto...');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final Map<String, dynamic> body = {
        'subcategoryId': subcategoryId,
        'name': name,
        'price': price,
        'isAvailable': isAvailable,
        'modifierGroupIds': modifierGroupIds,
      };
      
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }
      
      if (imageUrl != null && imageUrl.isNotEmpty) {
        body['imageUrl'] = imageUrl;
      }

      debugPrint('📤 Body del producto: $body');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'POST',
        '/restaurant/products',
        headers,
        body,
        null,
      );

      if (response.isSuccess && response.data != null) {
        debugPrint('🔍 Parsing producto desde: ${response.data}');
        
        try {
          final product = MenuProduct.fromJson(response.data!['product']);
          
          debugPrint('✅ Producto creado: ${product.name}');
          
          return ApiResponse<MenuProduct>(
            status: 'success',
            message: response.message,
            data: product,
          );
        } catch (parseError) {
          debugPrint('❌ Error parsing producto: $parseError');
          debugPrint('❌ Data recibida: ${response.data}');
          
          return ApiResponse<MenuProduct>(
            status: 'error',
            message: 'Error al parsear la respuesta del producto: $parseError',
          );
        }
      } else {
        return ApiResponse<MenuProduct>(
          status: response.status,
          message: response.message,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ MenuService.createProduct: Error: $e');
      return ApiResponse<MenuProduct>(
        status: 'error',
        message: 'Error al crear producto: ${e.toString()}',
      );
    }
  }

  /// Actualiza un producto existente
  static Future<ApiResponse<MenuProduct>> updateProduct({
    required int productId,
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    bool? isAvailable,
    int? subcategoryId,
    List<int>? modifierGroupIds,
  }) async {
    try {
      debugPrint('🔄 MenuService: Actualizando producto ID: $productId');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (imageUrl != null) body['imageUrl'] = imageUrl;
      if (price != null) body['price'] = price;
      if (isAvailable != null) body['isAvailable'] = isAvailable;
      if (subcategoryId != null) body['subcategoryId'] = subcategoryId;
      if (modifierGroupIds != null) body['modifierGroupIds'] = modifierGroupIds;

      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'PATCH',
        '/restaurant/products/$productId',
        headers,
        body,
        null,
      );

      if (response.isSuccess && response.data != null) {
        debugPrint('✅ Producto actualizado exitosamente');
        final product = MenuProduct.fromJson(response.data!['product']);
        return ApiResponse<MenuProduct>(
          status: 'success',
          message: response.message,
          data: product,
        );
      } else {
        return ApiResponse<MenuProduct>(
          status: response.status,
          message: response.message,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ MenuService.updateProduct: Error: $e');
      return ApiResponse<MenuProduct>(
        status: 'error',
        message: 'Error al actualizar producto: ${e.toString()}',
      );
    }
  }

  /// Elimina un producto
  static Future<ApiResponse<void>> deleteProduct(int productId) async {
    try {
      debugPrint('🗑️ MenuService: Eliminando producto ID: $productId');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'DELETE',
        '/restaurant/products/$productId',
        headers,
        null,
        null,
      );

      if (response.isSuccess) {
        debugPrint('✅ Producto eliminado exitosamente');
        
        return ApiResponse<void>(
          status: 'success',
          message: response.message,
          data: null,
        );
      } else {
        return ApiResponse<void>(
          status: response.status,
          message: response.message,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ MenuService.deleteProduct: Error: $e');
      return ApiResponse<void>(
        status: 'error',
        message: 'Error al eliminar producto: ${e.toString()}',
      );
    }
  }

  // ========== GRUPOS DE MODIFICADORES ==========

  /// Crea un nuevo grupo de modificadores
  static Future<ApiResponse<ModifierGroup>> createModifierGroup({
    required String name,
    int minSelection = 1,
    int maxSelection = 1,
  }) async {
    try {
      debugPrint('➕ MenuService: Creando grupo de modificadores...');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'POST',
        '/restaurant/modifier-groups',
        headers,
        {
          'name': name,
          'minSelection': minSelection,
          'maxSelection': maxSelection,
        },
        null,
      );

      if (response.isSuccess && response.data != null) {
        final modifierGroup = ModifierGroup.fromJson(response.data!['modifierGroup']);
        
        debugPrint('✅ Grupo de modificadores creado: ${modifierGroup.name}');
        
        return ApiResponse<ModifierGroup>(
          status: 'success',
          message: response.message,
          data: modifierGroup,
        );
      } else {
        return ApiResponse<ModifierGroup>(
          status: response.status,
          message: response.message,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ MenuService.createModifierGroup: Error: $e');
      return ApiResponse<ModifierGroup>(
        status: 'error',
        message: 'Error al crear grupo de modificadores: ${e.toString()}',
      );
    }
  }

  /// Actualiza un grupo de modificadores
  static Future<ApiResponse<ModifierGroup>> updateModifierGroup({
    required int groupId,
    String? name,
    int? minSelection,
    int? maxSelection,
  }) async {
    try {
      debugPrint('🔄 MenuService: Actualizando grupo de modificadores ID: $groupId');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (minSelection != null) body['minSelection'] = minSelection;
      if (maxSelection != null) body['maxSelection'] = maxSelection;
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'PATCH',
        '/restaurant/modifier-groups/$groupId',
        headers,
        body.isNotEmpty ? body : null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        final modifierGroup = ModifierGroup.fromJson(response.data!['modifierGroup']);
        
        debugPrint('✅ Grupo de modificadores actualizado: ${modifierGroup.name}');
        
        return ApiResponse<ModifierGroup>(
          status: 'success',
          message: response.message,
          data: modifierGroup,
        );
      } else {
        return ApiResponse<ModifierGroup>(
          status: response.status,
          message: response.message,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ MenuService.updateModifierGroup: Error: $e');
      return ApiResponse<ModifierGroup>(
        status: 'error',
        message: 'Error al actualizar grupo de modificadores: ${e.toString()}',
      );
    }
  }

  /// Elimina un grupo de modificadores
  static Future<ApiResponse<void>> deleteModifierGroup(int groupId) async {
    try {
      debugPrint('🗑️ MenuService: Eliminando grupo de modificadores ID: $groupId');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'DELETE',
        '/restaurant/modifier-groups/$groupId',
        headers,
        null,
        null,
      );

      if (response.isSuccess) {
        debugPrint('✅ Grupo de modificadores eliminado exitosamente');
        
        return ApiResponse<void>(
          status: 'success',
          message: response.message,
          data: null,
        );
      } else {
        return ApiResponse<void>(
          status: response.status,
          message: response.message,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ MenuService.deleteModifierGroup: Error: $e');
      return ApiResponse<void>(
        status: 'error',
        message: 'Error al eliminar grupo de modificadores: ${e.toString()}',
      );
    }
  }

  // ========== OPCIONES DE MODIFICADORES ==========

  /// Añade una opción a un grupo de modificadores
  static Future<ApiResponse<ModifierOption>> addModifierOption({
    required int groupId,
    required String name,
    required double price,
  }) async {
    try {
      debugPrint('➕ MenuService: Añadiendo opción al grupo ID: $groupId');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'POST',
        '/restaurant/modifier-groups/$groupId/options',
        headers,
        {
          'name': name,
          'price': price,
        },
        null,
      );

      if (response.isSuccess && response.data != null) {
        final modifierOption = ModifierOption.fromJson(response.data!['modifierOption']);
        
        debugPrint('✅ Opción de modificador creada: ${modifierOption.name}');
        
        return ApiResponse<ModifierOption>(
          status: 'success',
          message: response.message,
          data: modifierOption,
        );
      } else {
        return ApiResponse<ModifierOption>(
          status: response.status,
          message: response.message,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ MenuService.addModifierOption: Error: $e');
      return ApiResponse<ModifierOption>(
        status: 'error',
        message: 'Error al añadir opción de modificador: ${e.toString()}',
      );
    }
  }

  /// Actualiza una opción de modificador
  static Future<ApiResponse<ModifierOption>> updateModifierOption({
    required int optionId,
    String? name,
    double? price,
  }) async {
    try {
      debugPrint('🔄 MenuService: Actualizando opción de modificador ID: $optionId');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (price != null) body['price'] = price;
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'PATCH',
        '/restaurant/modifier-options/$optionId',
        headers,
        body.isNotEmpty ? body : null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        final modifierOption = ModifierOption.fromJson(response.data!['modifierOption']);
        
        debugPrint('✅ Opción de modificador actualizada: ${modifierOption.name}');
        
        return ApiResponse<ModifierOption>(
          status: 'success',
          message: response.message,
          data: modifierOption,
        );
      } else {
        return ApiResponse<ModifierOption>(
          status: response.status,
          message: response.message,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ MenuService.updateModifierOption: Error: $e');
      return ApiResponse<ModifierOption>(
        status: 'error',
        message: 'Error al actualizar opción de modificador: ${e.toString()}',
      );
    }
  }

  /// Elimina una opción de modificador
  static Future<ApiResponse<void>> deleteModifierOption(int optionId) async {
    try {
      debugPrint('🗑️ MenuService: Eliminando opción de modificador ID: $optionId');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'DELETE',
        '/restaurant/modifier-options/$optionId',
        headers,
        null,
        null,
      );

      if (response.isSuccess) {
        debugPrint('✅ Opción de modificador eliminada exitosamente');
        
        return ApiResponse<void>(
          status: 'success',
          message: response.message,
          data: null,
        );
      } else {
        return ApiResponse<void>(
          status: response.status,
          message: response.message,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ MenuService.deleteModifierOption: Error: $e');
      return ApiResponse<void>(
        status: 'error',
        message: 'Error al eliminar opción de modificador: ${e.toString()}',
      );
    }
  }
}
