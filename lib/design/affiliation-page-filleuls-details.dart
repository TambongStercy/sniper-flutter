import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/filleulscard.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/components/textfield.dart';

class Filleuls extends StatefulWidget {
  static const id = 'filleuls';

  final String email;

  Filleuls({
    super.key,
    required this.email,
  });

  @override
  State<Filleuls> createState() => _FilleulsState();
}

class _FilleulsState extends State<Filleuls> {
  String email = '';
  String mainType = 'direct';
  bool isloading = false;
  bool hasMore = true;

  List directUsers = [];
  List indirectUsers = [];

  int totalPagesDirect = 1;
  int totalPagesIndirect = 1;

  final scrollController = ScrollController();
  int page = 1;

  // State for search
  final TextEditingController searchController = TextEditingController();
  String currentSearchTerm = '';

  late SharedPreferences prefs;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    getReferedUersFunc();

    scrollController.addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    if (currentScroll >= (maxScroll * 0.8) && hasMore) {
      getReferedUersFunc();
    }
  }

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
  }

  Future<void>? getReferedUersFunc() async {
    if (isloading || !hasMore) return;
    setState(() {
      isloading = true;
    });
    String msg = '';

    try {
      await initSharedPref();

      // Determine level based on mainType
      final String level =
          (mainType == 'direct') ? '1' : '2'; // Assuming indirect = level 2

      final filters = {
        'page': page.toString(),
        'level': level, // Use 'level' parameter
        'limit': '10',
        // Add name filter if search term exists
        if (currentSearchTerm.isNotEmpty) 'name': currentSearchTerm,
      };

      final response = await apiService.getReferredUsers(filters);

      msg = response['message'] ?? '';
      int? statusCode = response['statusCode'];

      if (statusCode != null && statusCode >= 200 && statusCode < 300) {
        // Extract data using new keys
        final responseData = response['data'] ?? {};
        final List<dynamic> fetchedUsers = responseData['referredUsers'] ?? [];
        final int totalPages = responseData['totalPages'] ?? page;

        setState(() {
          if (mainType == 'indirect') {
            totalPagesIndirect = totalPages;
            indirectUsers.addAll(fetchedUsers);
          } else {
            totalPagesDirect = totalPages;
            directUsers.addAll(fetchedUsers);
          }
          hasMore = page < totalPages; // Simplified hasMore logic
          if (hasMore) page++;
        });
      } else {
        String error = response['error'] ?? 'Failed to fetch referred users';
        if (error == 'Accès refusé') {
          showPopupMessage(context, "Erreur. Accès refusé.", msg);
          await logoutUser();
        } else {
          showPopupMessage(context, context.translate('error'),
              msg.isNotEmpty ? msg : error);
          setState(() {
            hasMore = false;
          });
        }
        print('API Error getReferedUersFunc: $statusCode - $error - $msg');
      }
    } catch (e) {
      print('Exception in getReferedUersFunc: $e');
      showPopupMessage(context, context.translate('error'),
          context.translate('error_occurred'));
      setState(() {
        hasMore = false;
      });
    } finally {
      if (mounted)
        setState(() {
          isloading = false;
        });
    }
  }

  Future<void> logoutUser() async {
    if (!kIsWeb) {
      final avatar = prefs.getString('avatar') ?? '';
      await deleteFile(avatar);
    }
    await prefs.clear();
    await deleteNotifications();
    await deleteAllKindTransactions();
    if (mounted) context.go('/');
  }

  Future<void> refresh() async {
    setState(() {
      directUsers.clear();
      indirectUsers.clear();
      page = 1;
      hasMore = true;
      // Keep currentSearchTerm, fetch will use it
    });

    await getReferedUersFunc(); // Fetch using current search term and type
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        backgroundColor: Colors.white,
        title: Text(
          context.translate('your_godchildren'),
          style: SafeGoogleFont(
            'Montserrat',
            fontSize: 16 * ffem,
            fontWeight: FontWeight.w500,
            height: 1.6666666667 * ffem / fem,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        color: Color(0xffffffff),
        child: Column(
          children: [
            Padding(
              padding:
                  EdgeInsets.fromLTRB(25 * fem, 15 * fem, 25 * fem, 10 * fem),
              child: CustomTextField(
                value: currentSearchTerm,
                hintText: context.translate('search_by_name'),
                searchMode: true,
                onChange: (val) {
                  searchController.text = val;
                },
                onSearch: () {
                  setState(() {
                    currentSearchTerm = searchController.text;
                  });
                  refresh();
                },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(25 * fem, 0 * fem, 25 * fem, 0 * fem),
              child: Row(
                children: [
                  _topButton(fem, context.translate('direct'), 'direct'),
                  _topButton(fem, context.translate('indirect'), 'indirect'),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: refresh,
                child: ListView.builder(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      EdgeInsets.fromLTRB(25 * fem, 8 * fem, 25 * fem, 8 * fem),
                  itemCount: (mainType == 'direct'
                          ? directUsers.length
                          : indirectUsers.length) +
                      (hasMore ? 1 : 0),
                  itemBuilder: ((context, index) {
                    final usersUsed =
                        mainType == 'direct' ? directUsers : indirectUsers;
                    final itemCount = usersUsed.length;

                    if (index < itemCount) {
                      final user = usersUsed[index]
                          as Map<String, dynamic>; // Ensure type safety
                      // Extract available data
                      final name = user['name'] as String? ?? 'N/A';
                      final email = user['email'] as String? ?? 'N/A';
                      final phone = user['phoneNumber'] as String? ?? 'N/A';
                      // Determine subscription TYPE from the list
                      final List<dynamic> subscriptions =
                          user['activeSubscriptions'] as List<dynamic>? ?? [];
                      String? subscriptionType = null;
                      if (subscriptions.isNotEmpty) {
                        // Prioritize 'cible' if present, otherwise take the first one (e.g., 'classique')
                        // Convert to lowercase for case-insensitive comparison
                        if (subscriptions.any(
                            (s) => s.toString().toLowerCase() == 'cible')) {
                          subscriptionType = 'cible';
                        } else if (subscriptions.any(
                            (s) => s.toString().toLowerCase() == 'classique')) {
                          subscriptionType = 'classique';
                        } // Add more checks for other types if needed
                      }
                      // url (avatar) is still not available from this endpoint

                      return FilleulsCard(
                        // Pass the determined type string (or null)
                        subscriptionType: subscriptionType,
                        // url: user['url'], // Still removed
                        name: name,
                        email: phone,
                      );
                    } else if (hasMore) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16 * fem),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded _topButton(double fem, String type, String val) {
    final capsType = type.length > 2
        ? type.substring(0, 1).toUpperCase() + type.substring(1)
        : type;

    return Expanded(
      child: InkWell(
        onTap: () async {
          setState(() {
            mainType = val;
            searchController.clear();
            currentSearchTerm = '';
          });
          await refresh();
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 10 * fem,
            horizontal: 30 * fem,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10 * fem)),
            color: mainType == val
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[200],
          ),
          child: Text(
            capsType,
            textAlign: TextAlign.center,
            style: SafeGoogleFont(
              'Mulish',
              height: 1.255,
              color: mainType == val ? Color(0xffffffff) : Color(0xff000000),
            ),
          ),
        ),
      ),
    );
  }
}
