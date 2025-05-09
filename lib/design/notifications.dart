import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/notificationbox.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart';

class Notifications extends StatefulWidget {
  static const id = 'notifications';

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late SharedPreferences prefs;
  List<String> list = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => isLoading = true);
    try {
      prefs = await SharedPreferences.getInstance();
      final notifs = await getNotifications();
      list = notifs.map((e) => e['message'] ?? '').toList();
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.translate('notifications'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: list.isEmpty
                  ? _buildEmptyState(fem, ffem)
                  : ListView.separated(
                      padding: EdgeInsets.all(16 * fem),
                      itemCount: list.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12 * fem),
                      itemBuilder: (context, index) =>
                          NotifBox(message: list[index]),
                    ),
            ),
    );
  }

  Widget _buildEmptyState(double fem, double ffem) {
    return ListView(
      children: [
        SizedBox(height: 100 * fem),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: 80 * fem,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16 * fem),
              Text(
                context.translate('no_notifications'),
                style: TextStyle(
                  fontSize: 18 * ffem,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
