import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/notificationbox.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Import for localization

class Notifications extends StatefulWidget {
  static const id = 'notifications';

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    () async {
      await initSharedPref();
      setState(() {
        // Update your UI with the desired changes.
      });
    }();
  }

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    final notifs = await getNotifications();
    list = notifs.map((e) => e['message'] ?? '').toList();
  }

  List<String> list = [];

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;

    return SimpleScaffold(
      title: context.translate('notifications'), // Localized title
      child: Container(
        padding: EdgeInsets.fromLTRB(15 * fem, 20 * fem, 15 * fem, 14 * fem),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xffffffff),
        ),
        child: list.length > 0
            ? Column(
                children: list
                    .map(
                      (item) => Column(
                        children: [
                          NotifBox(message: item),
                          SizedBox(
                            height: 15 * fem,
                          ),
                        ],
                      ),
                    )
                    .toList(),
              )
            : SizedBox(),
      ),
    );
  }
}
