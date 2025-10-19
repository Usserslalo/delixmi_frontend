import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../models/schedule_response.dart';
import '../../services/schedule_service.dart';

class EditWeeklyScheduleScreen extends StatefulWidget {
  const EditWeeklyScheduleScreen({super.key});

  @override
  State<EditWeeklyScheduleScreen> createState() => _EditWeeklyScheduleScreenState();
}

class _EditWeeklyScheduleScreenState extends State<EditWeeklyScheduleScreen> {
  bool _isSaving = false;
  
  // Lista de 7 días de la semana (Domingo=0 a Sábado=6)
  late List<DayScheduleData> _weeklySchedule;

  // Colores Material 3
  static const Color primaryOrange = Color(0xFFF2843A);
  static const Color surfaceColor = Color(0xFFFFFBFE);
  static const Color onSurfaceColor = Color(0xFF1C1B1F);
  static const Color surfaceVariantColor = Color(0xFFE7E0EC);
  static const Color outlineColor = Color(0xFF79747E);

  @override
  void initState() {
    super.initState();
    _initializeSchedule();
  }

  void _initializeSchedule() async {
    try {
      // Inicializar horarios por defecto
      _weeklySchedule = _getDefaultSchedule();
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error inicializando horarios: $e');
    }
  }

  List<DayScheduleData> _getDefaultSchedule() {
    const dayNames = [
      'Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'
    ];
    
    return List.generate(7, (index) => DayScheduleData(
      dayOfWeek: index,
      dayName: dayNames[index],
      isClosed: index == 0, // Domingo cerrado por defecto
      openingTime: const TimeOfDay(hour: 9, minute: 0),
      closingTime: const TimeOfDay(hour: 22, minute: 0),
    ));
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
      title: const Text(
        'Configurar Horarios',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {},
            color: primaryOrange,
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _weeklySchedule.length,
              itemBuilder: (context, index) {
                final dayData = _weeklySchedule[index];
                return _buildDayScheduleCard(dayData, index);
              },
            ),
          ),
        ),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildDayScheduleCard(DayScheduleData dayData, int index) {
    final isToday = _isToday(dayData.dayOfWeek);
    final cardColor = isToday ? primaryOrange.withValues(alpha: 0.1) : surfaceVariantColor;
    final borderColor = isToday ? primaryOrange.withValues(alpha: 0.3) : outlineColor.withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: dayData.isClosed 
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    dayData.isClosed ? Icons.close_rounded : Icons.access_time_rounded,
                    size: 20,
                    color: dayData.isClosed ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        dayData.dayName,
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
                ),
                Switch(
                  value: !dayData.isClosed,
                  onChanged: (value) {
                    setState(() {
                      _weeklySchedule[index] = dayData.copyWith(isClosed: !value);
                    });
                  },
                  activeColor: primaryOrange,
                ),
              ],
            ),
            if (!dayData.isClosed) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker(
                      label: 'Apertura',
                      time: dayData.openingTime,
                      onTimeChanged: (newTime) {
                        setState(() {
                          _weeklySchedule[index] = dayData.copyWith(openingTime: newTime);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimePicker(
                      label: 'Cierre',
                      time: dayData.closingTime,
                      onTimeChanged: (newTime) {
                        setState(() {
                          _weeklySchedule[index] = dayData.copyWith(closingTime: newTime);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay time,
    required Function(TimeOfDay) onTimeChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: outlineColor,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: time,
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
            if (picked != null) {
              onTimeChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: outlineColor.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded, size: 18, color: outlineColor),
                const SizedBox(width: 8),
                Text(
                  _formatTimeOfDay(time),
                  style: TextStyle(
                    fontSize: 14,
                    color: onSurfaceColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveSchedule,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Guardar Horarios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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

  String _formatTimeOfDay(TimeOfDay time) {
    String period = time.hour >= 12 ? 'PM' : 'AM';
    int displayHour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    return '${displayHour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String _formatTimeOfDayForAPI(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _saveSchedule() async {
    if (_isSaving) return;

    // Validar horarios lógicos antes de enviar (según documentación backend)
    for (final day in _weeklySchedule) {
      if (!day.isClosed) {
        final openingMinutes = day.openingTime.hour * 60 + day.openingTime.minute;
        final closingMinutes = day.closingTime.hour * 60 + day.closingTime.minute;
        
        if (openingMinutes >= closingMinutes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Error en ${day.dayName}: La hora de apertura debe ser anterior a la hora de cierre'),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
          return;
        }
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Validar que tenemos exactamente 7 días únicos (0-6) según documentación backend
      final dayOfWeeks = _weeklySchedule.map((day) => day.dayOfWeek).toList();
      final expectedDays = [0, 1, 2, 3, 4, 5, 6];
      final uniqueDays = dayOfWeeks.toSet();
      
      if (uniqueDays.length != 7 || !expectedDays.every((day) => dayOfWeeks.contains(day))) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Debe configurar horarios para todos los 7 días de la semana (sin duplicados)'),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        setState(() {
          _isSaving = false;
        });
        return;
      }

      // Crear el request con todos los 7 días
      final schedules = _weeklySchedule.map((day) => ScheduleDayUpdate(
        dayOfWeek: day.dayOfWeek,
        openingTime: _formatTimeOfDayForAPI(day.openingTime),
        closingTime: _formatTimeOfDayForAPI(day.closingTime),
        isClosed: day.isClosed,
      )).toList();

      final request = WeeklyScheduleUpdateRequest(schedules: schedules);

      // Usar el método que obtiene automáticamente el branchId principal
      final response = await ScheduleService.updatePrimaryBranchWeeklySchedule(request);

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Horarios guardados exitosamente'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          
          // Volver a la pantalla anterior
          Navigator.pop(context, true); // true indica que se guardó exitosamente
        }
      } else {
        // Manejo específico de errores según códigos del backend (documentación horarios_Owner.md)
        String errorMessage = response.message;
        Color errorColor = Colors.red;
        IconData errorIcon = Icons.error;

        if (response.code != null) {
          switch (response.code) {
            case 'VALIDATION_ERROR':
              errorMessage = 'Datos de validación inválidos. Verifica los horarios.';
              errorColor = Colors.orange;
              errorIcon = Icons.warning;
              break;
            case 'INVALID_TIME_RANGE':
              errorMessage = 'Horarios inválidos: La hora de apertura debe ser anterior a la de cierre.';
              errorColor = Colors.orange;
              errorIcon = Icons.warning;
              break;
            case 'BRANCH_NOT_FOUND':
              errorMessage = 'Sucursal no encontrada. Verifica la configuración.';
              break;
            case 'BRANCH_UPDATE_DENIED':
              errorMessage = 'No tienes permisos para actualizar esta sucursal.';
              break;
            case 'INSUFFICIENT_PERMISSIONS':
              errorMessage = 'Permisos insuficientes. Contacta al administrador.';
              break;
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(errorIcon, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(errorMessage)),
                ],
              ),
              backgroundColor: errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error al guardar horarios: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error al guardar: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

/// Clase auxiliar para manejar los datos de cada día
class DayScheduleData {
  final int dayOfWeek;
  final String dayName;
  final bool isClosed;
  final TimeOfDay openingTime;
  final TimeOfDay closingTime;

  DayScheduleData({
    required this.dayOfWeek,
    required this.dayName,
    required this.isClosed,
    required this.openingTime,
    required this.closingTime,
  });

  DayScheduleData copyWith({
    int? dayOfWeek,
    String? dayName,
    bool? isClosed,
    TimeOfDay? openingTime,
    TimeOfDay? closingTime,
  }) {
    return DayScheduleData(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayName: dayName ?? this.dayName,
      isClosed: isClosed ?? this.isClosed,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
    );
  }
}
