import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_store/themes/theme_manager.dart';

class ThemeSettingsWidget extends StatelessWidget {
  const ThemeSettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theme Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Follow system theme option
            SwitchListTile(
              title: const Text('Use System Theme'),
              subtitle: const Text('Automatically adjust to device settings'),
              value: themeManager.followsSystem,
              onChanged: (value) {
                if (value) {
                  themeManager.useSystemTheme();
                }
              },
              secondary: Icon(
                Icons.settings_system_daydream,
                color: Theme.of(context).primaryColor,
              ),
            ),

            // Manual theme toggle (disabled when following system)
            if (!themeManager.followsSystem)
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle between light and dark theme'),
                value: themeManager.isDarkMode,
                onChanged: (_) => themeManager.toggleTheme(),
                secondary: Icon(
                  themeManager.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).primaryColor,
                ),
              ),

            // Show manual theme toggle even when system is enabled but make it not interactive
            if (themeManager.followsSystem)
              ListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Controlled by system settings'),
                leading: Icon(
                  themeManager.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).primaryColor,
                ),
                trailing: Switch(
                  value: themeManager.isDarkMode,
                  onChanged: null, // Disabled when following system
                ),
              ),
          ],
        ),
      ),
    );
  }
}
