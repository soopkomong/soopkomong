import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          _buildSettingsSection(
            title: '일반',
            children: [
              _buildSettingsTile(
                icon: Icons.language_outlined,
                title: '언어 설정',
                trailing: const Text(
                  '한국어',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.notifications_outlined,
                title: '알림 설정',
                trailing: Switch(value: true, onChanged: (value) {}),
              ),
            ],
          ),
          const Divider(),
          _buildSettingsSection(
            title: '게임 설정',
            children: [
              _buildSettingsTile(
                icon: Icons.music_note_outlined,
                title: '배경음',
                trailing: Switch(value: true, onChanged: (value) {}),
              ),
              _buildSettingsTile(
                icon: Icons.volume_up_outlined,
                title: '효과음',
                trailing: Switch(value: true, onChanged: (value) {}),
              ),
              _buildSettingsTile(
                icon: Icons.vibration_outlined,
                title: '진동',
                trailing: Switch(value: true, onChanged: (value) {}),
              ),
            ],
          ),
          const Divider(),
          _buildSettingsSection(
            title: '정보',
            children: [
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: '앱 정보',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.description_outlined,
                title: '서비스 이용약관',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: '개인정보 처리방침',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '버전 1.0.0',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
