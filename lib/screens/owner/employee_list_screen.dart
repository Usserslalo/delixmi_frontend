import 'package:flutter/material.dart';
import '../../models/owner/employee_models.dart';
import '../../services/employee_service.dart';
import '../../config/app_routes.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Employee> _employees = [];
  PaginationInfo? _pagination;
  
  // Filter state
  int _currentPage = 1;
  final int _pageSize = 15;
  int? _selectedRoleId;
  String? _selectedStatus;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter dropdowns
  final List<Map<String, dynamic>> _statusOptions = [
    {'value': null, 'label': 'Todos los estados'},
    {'value': 'active', 'label': 'Activo'},
    {'value': 'inactive', 'label': 'Inactivo'},
    {'value': 'suspended', 'label': 'Suspendido'},
  ];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Carga la lista de empleados
  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await EmployeeService.getEmployees(
        page: _currentPage,
        pageSize: _pageSize,
        roleId: _selectedRoleId,
        status: _selectedStatus,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      
      if (response.isSuccess && response.data != null) {
        final responseData = response.data!;
        final employeesData = responseData['employees'] as List<dynamic>;
        final paginationData = responseData['pagination'] as Map<String, dynamic>;
        
        setState(() {
          _employees = employeesData
              .map((employeeJson) => Employee.fromJson(employeeJson as Map<String, dynamic>))
              .toList();
          _pagination = PaginationInfo.fromJson(paginationData);
          _isLoading = false;
        });
      } else {
        // Handle specific error codes for GET employees
        String errorMessage = response.message;
        
        switch (response.code) {
          case 'VALIDATION_ERROR':
            errorMessage = 'Error en los parámetros de filtro.';
            break;
          case 'INSUFFICIENT_PERMISSIONS':
            errorMessage = 'No tienes permisos para consultar empleados.';
            break;
          case 'RESTAURANT_LOCATION_REQUIRED':
            errorMessage = 'Debes configurar la ubicación del restaurante primero.';
            break;
          case 'NOT_FOUND':
            errorMessage = 'Usuario no encontrado.';
            break;
          case 'INTERNAL_ERROR':
            errorMessage = 'Error interno del servidor.';
            break;
        }
        
        setState(() {
          _errorMessage = errorMessage;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar empleados: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Aplica filtros y recarga la lista
  void _applyFilters() {
    setState(() {
      _currentPage = 1;
      _searchQuery = _searchController.text.trim();
    });
    _loadEmployees();
  }

  /// Limpia todos los filtros
  void _clearFilters() {
    setState(() {
      _selectedRoleId = null;
      _selectedStatus = null;
      _searchQuery = '';
      _currentPage = 1;
    });
    _searchController.clear();
    _loadEmployees();
  }

  /// Cambia de página
  void _changePage(int page) {
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
      _loadEmployees();
    }
  }

  /// Confirma el cambio de estado de un empleado
  Future<void> _confirmStatusChange(Employee employee, String newStatus) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${newStatus == 'inactive' ? 'Desactivar' : 'Activar'} Empleado'),
        content: Text(
          '¿Estás seguro de que deseas ${newStatus == 'inactive' ? 'desactivar' : 'activar'} a ${employee.fullName}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(newStatus == 'inactive' ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (employee.assignmentId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error: No se puede actualizar el empleado. Falta información de asignación.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final response = await EmployeeService.updateEmployee(
          assignmentId: employee.assignmentId!,
          status: newStatus,
        );

        if (!mounted) return;
        
        Navigator.pop(context); // Close loading dialog
        
        if (response.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Empleado ${newStatus == 'inactive' ? 'desactivado' : 'activado'} exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          _loadEmployees(); // Refresh the list
        } else {
          // Handle specific error codes for better user experience
          String errorMessage = response.message;
          Color errorColor = Colors.red;
          
          switch (response.code) {
            case 'ASSIGNMENT_NOT_FOUND':
              errorMessage = 'Asignación de empleado no encontrada.';
              break;
            case 'FORBIDDEN_ACCESS':
              errorMessage = 'No tienes permisos para actualizar este empleado.';
              break;
            case 'INVALID_EMPLOYEE_ROLE':
              errorMessage = 'Rol no válido para empleados.';
              break;
            case 'VALIDATION_ERROR':
              errorColor = Colors.orange;
              break;
            case 'NO_RESTAURANT_ASSIGNED':
              errorMessage = 'No tienes un restaurante asignado para actualizar empleados.';
              break;
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: errorColor,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFE),
      appBar: AppBar(
        title: const Text('Gestionar Empleados'),
        backgroundColor: const Color(0xFFF2843A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFiltersSection(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            AppRoutes.ownerAddEditEmployee,
            arguments: {'mode': 'create'},
          );
          if (result == true && mounted) {
            _loadEmployees();
          }
        },
        backgroundColor: const Color(0xFFF2843A),
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar empleados...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                        _applyFilters();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF2843A)),
              ),
            ),
            onSubmitted: (_) => _applyFilters(),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 12),
          
          // Role and Status filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _selectedRoleId,
                  decoration: InputDecoration(
                    labelText: 'Rol',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFF2843A)),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Todos los roles'),
                    ),
                    ...ValidEmployeeRoles.roleList.map(
                      (role) => DropdownMenuItem<int?>(
                        value: role.id,
                        child: Text(
                          role.displayName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRoleId = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFF2843A)),
                    ),
                  ),
                  items: _statusOptions.map((option) {
                    return DropdownMenuItem<String?>(
                      value: option['value'] as String?,
                      child: Text(
                        option['label'] as String,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Filter actions
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _applyFilters,
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Filtrar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF2843A),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Limpiar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _employees.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null && _employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadEmployees,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No se encontraron empleados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedRoleId != null || _selectedStatus != null
                  ? 'Intenta ajustar los filtros de búsqueda'
                  : 'Agrega tu primer empleado al equipo',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isEmpty && _selectedRoleId == null && _selectedStatus == null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    AppRoutes.ownerAddEditEmployee,
                    arguments: {'mode': 'create'},
                  );
                  if (result == true && mounted) {
                    _loadEmployees();
                  }
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Agregar Empleado'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF2843A),
                  foregroundColor: Colors.white,
                ),
              ),
            ] else ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar Filtros'),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadEmployees(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _employees.length,
              itemBuilder: (context, index) {
                final employee = _employees[index];
                return _buildEmployeeCard(employee);
              },
            ),
          ),
        ),
        if (_pagination != null && (_pagination!.hasNextPage || _pagination!.hasPrevPage))
          _buildPaginationControls(),
      ],
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: employee.isActive 
              ? Colors.green.shade100
              : employee.isInactive 
                  ? Colors.orange.shade100
                  : Colors.red.shade100,
          child: Icon(
            Icons.person,
            color: employee.isActive 
                ? Colors.green.shade700
                : employee.isInactive 
                    ? Colors.orange.shade700
                    : Colors.red.shade700,
          ),
        ),
        title: Text(
          employee.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(employee.email),
            if (employee.role != null)
              Text(
                employee.role!.displayName,
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: employee.isActive 
                        ? Colors.green.shade100
                        : employee.isInactive 
                            ? Colors.orange.shade100
                            : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    employee.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: employee.isActive 
                          ? Colors.green.shade700
                          : employee.isInactive 
                              ? Colors.orange.shade700
                              : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                final result = await Navigator.pushNamed(
                  context,
                  AppRoutes.ownerAddEditEmployee,
                  arguments: {
                    'mode': 'edit',
                    'employee': employee,
                  },
                );
                if (result == true && mounted) {
                  _loadEmployees();
                }
                break;
              case 'deactivate':
                if (employee.isActive) {
                  await _confirmStatusChange(employee, 'inactive');
                }
                break;
              case 'activate':
                if (!employee.isActive) {
                  await _confirmStatusChange(employee, 'active');
                }
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            if (employee.isActive)
              const PopupMenuItem(
                value: 'deactivate',
                child: Row(
                  children: [
                    Icon(Icons.person_off, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Desactivar'),
                  ],
                ),
              ),
            if (!employee.isActive)
              const PopupMenuItem(
                value: 'activate',
                child: Row(
                  children: [
                    Icon(Icons.person_add, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Activar'),
                  ],
                ),
              ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildPaginationControls() {
    if (_pagination == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Página ${_pagination!.currentPage} de ${_pagination!.totalPages} (${_pagination!.totalItems} empleados)',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _pagination!.hasPrevPage 
                    ? () => _changePage(_pagination!.prevPage!)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                onPressed: _pagination!.hasNextPage 
                    ? () => _changePage(_pagination!.nextPage!)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
