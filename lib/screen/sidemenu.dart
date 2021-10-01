import 'package:flutter/material.dart';
import 'package:quicknote/screen/password.dart';
import 'package:quicknote/theme/components/z_animated_toggle.dart';
import 'package:quicknote/theme/models_providers/theme_provider.dart';
import 'about.dart';
import 'package:provider/provider.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Quick Note',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(
                    fit: BoxFit.fill, image: AssetImage('assets/cover.jpg'))),
          ),
          ListTile(
            leading: Icon(Icons.wb_sunny_outlined),
            trailing: ZAnimatedToggle(
              values: ['Light', 'Dark'],
              onToggleCallback: (v) async {
                await themeProvider.toggleThemeData();
              },
            ),
            title: Text('Theme'),
          ),
          ListTile(
            leading: Icon(Icons.lock_outline_rounded),
            title: Text('Lock app'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => passwords()));
            },
          ),
          ListTile(
            leading: Icon(Icons.announcement_outlined),
            title: Text('About'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => aboutPage()));
            },
          ),
        ],
      ),
    );
  }
}
