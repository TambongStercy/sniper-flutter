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

    try {
      await initSharedPref();

      // Determine level based on mainType
      final String level = (mainType == 'direct') ? '1' : '2';

      final filters = {
        'page': page.toString(),
        'level': level,
        'limit': '10',
        if (currentSearchTerm.isNotEmpty) 'name': currentSearchTerm,
      };

      final response = await apiService.getReferredUsers(filters);

      String msg = response.message;
      int? statusCode = response.statusCode;

      if (statusCode != null &&
          statusCode >= 200 &&
          statusCode < 300 &&
          response.apiReportedSuccess) {
        // Extract data using new keys
        final responseData = response.body['data'] ?? {};
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
          hasMore = page < totalPages;
          if (hasMore) page++;
        });
      } else {
        String error = response.message;
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
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
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
    });

    await getReferedUersFunc();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.translate('your_godchildren'),
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
      body: Column(
        children: [
          // Search field
          Padding(
            padding: EdgeInsets.all(16 * fem),
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

          // Tab selector
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * fem),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8 * fem),
              ),
              child: Row(
                children: [
                  _buildTab(
                    text: context.translate('direct'),
                    isSelected: mainType == 'direct',
                    onTap: () async {
                      setState(() {
                        mainType = 'direct';
                        searchController.clear();
                        currentSearchTerm = '';
                      });
                      await refresh();
                    },
                    fem: fem,
                    ffem: ffem,
                  ),
                  _buildTab(
                    text: context.translate('indirect'),
                    isSelected: mainType == 'indirect',
                    onTap: () async {
                      setState(() {
                        mainType = 'indirect';
                        searchController.clear();
                        currentSearchTerm = '';
                      });
                      await refresh();
                    },
                    fem: fem,
                    ffem: ffem,
                  ),
                ],
              ),
            ),
          ),

          // List of users
          Expanded(
            child: RefreshIndicator(
              onRefresh: refresh,
              child: ListView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16 * fem),
                itemCount: (mainType == 'direct'
                        ? directUsers.length
                        : indirectUsers.length) +
                    (hasMore ? 1 : 0),
                itemBuilder: ((context, index) {
                  final usersUsed =
                      mainType == 'direct' ? directUsers : indirectUsers;
                  final itemCount = usersUsed.length;

                  if (index < itemCount) {
                    final user = usersUsed[index] as Map<String, dynamic>;

                    final name = user['name'] as String? ?? 'N/A';
                    final email = user['email'] as String? ?? 'N/A';
                    final phone = user['phoneNumber'] as String? ?? 'N/A';

                    final List<dynamic> subscriptions =
                        user['activeSubscriptions'] as List<dynamic>? ?? [];
                    String? subscriptionType = null;

                    if (subscriptions.isNotEmpty) {
                      if (subscriptions
                          .any((s) => s.toString().toLowerCase() == 'cible')) {
                        subscriptionType = 'cible';
                      } else if (subscriptions.any(
                          (s) => s.toString().toLowerCase() == 'classique')) {
                        subscriptionType = 'classique';
                      }
                    }

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12 * fem),
                      child: FilleulsCard(
                        subscriptionType: subscriptionType,
                        name: name,
                        email: phone,
                      ),
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
    );
  }

  Widget _buildTab({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    required double fem,
    required double ffem,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 12 * fem,
            horizontal: 16 * fem,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8 * fem),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14 * ffem,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
