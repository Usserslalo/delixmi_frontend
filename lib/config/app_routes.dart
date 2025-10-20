/// Clase que centraliza todas las constantes de rutas de la aplicación
class AppRoutes {
  // Constructor privado para evitar instanciación
  AppRoutes._();

  // ===== RUTAS DE AUTENTICACIÓN =====
  static const String login = '/login';
  static const String register = '/register';
  static const String emailVerification = '/email-verification';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String unsupportedRole = '/unsupported_role';

  // ===== RUTAS DE CLIENTE =====
  static const String home = '/home';
  static const String customerHome = '/customer_home';
  static const String restaurantDetail = '/restaurant-detail';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String cartDetail = '/cart-detail';
  static const String addresses = '/addresses';
  static const String addressForm = '/address-form';
  static const String locationPicker = '/location-picker';
  static const String checkout = '/checkout';
  static const String payment = '/payment';
  static const String orders = '/orders';
  static const String orderDetails = '/order-details';
  static const String orderHistory = '/order-history';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String helpSupport = '/help-support';
  static const String profile = '/profile';

  // ===== RUTAS DE OWNER =====
  static const String ownerDashboard = '/owner_dashboard';
  static const String ownerProfileEdit = '/owner_profile_edit';
  static const String ownerMenu = '/owner_menu';
  static const String ownerModifierGroups = '/owner_modifier_groups';
  static const String ownerCategories = '/owner_categories';
  static const String ownerSubcategories = '/owner_subcategories';
  static const String ownerProducts = '/owner_products';
  static const String setRestaurantLocation = '/set_restaurant_location';
  static const String ownerBranchesListForSchedules = '/owner_branches_list_schedules';
  static const String ownerWeeklySchedule = '/owner_weekly_schedule';
  static const String ownerEditSingleDaySchedule = '/owner_edit_single_day_schedule';
  static const String ownerEditWeeklySchedule = '/owner_edit_weekly_schedule';
  static const String ownerEmployeeList = '/owner_employee_list';
  static const String ownerAddEditEmployee = '/owner_add_edit_employee';

  // ===== RUTAS DE REPARTIDOR =====
  static const String driverDashboard = '/driver_dashboard';

  // ===== RUTAS DE ADMIN =====
  static const String adminDashboard = '/admin_dashboard';

  // ===== RUTAS DE OTROS ROLES =====
  static const String platformDashboard = '/platform_dashboard';
  static const String supportDashboard = '/support_dashboard';
  static const String branchDashboard = '/branch_dashboard';
  static const String ordersDashboard = '/orders_dashboard';
  static const String kitchenDashboard = '/kitchen_dashboard';

  // ===== RUTAS DE TEST =====
  static const String testCartBadge = '/test-cart-badge';
}

