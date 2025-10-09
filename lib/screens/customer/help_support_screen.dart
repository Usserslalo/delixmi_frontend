import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      // Si hay error, mantener la versión por defecto
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda y Soporte'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contacto Directo
            _buildSection(
              title: 'Contacto Directo',
              icon: Icons.phone,
              children: [
                _buildOptionTile(
                  icon: Icons.chat_bubble_outline,
                  title: 'Chat en Vivo',
                  subtitle: 'Habla con nuestro equipo de soporte',
                  onTap: _openLiveChat,
                  isComingSoon: true,
                ),
                _buildOptionTile(
                  icon: Icons.phone_outlined,
                  title: 'Llamar a Soporte',
                  subtitle: '+52 771 123 4567',
                  onTap: _callSupport,
                ),
                _buildOptionTile(
                  icon: Icons.email_outlined,
                  title: 'Enviar Email',
                  subtitle: 'soporte@delixmi.com',
                  onTap: _sendEmail,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Centro de Ayuda
            _buildSection(
              title: 'Centro de Ayuda',
              icon: Icons.help_outline,
              children: [
                _buildOptionTile(
                  icon: Icons.quiz_outlined,
                  title: 'Preguntas Frecuentes',
                  subtitle: 'Encuentra respuestas rápidas',
                  onTap: _openFAQs,
                ),
                _buildOptionTile(
                  icon: Icons.play_circle_outline,
                  title: 'Tutoriales en Video',
                  subtitle: 'Aprende a usar la app paso a paso',
                  onTap: _openTutorials,
                ),
                _buildOptionTile(
                  icon: Icons.book_outlined,
                  title: 'Guía de Usuario',
                  subtitle: 'Documentación completa',
                  onTap: _openUserGuide,
                ),
                _buildOptionTile(
                  icon: Icons.build_outlined,
                  title: 'Solución de Problemas',
                  subtitle: 'Guías para problemas comunes',
                  onTap: _openTroubleshooting,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Información Legal
            _buildSection(
              title: 'Información Legal',
              icon: Icons.gavel_outlined,
              children: [
                _buildOptionTile(
                  icon: Icons.description_outlined,
                  title: 'Términos y Condiciones',
                  subtitle: 'Condiciones de uso del servicio',
                  onTap: _openTermsAndConditions,
                ),
                _buildOptionTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Política de Privacidad',
                  subtitle: 'Cómo protegemos tus datos',
                  onTap: _openPrivacyPolicy,
                ),
                _buildOptionTile(
                  icon: Icons.cookie_outlined,
                  title: 'Política de Cookies',
                  subtitle: 'Uso de cookies y tecnologías',
                  onTap: _openCookiePolicy,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Acerca de la App
            _buildSection(
              title: 'Acerca de la App',
              icon: Icons.info_outline,
              children: [
                _buildInfoTile(
                  icon: Icons.info_outline,
                  title: 'Información de la App',
                  subtitle: 'Versión $_appVersion',
                  onTap: _showAppInfo,
                ),
                _buildOptionTile(
                  icon: Icons.star_outline,
                  title: 'Calificar en App Store',
                  subtitle: 'Ayúdanos con tu opinión',
                  onTap: _rateApp,
                ),
                _buildOptionTile(
                  icon: Icons.share_outlined,
                  title: 'Compartir con Amigos',
                  subtitle: 'Invita a tus amigos a usar Delixmi',
                  onTap: _shareApp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isComingSoon = false,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: isComingSoon
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Próximamente',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
        onTap: isComingSoon ? null : onTap,
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.grey[600],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  // Métodos de acción
  void _openLiveChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chat en vivo estará disponible próximamente'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _callSupport() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+527711234567');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showErrorSnackBar('No se pudo abrir la aplicación de teléfono');
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'soporte@delixmi.com',
      query: 'subject=Soporte Delixmi&body=Hola, necesito ayuda con...',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showErrorSnackBar('No se pudo abrir la aplicación de email');
    }
  }

  void _openFAQs() {
    _showComingSoonDialog('Preguntas Frecuentes');
  }

  void _openTutorials() {
    _showComingSoonDialog('Tutoriales en Video');
  }

  void _openUserGuide() {
    _showComingSoonDialog('Guía de Usuario');
  }

  void _openTroubleshooting() {
    _showComingSoonDialog('Solución de Problemas');
  }

  void _openTermsAndConditions() {
    _showComingSoonDialog('Términos y Condiciones');
  }

  void _openPrivacyPolicy() {
    _showComingSoonDialog('Política de Privacidad');
  }

  void _openCookiePolicy() {
    _showComingSoonDialog('Política de Cookies');
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de la App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Versión', _appVersion),
            _buildInfoRow('Desarrollador', 'Delixmi Team'),
            _buildInfoRow('Plataforma', 'Flutter'),
            _buildInfoRow('Año', '2025'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _rateApp() async {
    // En una implementación real, esto abriría la App Store
    _showComingSoonDialog('Calificar en App Store');
  }

  Future<void> _shareApp() async {
    try {
      // En una implementación real, usarías share_plus
      // Por ahora, mostraremos un mensaje informativo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Función de compartir estará disponible próximamente'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Error al compartir la aplicación');
    }
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text(
          'Esta funcionalidad estará disponible próximamente. '
          '¡Mantente atento a las actualizaciones!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
