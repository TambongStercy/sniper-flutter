import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/components/prodtpost.dart';
import 'package:snipper_frontend/components/rating_tag.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/design/produit-page.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class Market extends StatefulWidget {
  Market({super.key, this.page});

  static const id = 'market';

  int? page;

  @override
  State<Market> createState() => _MarketState();
}

class _MarketState extends State<Market> {
  final List prdtList = [];
  String email = '';
  int itemCount = 0;
  int page = 1;
  bool hasMore = true;
  bool isLoading = false;
  bool _isInitialLoading = true;
  bool showSpinner = false;

  late SharedPreferences prefs;
  final ApiService _apiService = ApiService();

  final scrollController = ScrollController();
  String search = '';
  String currentSearchTerm = '';
  String category = '';
  String subcategory = '';

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
  }

  @override
  void initState() {
    super.initState();

    page = widget.page ?? page;

    () async {
      await initSharedPref();
      await getProductsOnline();
      scrollController.addListener(_onScroll);
    }();
  }

  void _onScroll() {
    if (!scrollController.hasClients || isLoading) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    if (currentScroll >= (maxScroll * 0.8) && hasMore) {
      getProductsOnline(loadMore: true);
    }
  }

  Future<void> getProductsOnline({bool loadMore = false}) async {
    if (isLoading) return;
    isLoading = true;
    String msg = '';
    String error = '';
    try {
      await initSharedPref();

      if (!loadMore) {
        page = 1;
        prdtList.clear();
        hasMore = true;
        currentSearchTerm = search;
      }

      Map<String, dynamic> filters = {
        'page': page.toString(),
        'limit': '10',
        if (currentSearchTerm.isNotEmpty) 'search': currentSearchTerm,
        if (category.isNotEmpty) 'category': category,
        if (subcategory.isNotEmpty) 'subcategory': subcategory,
      };
      filters.removeWhere((key, value) => value == null || value.isEmpty);

      print("Fetching products with filters: $filters");

      final response = await _apiService.getProducts(filters);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final List<dynamic> newItems = data['products'] as List<dynamic>? ?? [];
        final pagination = data['paginationInfo'] as Map<String, dynamic>?;

        print('data : ${data['products'].first}');
        if (mounted) {
          setState(() {
            print('Mounted and running setstate');
            prdtList.addAll(newItems);
            itemCount = prdtList.length;

            if (pagination != null) {
              final int currentPageFromApi = pagination['currentPage'] ?? page;
              final int totalPages = pagination['totalPages'] ?? 1;
              hasMore = currentPageFromApi < totalPages;
              page = currentPageFromApi + 1;
            } else {
              hasMore = newItems.length == 10;
              if (hasMore) page++;
            }
          });
        }
      } else {
        msg = response['message'] ??
            response['error'] ??
            'Failed to load products or no products found';
        if (mounted) {
          if (response['success'] != true) {
            showPopupMessage(context, context.translate('error'), msg);
          }
          setState(() {
            hasMore = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching products: $e");
      if (mounted) {
        showPopupMessage(context, context.translate('error'),
            context.translate('error_occurred'));
        setState(() {
          hasMore = false;
        });
      }
    } finally {
      isLoading = false;
      // Set initial loading to false only after the first fetch attempt
      if (_isInitialLoading) {
        _isInitialLoading = false;
      }
      if (mounted) setState(() {});
    }
  }

  Future<void> _rateProductApiCall(String prdtId, double rating) async {
    setState(() {
      showSpinner = true;
    });
    String msg = '';
    try {
      final response = await _apiService.rateProduct(prdtId, rating);

      msg = response['message'] ?? response['error'] ?? 'Rating failed';
      final title =
          (response['statusCode'] == 200 && response['success'] == true)
              ? context.translate('success')
              : context.translate('error');

      if (mounted) {
        showPopupMessage(context, title, msg);
      }
      print(msg);

      if (response['statusCode'] == 200 && response['success'] == true) {
        await refresh();
      }
    } catch (e) {
      print("Error rating product: $e");
      if (mounted) {
        String title = context.translate('error');
        showPopupMessage(context, title, context.translate('error_occurred'));
      }
    } finally {
      if (mounted) {
        setState(() {
          showSpinner = false;
        });
      }
    }
  }

  Future<void> refresh() async {
    await getProductsOnline(loadMore: false);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void showRatingBar(BuildContext context, prdtAndUser) {
    final prdt = prdtAndUser['product'];
    final prdtId = prdt['_id'] as String?;

    if (prdtId == null) {
      print("Error: Product ID is null in showRatingBar");
      showPopupMessage(context, context.translate('error'),
          "Cannot rate product: Missing ID.");
      return;
    }

    double userRating = 3;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              context.translate('product_rating_prompt'),
              textAlign: TextAlign.center,
              style: SafeGoogleFont(
                'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: Color(0xff25313c),
              ),
            ),
            content: RatingBar.builder(
              initialRating: userRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setDialogState(() {
                  userRating = rating;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _rateProductApiCall(prdtId, userRating);
                },
                child: Text(context.translate('ok')),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(context.translate('cancel')),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;

    // Show initial loading indicator
    if (_isInitialLoading) {
      return Center(child: CircularProgressIndicator());
    }

    List<String> subCategories = [];

    if (category == 'services') {
      subCategories.addAll(subServices);
    } else if (category == 'produits') {
      subCategories.addAll(subProducts);
    } else {
      // If category is empty ('all'), include both product and service subcategories
    }

    return Column(
      children: [
        // Search and filter section
        Container(
          padding: EdgeInsets.fromLTRB(16 * fem, 16 * fem, 16 * fem, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search field with modern styling
              CustomTextField(
                hintText: context.translate('search_product_or_service'),
                onChange: (val) {
                  search = val;
                },
                onSearch: () async {
                  currentSearchTerm = search;
                  await refresh();
                },
                searchMode: true,
                margin: 0,
              ),
              SizedBox(height: 16 * fem),

              // Main category tabs
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildMainCategoryTab(fem, ''),
                    _buildMainCategoryTab(fem, 'services'),
                    _buildMainCategoryTab(fem, 'produits'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Subcategories horizontal list
        if (category == 'produits' || category == 'services')
          Container(
            height: 48 * fem,
            padding:
                EdgeInsets.symmetric(vertical: 8 * fem, horizontal: 8 * fem),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: ListView(scrollDirection: Axis.horizontal, children: [
              _buildSubcategoryChip(fem, ''), // Add "All" for subcategories
              ...subCategories
                  .map((val) => _buildSubcategoryChip(fem, val))
                  .toList(),
            ]),
          ),

        // Product grid
        Expanded(
          child: RefreshIndicator(
            onRefresh: refresh,
            child: Container(
              color: Colors.white,
              child: _buildProductList(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainCategoryTab(double fem, String catg) {
    final value =
        catg == '' ? context.translate('all') : context.translate(catg);

    return Expanded(
      child: InkWell(
        onTap: () async {
          setState(() {
            category = catg;
            subcategory = '';
          });
          await refresh();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12 * fem),
          decoration: BoxDecoration(
            color: category == catg ? AppTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(8 * fem),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: category == catg ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubcategoryChip(double fem, String subCateg) {
    subCateg = subCateg.toLowerCase();

    final value = subCateg.isEmpty
        ? context.translate('all')
        : context.translate(subCateg);

    return Container(
      margin: EdgeInsets.only(right: 8 * fem),
      child: InkWell(
        onTap: () async {
          setState(() {
            subcategory = subCateg;
          });
          await refresh();
        },
        child: Chip(
          label: Text(value),
          backgroundColor: subcategory == subCateg
              ? AppTheme.primaryBlue.withOpacity(0.1)
              : Colors.grey.shade100,
          labelStyle: TextStyle(
            color:
                subcategory == subCateg ? AppTheme.primaryBlue : Colors.black87,
            fontWeight:
                subcategory == subCateg ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
          padding: EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: subcategory == subCateg
                  ? AppTheme.primaryBlue.withOpacity(0.3)
                  : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build the product list or show appropriate messages
  Widget _buildProductList(BuildContext context) {
    // Case: Initial load finished, list is empty, and API confirms no more items.
    if (prdtList.isEmpty && !hasMore && !isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            context.translate(
                'no_products_services'), // Or a more specific "No results found" message
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    // Case: Still loading initially (after _isInitialLoading is false but before first items arrive)
    // or during refresh when list is cleared, or when loading more items.
    // Show centered indicator only if list is currently empty.
    // If list has items, the indicator will be at the bottom.
    else if (prdtList.isEmpty && isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Build the list using ListView.builder
    return ListView.builder(
      controller: scrollController,
      itemCount: prdtList.length + (hasMore ? 1 : 0),
      itemBuilder: ((context, index) {
        // Logic for the "load more" indicator or "no more items" text
        if (index == prdtList.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: hasMore
                  // Only show indicator if actively loading more
                  ? (isLoading
                      ? CircularProgressIndicator()
                      : SizedBox.shrink())
                  // Show "No more products" only if hasMore is false and list isn't empty
                  : (prdtList.isNotEmpty
                      ? Text(context.translate('no_more_products'))
                      : SizedBox.shrink()),
            ),
          );
        }

        // --- Render Product Item ---
        final prdt = prdtList[index] as Map<String, dynamic>? ?? {};

        final prdtName = prdt['name'] as String? ?? 'N/A';
        final price = (prdt['price'] as num?)?.toDouble() ?? 0.0;
        // final imagesUrlList = prdt['imagesUrl'] as List<dynamic>? ?? [];
        // final imageUrl =
        // imagesUrlList.isNotEmpty ? imagesUrlList[0]?.toString() ?? '' : '';
        final link = prdt['whatsappLink'] as String? ?? '';

        // --- New image handling ---
        final imagesList = prdt['images'] as List<dynamic>? ?? [];
        String imageUrl = '';
        if (imagesList.isNotEmpty) {
          final firstImageMap = imagesList[0] as Map<String, dynamic>?;
          final imageId = firstImageMap?['fileId'] as String?;
          if (imageId != null && imageId.isNotEmpty) {
            imageUrl = '$settingsFileBaseUrl$imageId';
          }
        }
        // --- End new image handling ---

        final rating = (prdt['overallRating'] as num?)?.toDouble() ?? 0.0;
        final ratingLength = (prdt['ratings'] as List<dynamic>? ?? []).length;
        final prdtId = prdt['_id'] as String?;
        // Correctly access userId instead of sellerId
        final sellerId = prdt['userId'] as String?;

        // Basic validation: Skip rendering if essential data is missing
        if (prdtId == null || sellerId == null) {
          print(
              "Skipping item at index $index due to missing prdtId or sellerId");
          return SizedBox.shrink();
        }

        return InkWell(
          onTap: () {
            print("Tapping product: $prdtId by seller: $sellerId");
            // Pass the whole product map as extra
            context.pushNamed(
              ProduitPage.id,
              extra: {'productId': prdtId, 'sellerId': sellerId}, // Pass IDs
            );
          },
          child: PrdtPost(
            image: imageUrl,
            onContact: () {
              launchUrl(Uri.parse(link));
            },
            prdtId: prdtId,
            sellerId: sellerId, // Pass the correct sellerId
            price: price.toInt(),
            title: prdtName,
            rating: InkWell(
              onTap: () {
                // Pass the specific product data to the rating bar
                showRatingBar(context, {'product': prdt});
              },
              child: RatingTag(
                value: rating,
                margin: EdgeInsets.all(3.0),
                length: ratingLength,
              ),
            ),
          ),
        );
        // --- End Render Product Item ---
      }),
      padding: EdgeInsets.all(8.0),
    );
  }
}
