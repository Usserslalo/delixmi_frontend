import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../models/branch_schedule.dart';
import '../../models/schedule_response.dart';
import '../../services/schedule_service.dart';
import '../../services/token_manager.dart';
import '../../config/app_routes.dart';

class WeeklyScheduleScreen extends StatefulWidget {
  const WeeklyScheduleScreen({super.key});

  @override
  State<WeeklyScheduleScreen> createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends State<WeeklyScheduleScreen> {
  bool _isLoading = true; // Comenzar con loading = true
  String? _errorMessage;
  ScheduleResponse? _scheduleData;
  int? _branchId;
  String? _branchName;

  // Colores Material 3
  static const Color primaryOrange = Color(0xFFF2843A);
  static const Color surfaceColor = Color(0xFFFFFBFE);
  static const Color onSurfaceColor = Color(0xFF1C1B1F);
  static const Color surfaceVariantColor = Color(0xFFE7E0EC);
  static const Color outlineColor = Color(0xFF79747E);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSchedule();
    });
  }

  void _initializeSchedule() async {
    // Intentar obtener branchId desde argumentos primero (compatibilidad)
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    if (args != null && args['branchId'] != null) {
      // Usar argumentos si están presentes (compatibilidad hacia atrás)
      setState(() {
        _branchId = args['branchId'] as int?;
        _branchName = args['branchName'] as String?;
      });
    } else {
      // Obtener branchId principal automáticamente
      final branchId = await TokenManager.getPrimaryBranchId();
      setState(() {
        _branchId = branchId;
        _branchName = 'Sucursal Principal';
      });
    }
    
    if (_branchId != null) {
      _loadBranchSchedule();
    } else {
      setState(() {
        _errorMessage = 'No se encontró información de la sucursal principal';
        _isLoading = false;
      });
    }
  }

  /// Carga el horario semanal de la sucursal principal
  Future<void> _loadBranchSchedule() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Usar el nuevo método que obtiene automáticamente el branchId principal
      final response = await ScheduleService.getPrimaryBranchSchedule();
      
      if (response.isSuccess && response.data != null) {
        debugPrint('📅 WeeklyScheduleScreen: Datos recibidos - ${response.data!.schedules.length} horarios');
        setState(() {
          _scheduleData = response.data!;
          _branchId = response.data!.branch.id; // Actualizar branchId desde la respuesta
          _branchName = response.data!.branch.name; // Obtener nombre desde la respuesta
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar horarios: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: primaryOrange,
      foregroundColor: Colors.white,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Volver',
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Horarios de Sucursal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            _branchName ?? 'Cargando...',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 24),
          onPressed: _loadBranchSchedule,
          tooltip: 'Actualizar',
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_scheduleData == null || _scheduleData!.schedules.isEmpty) {
      return _buildEmptyState();
    }

    return _buildScheduleList();
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar horarios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadBranchSchedule,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 64,
              color: outlineColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay horarios configurados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: onSurfaceColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Aún no has configurado los horarios de apertura y cierre para tu sucursal. Esto es importante para que los clientes sepan cuándo pueden hacer pedidos.',
              style: TextStyle(
                fontSize: 14,
                color: outlineColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 280),
              child: ElevatedButton.icon(
                onPressed: _navigateToEditWeeklySchedule,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Configurar Horarios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _loadBranchSchedule,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Actualizar'),
                  style: TextButton.styleFrom(
                    foregroundColor: outlineColor,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: _showSetupScheduleHelp,
                  icon: const Icon(Icons.help_outline_rounded, size: 18),
                  label: const Text('Ayuda'),
                  style: TextButton.styleFrom(
                    foregroundColor: outlineColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSetupScheduleHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: primaryOrange),
            const SizedBox(width: 12),
            const Text('Configurar Horarios'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para configurar los horarios de tu sucursal:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildHelpItem('1. Toca "Configurar Horarios" para crear horarios para toda la semana'),
            _buildHelpItem('2. Define horarios de apertura y cierre para cada día'),
            _buildHelpItem('3. Puedes marcar días específicos como cerrados'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToEditWeeklySchedule();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Configurar'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: primaryOrange,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    return RefreshIndicator(
      onRefresh: _loadBranchSchedule,
      color: primaryOrange,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _scheduleData!.schedules.length,
        itemBuilder: (context, index) {
          final schedule = _scheduleData!.schedules[index];
          return _buildDayScheduleCard(schedule);
        },
      ),
    );
  }

  Widget _buildDayScheduleCard(BranchSchedule schedule) {
    final isToday = _isToday(schedule.dayOfWeek);
    final cardColor = isToday ? primaryOrange.withValues(alpha: 0.1) : surfaceVariantColor;
    final borderColor = isToday ? primaryOrange.withValues(alpha: 0.3) : outlineColor.withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToEditDay(schedule),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: schedule.isClosed 
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    schedule.isClosed ? Icons.close_rounded : Icons.access_time_rounded,
                    size: 24,
                    color: schedule.isClosed ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            schedule.dayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isToday ? primaryOrange : onSurfaceColor,
                            ),
                          ),
                          if (isToday) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: primaryOrange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'HOY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (schedule.isClosed)
                        Text(
                          'Cerrado',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[600],
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        Text(
                          '${_formatTime(schedule.openingTime)} - ${_formatTime(schedule.closingTime)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: outlineColor,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.edit_rounded,
                  size: 20,
                  color: outlineColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isToday(int dayOfWeek) {
    final today = DateTime.now().weekday;
    // Convertir: Monday=1, Tuesday=2, ..., Sunday=7 a Sunday=0, Monday=1, ..., Saturday=6
    final todayAsBranchDay = today % 7;
    return todayAsBranchDay == dayOfWeek;
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      
      String period = hour >= 12 ? 'PM' : 'AM';
      int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      
      return '$displayHour:$minute $period';
    } catch (e) {
      return time;
    }
  }

  void _navigateToEditDay(BranchSchedule schedule) {
    Navigator.pushNamed(
      context,
      AppRoutes.ownerEditSingleDaySchedule,
      arguments: {
        'branchId': _branchId,
        'branchName': _branchName,
        'schedule': schedule,
      },
    ).then((_) {
      // Recargar horarios cuando vuelva de editar
      _loadBranchSchedule();
    });
  }

  void _navigateToEditWeeklySchedule() {
    Navigator.pushNamed(
      context,
      AppRoutes.ownerEditWeeklySchedule,
    ).then((savedSuccessfully) {
      // Recargar horarios cuando vuelva de configurar
      if (savedSuccessfully == true) {
        _loadBranchSchedule();
      }
    });
  }
}
