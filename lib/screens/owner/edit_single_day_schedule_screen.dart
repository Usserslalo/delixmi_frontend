import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/branch_schedule.dart';
import '../../services/schedule_service.dart';

class EditSingleDayScheduleScreen extends StatefulWidget {
  const EditSingleDayScheduleScreen({super.key});

  @override
  State<EditSingleDayScheduleScreen> createState() => _EditSingleDayScheduleScreenState();
}

class _EditSingleDayScheduleScreenState extends State<EditSingleDayScheduleScreen> {
  bool _isSaving = false;
  
  String? _branchName;
  BranchSchedule? _originalSchedule;
  
  late bool _isClosed;
  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;

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
      _initializeEditScreen();
    });
  }

  void _initializeEditScreen() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    // Obtener branchName desde argumentos o usar por defecto
    String? branchName;
    
    if (args != null && args['branchName'] != null) {
      // Usar argumentos si están presentes (compatibilidad hacia atrás)
      branchName = args['branchName'] as String?;
    } else {
      // Usar nombre por defecto
      branchName = 'Sucursal Principal';
    }
    
    setState(() {
      _branchName = branchName;
      _originalSchedule = args?['schedule'] as BranchSchedule?;
      
      if (_originalSchedule != null) {
        _isClosed = _originalSchedule!.isClosed;
        _openingTime = _parseTimeOfDay(_originalSchedule!.openingTime);
        _closingTime = _parseTimeOfDay(_originalSchedule!.closingTime);
      } else {
        _isClosed = false;
        _openingTime = const TimeOfDay(hour: 9, minute: 0);
        _closingTime = const TimeOfDay(hour: 22, minute: 0);
      }
    });
  }

  TimeOfDay _parseTimeOfDay(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
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
          Text(
            _originalSchedule?.dayName ?? 'Editar Horario',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            _branchName ?? '',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_originalSchedule == null) {
      return const Center(
        child: Text('Error: No se proporcionó información del horario'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDayInfoCard(),
          const SizedBox(height: 24),
          _buildScheduleCard(),
          const SizedBox(height: 24),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildDayInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryOrange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              size: 24,
              color: primaryOrange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _originalSchedule!.dayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryOrange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Horario de operación',
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryOrange.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceVariantColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: outlineColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Configuración',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Toggle para abierto/cerrado
          Row(
            children: [
              Expanded(
                child: Text(
                  'Día cerrado',
                  style: TextStyle(
                    fontSize: 16,
                    color: onSurfaceColor,
                  ),
                ),
              ),
              Switch(
                value: _isClosed,
                onChanged: (value) {
                  setState(() {
                    _isClosed = value;
                  });
                },
                activeColor: Colors.red,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          if (!_isClosed) ...[
            _buildTimePicker(
              label: 'Hora de apertura',
              time: _openingTime!,
              onTap: () => _selectOpeningTime(),
            ),
            const SizedBox(height: 16),
            _buildTimePicker(
              label: 'Hora de cierre',
              time: _closingTime!,
              onTap: () => _selectClosingTime(),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.red[600],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Este día permanecerá cerrado',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: onSurfaceColor,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: outlineColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: outlineColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  time.format(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: onSurfaceColor,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: outlineColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
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
                'Guardar Cambios',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _selectOpeningTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _openingTime!,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryOrange,
              onPrimary: Colors.white,
              onSurface: onSurfaceColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _openingTime) {
      setState(() {
        _openingTime = picked;
        // Validar que la hora de apertura sea anterior a la de cierre
        if (_closingTime != null && picked.hour >= _closingTime!.hour) {
          if (picked.hour > _closingTime!.hour || 
              (picked.hour == _closingTime!.hour && picked.minute >= _closingTime!.minute)) {
            _closingTime = TimeOfDay(
              hour: (picked.hour + 1) % 24,
              minute: picked.minute,
            );
          }
        }
      });
    }
  }

  Future<void> _selectClosingTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _closingTime!,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryOrange,
              onPrimary: Colors.white,
              onSurface: onSurfaceColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _closingTime) {
      setState(() {
        _closingTime = picked;
        // Validar que la hora de cierre sea posterior a la de apertura
        if (_openingTime != null && picked.hour <= _openingTime!.hour) {
          if (picked.hour < _openingTime!.hour || 
              (picked.hour == _openingTime!.hour && picked.minute <= _openingTime!.minute)) {
            _openingTime = TimeOfDay(
              hour: (picked.hour - 1 + 24) % 24,
              minute: picked.minute,
            );
          }
        }
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (_originalSchedule == null) return;

    // Validar horarios lógicos según documentación backend
    if (!_isClosed) {
      final openingMinutes = _openingTime!.hour * 60 + _openingTime!.minute;
      final closingMinutes = _closingTime!.hour * 60 + _closingTime!.minute;
      
      if (openingMinutes >= closingMinutes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('La hora de apertura debe ser anterior a la hora de cierre'),
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

    setState(() {
      _isSaving = true;
    });

    try {
      // Usar el nuevo método que obtiene automáticamente el branchId principal
      final response = await ScheduleService.updatePrimaryBranchSingleDaySchedule(
        _originalSchedule!.dayOfWeek,
        openingTime: _formatTimeOfDay(_openingTime!),
        closingTime: _formatTimeOfDay(_closingTime!),
        isClosed: _isClosed,
      );

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Horario de ${_originalSchedule!.dayName} actualizado exitosamente',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _isSaving = false;
        });
        
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
            case 'INVALID_DAY_OF_WEEK':
              errorMessage = 'Día de la semana inválido.';
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
      setState(() {
        _isSaving = false;
      });
      
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
    }
  }
}
