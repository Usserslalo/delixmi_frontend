import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/owner/metrics_models.dart';
import '../../models/api_response.dart';
import '../../services/metrics_service.dart';
import '../../widgets/owner/transactions_widget.dart';

class OwnerMetricsScreen extends StatefulWidget {
  const OwnerMetricsScreen({super.key});

  @override
  State<OwnerMetricsScreen> createState() => _OwnerMetricsScreenState();
}

class _OwnerMetricsScreenState extends State<OwnerMetricsScreen>
    with TickerProviderStateMixin {
  
  // Estado de carga
  bool _isLoading = true;
  String? _errorMessage;
  
  // Datos
  RestaurantWallet? _wallet;
  EarningsResponse? _earnings;
  
  // Controladores
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  // Períodos
  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;
  
  // Colores Material 3
  static const Color primaryOrange = Color(0xFFF2843A);
  static const Color surfaceColor = Color(0xFFFFFBFE);
  static const Color onSurfaceColor = Color(0xFF1C1B1F);
  static const Color surfaceVariantColor = Color(0xFFE7E0EC);
  static const Color outlineColor = Color(0xFF79747E);
  static const Color successColor = Color(0xFF2E7D32);
  static const Color errorColor = Color(0xFFBA1A1A);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Cargar datos en paralelo
      final futures = await Future.wait([
        MetricsService.getWalletBalance(),
        MetricsService.getEarningsSummary(
          dateFrom: _selectedFromDate?.toIso8601String(),
          dateTo: _selectedToDate?.toIso8601String(),
        ),
      ]);

      final walletResponse = futures[0] as ApiResponse<RestaurantWallet>;
      final earningsResponse = futures[1] as ApiResponse<EarningsResponse>;

      if (mounted) {
        setState(() {
          if (walletResponse.isSuccess) {
            _wallet = walletResponse.data;
          } else {
            _errorMessage = walletResponse.message;
          }

          if (earningsResponse.isSuccess) {
            _earnings = earningsResponse.data;
          } else {
            // Si no hay error con wallet pero sí con earnings, no marcar como error general
            if (_errorMessage == null) {
              _errorMessage = earningsResponse.message;
            }
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading initial data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar los datos: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: _buildModernAppBar(),
      body: _isLoading 
          ? _buildLoadingState() 
          : _errorMessage != null 
              ? _buildErrorState()
              : _buildBody(),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: false,
      toolbarHeight: 64,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: onSurfaceColor,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Métricas Financieras',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: onSurfaceColor,
            ),
          ),
          if (_selectedFromDate != null || _selectedToDate != null)
            Text(
              _buildDateRangeText(),
              style: TextStyle(
                fontSize: 12,
                color: outlineColor,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showDateRangePicker,
          icon: Icon(
            _selectedFromDate != null ? Icons.date_range : Icons.date_range_outlined,
          ),
          style: IconButton.styleFrom(
            backgroundColor: _selectedFromDate != null 
                ? primaryOrange.withOpacity(0.1) 
                : surfaceVariantColor,
            foregroundColor: _selectedFromDate != null 
                ? primaryOrange 
                : onSurfaceColor,
          ),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: outlineColor.withOpacity(0.2),
                width: 0.5,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: primaryOrange,
            unselectedLabelColor: outlineColor,
            indicatorColor: primaryOrange,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Resumen'),
              Tab(text: 'Transacciones'),
            ],
          ),
        ),
      ),
    );
  }

  String _buildDateRangeText() {
    if (_selectedFromDate != null && _selectedToDate != null) {
      final from = _selectedFromDate!;
      final to = _selectedToDate!;
      if (from.year == to.year && from.month == to.month && from.day == to.day) {
        return '${from.day}/${from.month}/${from.year}';
      }
      return '${from.day}/${from.month} - ${to.day}/${to.month}/${to.year}';
    } else if (_selectedFromDate != null) {
      final date = _selectedFromDate!;
      return 'Desde ${date.day}/${date.month}/${date.year}';
    } else if (_selectedToDate != null) {
      final date = _selectedToDate!;
      return 'Hasta ${date.day}/${date.month}/${date.year}';
    }
    return '';
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Header con saldo actual
        _buildWalletHeader(),
        
        // Contenido principal con tabs
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSummaryTab(),
              _buildTransactionsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWalletHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryOrange, primaryOrange.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo Actual',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _wallet != null 
                      ? '\$${_wallet!.balance.toStringAsFixed(2)}'
                      : '\$0.00',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _wallet?.restaurant.name ?? 'Restaurante',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (_selectedFromDate != null || _selectedToDate != null)
            TextButton.icon(
              onPressed: _clearDateRange,
              icon: const Icon(Icons.clear_rounded, size: 18),
              label: const Text('Limpiar'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    if (_earnings == null) {
      return _buildEmptyEarningsState();
    }

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Período
            _buildPeriodCard(),
            const SizedBox(height: 16),
            
            // Métricas principales
            _buildMainMetrics(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, 
                color: primaryOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Período de Análisis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPeriodItem(
                  'Desde',
                  _earnings!.period.from?.toString() ?? 'No especificado',
                  Icons.play_arrow_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPeriodItem(
                  'Hasta',
                  _earnings!.period.to?.toString() ?? 'No especificado',
                  Icons.stop_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceVariantColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: outlineColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: outlineColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: onSurfaceColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMetrics() {
    final summary = _earnings!.summary;
    
    // Calcular el porcentaje de ganancias para mostrarlo prominentemente
    final earningsPercentage = summary.totalRevenue > 0 
        ? (summary.totalEarnings / summary.totalRevenue) * 100 
        : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rendimiento del Período',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: onSurfaceColor,
          ),
        ),
        const SizedBox(height: 16),
        
        // Primera fila: Ingresos Totales (primero) y Ganancias Totales (segundo)
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Ingresos Totales',
                '\$${summary.totalRevenue.toStringAsFixed(2)}',
                Icons.receipt_long_rounded,
                primaryOrange,
                'Facturación Bruta (100%)',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Ganancias Totales',
                '\$${summary.totalEarnings.toStringAsFixed(2)}',
                Icons.trending_up_rounded,
                successColor,
                'Tu Pago Neto (${earningsPercentage.toStringAsFixed(1)}%)',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Segunda fila: Porcentaje de Ganancias (prominente) y Pedidos Entregados
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Porcentaje de Ganancias',
                '${earningsPercentage.toStringAsFixed(1)}%',
                Icons.pie_chart_rounded,
                Colors.deepPurple,
                'Comisión transparente',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Pedidos Entregados',
                summary.ordersDelivered.toString(),
                Icons.check_circle_rounded,
                Colors.blue,
                'Pedidos completados',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Tercera fila: Ganancia Promedio (centrada)
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Ganancia Promedio',
                '\$${summary.averageOrderValue.toStringAsFixed(2)}',
                Icons.analytics_rounded,
                Colors.purple,
                'Por pedido entregado',
              ),
            ),
            const SizedBox(width: 12),
            // Espacio vacío para mantener el layout consistente
            Expanded(
              child: Container(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: outlineColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: onSurfaceColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: outlineColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTransactionsTab() {
    return const TransactionsWidget();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Cargando métricas financieras...',
            style: TextStyle(
              fontSize: 16,
              color: outlineColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: errorColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar métricas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: onSurfaceColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Ocurrió un error inesperado',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: outlineColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _loadInitialData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyEarningsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: outlineColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 64,
                color: outlineColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin datos de ganancias',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: onSurfaceColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Los datos de ganancias aparecerán aquí una vez que comiences a recibir pedidos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: outlineColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedFromDate != null && _selectedToDate != null
          ? DateTimeRange(start: _selectedFromDate!, end: _selectedToDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryOrange,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedFromDate = picked.start;
        _selectedToDate = picked.end;
      });
      
      _loadEarningsWithDateRange();
    }
  }

  void _clearDateRange() {
    setState(() {
      _selectedFromDate = null;
      _selectedToDate = null;
    });
    
    _loadEarningsWithDateRange();
  }

  Future<void> _loadEarningsWithDateRange() async {
    try {
      final response = await MetricsService.getEarningsSummary(
        dateFrom: _selectedFromDate?.toIso8601String(),
        dateTo: _selectedToDate?.toIso8601String(),
      );

      if (mounted && response.isSuccess) {
        setState(() {
          _earnings = response.data;
        });
      } else if (mounted) {
        setState(() {
          _errorMessage = response.message;
        });
      }
    } catch (e) {
      debugPrint('Error loading earnings: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar ganancias: ${e.toString()}';
        });
      }
    }
  }
}
