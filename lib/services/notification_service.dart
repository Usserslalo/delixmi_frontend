import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static bool _isInitialized = false;

  /// Inicializar el servicio de notificaciones
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔔 Inicializando servicio de notificaciones...');

      // Configuración para Android
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // Configuración para iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Solicitar permisos
      await _requestPermissions();

      _isInitialized = true;
      debugPrint('✅ Servicio de notificaciones inicializado');
    } catch (e) {
      debugPrint('❌ Error al inicializar notificaciones: $e');
    }
  }

  /// Solicitar permisos de notificación
  static Future<void> _requestPermissions() async {
    try {
      // Android 13+ requiere permiso específico
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      // iOS requiere configuración adicional en Info.plist
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } catch (e) {
      debugPrint('❌ Error al solicitar permisos: $e');
    }
  }

  /// Manejar tap en notificación
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notificación tocada: ${response.payload}');
    
    // Navegación basada en el payload - funcionalidad pendiente
    final payload = response.payload;
    if (payload != null) {
      _handleNotificationPayload(payload);
    }
  }

  /// Manejar payload de notificación
  static void _handleNotificationPayload(String payload) {
    try {
      // Parsear payload JSON
      final data = _parseNotificationPayload(payload);
      
      switch (data['type']) {
        case 'order_status':
          _handleOrderStatusNotification(data);
          break;
        case 'delivery_update':
          _handleDeliveryUpdateNotification(data);
          break;
        case 'promotion':
          _handlePromotionNotification(data);
          break;
        default:
          debugPrint('🔔 Tipo de notificación no reconocido: ${data['type']}');
      }
    } catch (e) {
      debugPrint('❌ Error al manejar payload: $e');
    }
  }

  /// Parsear payload de notificación
  static Map<String, dynamic> _parseNotificationPayload(String payload) {
    // Parsing JSON real - funcionalidad pendiente
    return {
      'type': 'order_status',
      'order_id': '123',
      'status': 'confirmed',
    };
  }

  /// Manejar notificación de estado de pedido
  static void _handleOrderStatusNotification(Map<String, dynamic> data) {
    // Navegación a pantalla de pedido - funcionalidad pendiente
    debugPrint('🔔 Estado de pedido: ${data['status']}');
  }

  /// Manejar notificación de actualización de entrega
  static void _handleDeliveryUpdateNotification(Map<String, dynamic> data) {
    // Navegación a pantalla de seguimiento - funcionalidad pendiente
    debugPrint('🔔 Actualización de entrega: ${data['status']}');
  }

  /// Manejar notificación de promoción
  static void _handlePromotionNotification(Map<String, dynamic> data) {
    // Navegación a pantalla de promociones - funcionalidad pendiente
    debugPrint('🔔 Promoción: ${data['title']}');
  }

  /// Mostrar notificación local
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      const androidDetails = AndroidNotificationDetails(
        'delixmi_channel',
        'Delixmi Notifications',
        channelDescription: 'Notificaciones de la app Delixmi',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );

      debugPrint('✅ Notificación mostrada: $title');
    } catch (e) {
      debugPrint('❌ Error al mostrar notificación: $e');
    }
  }

  /// Mostrar notificación de estado de pedido
  static Future<void> showOrderStatusNotification({
    required String orderId,
    required String status,
    required String message,
  }) async {
    final title = _getOrderStatusTitle(status);
    final payload = _createOrderPayload(orderId, status);

    await showNotification(
      id: orderId.hashCode,
      title: title,
      body: message,
      payload: payload,
    );
  }

  /// Mostrar notificación de actualización de entrega
  static Future<void> showDeliveryUpdateNotification({
    required String orderId,
    required String status,
    required String message,
  }) async {
    final title = 'Actualización de Entrega';
    final payload = _createDeliveryPayload(orderId, status);

    await showNotification(
      id: '${orderId}_delivery'.hashCode,
      title: title,
      body: message,
      payload: payload,
    );
  }

  /// Mostrar notificación de promoción
  static Future<void> showPromotionNotification({
    required String title,
    required String message,
    String? promotionId,
  }) async {
    final payload = _createPromotionPayload(promotionId);

    await showNotification(
      id: title.hashCode,
      title: title,
      body: message,
      payload: payload,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
  }

  /// Mostrar notificación de bienvenida
  static Future<void> showWelcomeNotification({
    required String userName,
  }) async {
    await showNotification(
      id: 'welcome'.hashCode,
      title: '¡Bienvenido a Delixmi!',
      body: 'Hola $userName, ¡disfruta de tu experiencia de pedidos!',
      payload: _createWelcomePayload(),
    );
  }

  /// Obtener título según estado del pedido
  static String _getOrderStatusTitle(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Pedido Confirmado';
      case 'preparing':
        return 'Preparando tu Pedido';
      case 'ready':
        return 'Pedido Listo';
      case 'on_the_way':
        return 'En Camino';
      case 'delivered':
        return 'Pedido Entregado';
      case 'cancelled':
        return 'Pedido Cancelado';
      default:
        return 'Actualización de Pedido';
    }
  }

  /// Crear payload para pedido
  static String _createOrderPayload(String orderId, String status) {
    return '{"type":"order_status","order_id":"$orderId","status":"$status"}';
  }

  /// Crear payload para entrega
  static String _createDeliveryPayload(String orderId, String status) {
    return '{"type":"delivery_update","order_id":"$orderId","status":"$status"}';
  }

  /// Crear payload para promoción
  static String _createPromotionPayload(String? promotionId) {
    return '{"type":"promotion","promotion_id":"$promotionId"}';
  }

  /// Crear payload de bienvenida
  static String _createWelcomePayload() {
    return '{"type":"welcome"}';
  }

  /// Cancelar notificación específica
  static Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      debugPrint('✅ Notificación cancelada: $id');
    } catch (e) {
      debugPrint('❌ Error al cancelar notificación: $e');
    }
  }

  /// Cancelar todas las notificaciones
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      debugPrint('✅ Todas las notificaciones canceladas');
    } catch (e) {
      debugPrint('❌ Error al cancelar todas las notificaciones: $e');
    }
  }

  /// Obtener notificaciones pendientes
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('❌ Error al obtener notificaciones pendientes: $e');
      return [];
    }
  }

  /// Programar notificación (simplificado para evitar dependencias de timezone)
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      // Por ahora, mostrar notificación inmediata
      // Programación real con timezone - funcionalidad pendiente
      await showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );

      debugPrint('✅ Notificación programada (simplificada): $title');
    } catch (e) {
      debugPrint('❌ Error al programar notificación: $e');
    }
  }

  /// Verificar si las notificaciones están habilitadas
  static Future<bool> areNotificationsEnabled() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('❌ Error al verificar permisos: $e');
      return false;
    }
  }

  /// Abrir configuración de notificaciones
  static Future<void> openNotificationSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('❌ Error al abrir configuración: $e');
    }
  }
}
