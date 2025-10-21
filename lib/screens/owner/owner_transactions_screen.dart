import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/owner/metrics_models.dart';
import '../../services/metrics_service.dart';

class OwnerTransactionsScreen extends StatefulWidget {
  const OwnerTransactionsScreen({super.key});

  @override
  State<OwnerTransactionsScreen> createState() => _OwnerTransactionsScreenState();
}

class _OwnerTransactionsScreenState extends State<OwnerTransactionsScreen> {
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _errorMessage;
  
  List<WalletTransaction> _transactions = [];
  TransactionPagination? _pagination;
  
  int _currentPage = 1;
  final int _pageSize = 20;
  
  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;
  
  final ScrollController _scrollController = ScrollController();

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
    _loadTransactions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      if (_pagination?.hasNextPage == true && !_isLoading) {
        _loadNextPage();
      }
    }
  }

  Future<void> _loadTransactions() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (_currentPage == 1) {
        _isInitialLoading = true;
        _transactions.clear();
      }
    });

    try {
      final response = await MetricsService.getWalletTransactions(
        page: _currentPage,
        pageSize: _pageSize,
        dateFrom: _selectedFromDate?.toIso8601String(),
        dateTo: _selectedToDate?.toIso8601String(),
      );

      if (mounted) {
        if (response.isSuccess && response.data != null) {
          setState(() {
            if (_currentPage == 1) {
              _transactions = response.data!.transactions;
            } else {
              _transactions.addAll(response.data!.transactions);
            }
            _pagination = response.data!.pagination;
            _isLoading = false;
            _isInitialLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = response.message;
            _isLoading = false;
            _isInitialLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar transacciones: ${e.toString()}';
          _isLoading = false;
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _loadNextPage() async {
    if (_pagination?.hasNextPage == true) {
      setState(() {
        _currentPage++;
      });
      await _loadTransactions();
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _currentPage = 1;
    });
    await _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: _buildModernAppBar(),
      body: _isInitialLoading
          ? _buildLoadingState()
          : _errorMessage != null && _transactions.isEmpty
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: onSurfaceColor,
        ),
      ),
      title: Text(
        'Historial de Transacciones',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurfaceColor,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showDateRangePicker,
          icon: const Icon(Icons.filter_list_rounded),
          style: IconButton.styleFrom(
            backgroundColor: surfaceVariantColor,
            foregroundColor: onSurfaceColor,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Filtros de fecha
        if (_selectedFromDate != null && _selectedToDate != null)
          _buildDateFilterCard(),
        
        // Lista de transacciones
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            color: primaryOrange,
            child: _transactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _transactions.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _transactions.length) {
                        return _buildLoadingIndicator();
                      }
                      
                      return _buildTransactionCard(_transactions[index]);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateFilterCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryOrange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryOrange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.date_range_rounded,
            color: primaryOrange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Filtro: ${_formatDate(_selectedFromDate!)} - ${_formatDate(_selectedToDate!)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: onSurfaceColor,
              ),
            ),
          ),
          TextButton(
            onPressed: _clearDateFilter,
            child: Text(
              'Limpiar',
              style: TextStyle(
                color: primaryOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(WalletTransaction transaction) {
    final isPositive = transaction.type.toLowerCase() == 'earning';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: outlineColor.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icono del tipo de transacción
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: transaction.typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  transaction.typeIcon,
                  size: 24,
                  color: transaction.typeColor,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Información de la transacción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: transaction.typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            transaction.typeDisplayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: transaction.typeColor,
                            ),
                          ),
                        ),
                        if (transaction.order != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: outlineColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Pedido #${transaction.order!.id}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: outlineColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTransactionDate(transaction.createdAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: outlineColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Monto
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isPositive ? '+' : '-'}\$${transaction.amount.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isPositive ? successColor : errorColor,
                    ),
                  ),
                  if (transaction.balanceAfter != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Saldo: \$${transaction.balanceAfter!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: outlineColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (transaction.order != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Pedido: \$${transaction.order!.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: outlineColor,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: primaryOrange,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Cargando transacciones...',
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

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
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
                size: 48,
                color: errorColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar transacciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Ocurrió un error inesperado',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: outlineColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
                Icons.receipt_long_outlined,
                size: 48,
                color: outlineColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin transacciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFromDate != null && _selectedToDate != null
                  ? 'No hay transacciones en el período seleccionado'
                  : 'Las transacciones aparecerán cuando tengas actividad en tu billetera',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: outlineColor,
                height: 1.5,
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
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: primaryOrange,
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
      
      // Recargar transacciones con el nuevo rango de fechas
      _refresh();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedFromDate = null;
      _selectedToDate = null;
    });
    
    // Recargar transacciones sin filtro de fechas
    _refresh();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays != 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours != 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes != 1 ? 's' : ''}';
    } else {
      return 'Hace un momento';
    }
  }
}