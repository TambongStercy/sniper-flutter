import 'dart:convert';

import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/filleulscard.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/localization_extension.dart'; // Import for localization
import 'package:share_plus/share_plus.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart'; // Import loading HUD
import 'package:intl/intl.dart';

class ProduitPage extends StatefulWidget {
  static const id = 'productpage';

  const ProduitPage(
      {super.key, required this.productId, required this.sellerId});

  final String productId;
  final String sellerId;

  @override
  State<ProduitPage> createState() => _ProduitPageState();
}

class _ProduitPageState extends State<ProduitPage> {
  String email = '';
  bool isSubscribed = false;
  String shareLink = '';
  bool _isRating = false;
  bool _isLoading = true; // Loading state for initial fetch
  bool _showSpinner = false; // Spinner for actions like rating
  Map<String, dynamic>? _productData; // Store fetched product data
  Map<String, dynamic>? _sellerData; // Store fetched seller data
  String? _errorMessage;

  // State for ratings section
  List<Map<String, dynamic>> _ratingsList = [];
  int _ratingsPage = 1;
  bool _isRatingsLoading = false;
  bool _hasMoreRatings = true;
  final ScrollController _ratingsScrollController = ScrollController();

  late SharedPreferences prefs;
  final ApiService _apiService = ApiService();

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;
    shareLink =
        '${frontEnd}?sellerId=${widget.sellerId}&prdtId=${widget.productId}';
  }

  @override
  void initState() {
    super.initState();
    () async {
      await initSharedPref();
      await _fetchProductAndSellerDetails(); // Fetch data on init
      // Fetch initial ratings only if product details were fetched successfully
      if (_productData != null) {
        await _fetchProductRatings();
      }
      // Add listener for ratings scroll controller
      _ratingsScrollController.addListener(_onRatingsScroll);
      if (mounted) {
        setState(() {
          // Update your UI with the desired changes.
        });
      }
    }();
  }

  @override
  void dispose() {
    _ratingsScrollController.removeListener(_onRatingsScroll);
    _ratingsScrollController.dispose();
    super.dispose();
  }

  // Listener for ratings pagination
  void _onRatingsScroll() {
    if (!_ratingsScrollController.hasClients ||
        _isRatingsLoading ||
        !_hasMoreRatings) return;

    final maxScroll = _ratingsScrollController.position.maxScrollExtent;
    final currentScroll = _ratingsScrollController.offset;
    // Load more when reaching 80% of the scroll extent
    if (currentScroll >= (maxScroll * 0.8)) {
      _fetchProductRatings(loadMore: true);
    }
  }

  Future<void> _fetchProductRatings({bool loadMore = false}) async {
    if (_isRatingsLoading || (!loadMore && !_hasMoreRatings)) return;

    setState(() {
      _isRatingsLoading = true;
      if (!loadMore) {
        // Reset list only when refreshing (not loading more)
        _ratingsList.clear();
        _ratingsPage = 1;
        _hasMoreRatings = true;
      }
    });

    try {
      final response = await _apiService.getProductRatings(
        widget.productId,
        page: _ratingsPage,
        limit: 10, // Or your desired page size
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final List<dynamic> newRatings =
            data['ratings'] as List<dynamic>? ?? [];
        final int totalPages = data['totalPages'] as int? ?? 1;

        if (mounted) {
          setState(() {
            _ratingsList.addAll(newRatings.cast<Map<String, dynamic>>());
            _hasMoreRatings = _ratingsPage < totalPages;
            if (_hasMoreRatings) {
              _ratingsPage++;
            }
          });
        }
      } else {
        // Handle API error, maybe show a message specific to ratings
        print(
            "API Error fetching ratings: ${response['message'] ?? response['error']}");
        if (mounted) {
          setState(() {
            _hasMoreRatings = false;
          });
        }
      }
    } catch (e) {
      print("Exception fetching ratings: $e");
      if (mounted) {
        setState(() {
          _hasMoreRatings = false;
        });
        // Optionally show a snackbar or message for the error
        // showSnackbar(context, context.translate('error_fetching_ratings'));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRatingsLoading = false;
        });
      }
    }
  }

  Future<void> _fetchProductAndSellerDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _productData = null; // Reset data
      _sellerData = null; // Reset data
    });

    try {
      // Fetch product and seller details concurrently
      final results = await Future.wait([
        _apiService.getProductById(widget.productId),
        _apiService.getUserProfileById(widget.sellerId),
      ]);

      final productResponse = results[0];
      final sellerResponse = results[1];

      // Process Product Response
      if (productResponse['success'] == true &&
          productResponse['data'] != null) {
        _productData = productResponse['data'] as Map<String, dynamic>;
      } else {
        _errorMessage = productResponse['message'] ??
            productResponse['error'] ??
            context.translate('error_fetching_product');
        print("API Error fetching product: $_errorMessage");
        // Potentially stop here if product is essential
      }

      // Process Seller Response (only if product fetch was okay or if seller info is optional)
      if (sellerResponse['success'] == true && sellerResponse['data'] != null) {
        _sellerData = sellerResponse['data'] as Map<String, dynamic>;
      } else {
        // Append seller error message if product error didn't already exist
        final sellerError = sellerResponse['message'] ??
            sellerResponse['error'] ??
            context.translate('error_fetching_seller');
        print("API Error fetching seller: $sellerError");
        _errorMessage = (_errorMessage == null)
            ? sellerError
            : "$_errorMessage; $sellerError";
      }

      // Check if essential data is missing after attempts
      if (_productData == null) {
        // If product data is null ensure error message reflects it.
        if (_errorMessage == null) {
          _errorMessage = context.translate('error_fetching_product');
        }
        print("Error: Product data is null after API call.");
      }
      if (_sellerData == null) {
        // If seller data is null ensure error message reflects it.
        if (_errorMessage == null) {
          _errorMessage = context.translate('error_fetching_seller');
        }
        print("Error: Seller data is null after API call.");
      }
    } catch (e) {
      _errorMessage = context.translate('error_occurred');
      print("Exception fetching product/seller details: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> rateProduct(String prdtId, double rating,
      {String? review}) async {
    if (_isRating) return;

    setState(() {
      _isRating = true;
      _showSpinner = true; // Show spinner for rating action
    });

    String msg = '';
    try {
      final response =
          await _apiService.rateProduct(prdtId, rating, review: review);

      msg = response['message'] ?? response['error'] ?? 'Rating failed';
      final title =
          (response['statusCode'] == 200 && response['success'] == true)
              ? context.translate('success')
              : context.translate('error');

      if (mounted) {
        showPopupMessage(context, title, msg, callback: () {
          // Refetch details after successful rating to update UI
          if (response['statusCode'] == 200 && response['success'] == true) {
            _fetchProductAndSellerDetails();
          }
        });
      }
      print(msg);
    } catch (e) {
      print("Error rating product: $e");
      if (mounted) {
        String title = context.translate('error');
        showPopupMessage(context, title, context.translate('error_occurred'));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRating = false;
          _showSpinner = false; // Hide spinner
        });
      }
    }
  }

  void showRatingBar(
    BuildContext context,
    String productId, // Pass only the ID
  ) {
    double userRating = 3;
    TextEditingController reviewController =
        TextEditingController(); // Controller for review

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              context.translate('product_rating_prompt'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Color(0xff25313c),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RatingBar.builder(
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
                  SizedBox(height: 15), // Add spacing
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: context.translate(
                          'write_review_optional'), // Add translation key
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(context.translate('cancel')),
              ),
              _isRating
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop(); // Close dialog first
                        await rateProduct(productId, userRating,
                            review: reviewController.text);
                      },
                      child: Text(context.translate('ok')),
                    ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while fetching
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show error message if fetching failed
    if (_errorMessage != null || _productData == null || _sellerData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.translate('error')),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage ??
                  context.translate('error_occurred') + " (Data missing)",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // --- Extract data from state variables ---
    final prdt = _productData!;
    final seller = _sellerData!;

    final link = prdt['whatsappLink'] as String? ?? '';
    final prdtName = prdt['name'] as String? ?? 'N/A';
    final description =
        prdt['description'] as String? ?? 'No description available.';
    // final List<String> imagesUrl = (prdt['imagesUrl'] as List<dynamic>? ?? [])
    //     .map((url) => url.toString())
    //     .where((url) => url.isNotEmpty)
    //     .toList();

    // --- New image handling ---
    final List<String> imagesUrl = (prdt['images'] as List<dynamic>? ?? [])
        .map((img) {
          final imgMap = img as Map<String, dynamic>?;
          // Use fileId directly
          final imageId = imgMap?['fileId'] as String?;
          if (imageId != null && imageId.isNotEmpty) {
            return '$settingsFileBaseUrl$imageId';
          }
          return null; // Return null for invalid entries
        })
        .where((url) =>
            url != null && url.isNotEmpty) // Filter out null/empty URLs
        .cast<String>() // Cast to String
        .toList();
    // --- End new image handling ---

    final rating = (prdt['overallRating'] as num?)?.toDouble() ?? 0.0;
    final ratingCount = (prdt['ratings'] as List<dynamic>? ?? []).length;
    final price = (prdt['price'] as num?)?.toDouble() ?? 0.0;
    final prdtId = prdt['_id']
        as String?; // Already have widget.productId, but keep for safety

    final sellerName = seller['name'] as String? ?? 'N/A';
    final sellerAvatar = seller['avatar'] as String? ?? '';
    final sellerEmail = seller['email'] as String? ?? 'N/A';
    final sellerRegion = seller['region'] as String? ?? 'N/A';
    final sellerCountry = seller['country'] as String? ?? 'N/A';
    final sellerPhone = seller['phoneNumber']?.toString() ?? 'N/A';
    final sellerId = seller['_id'] as String?;

    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xffffffff),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40 * fem,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            context.pop();
                          },
                          icon: Icon(Icons.close),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.share),
                              tooltip: context.translate('share'),
                              onPressed: () {
                                Share.share(shareLink);
                              },
                            ),
                            PopupMenuButton(
                              icon: Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == '/rate') {
                                  showRatingBar(
                                      context, widget.productId); // Pass ID
                                }
                                // Add other actions if needed
                              },
                              itemBuilder: (BuildContext bc) {
                                return <PopupMenuEntry>[
                                  PopupMenuItem(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(context.translate(
                                            'rate_this_product')), // Add translation key if missing
                                        SizedBox(width: 8),
                                        Icon(Icons.star, size: 20),
                                      ],
                                    ),
                                    value: '/rate',
                                  ),
                                ];
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 320 * fem,
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    child: imagesUrl.isNotEmpty
                        ? AnotherCarousel(
                            images: imagesUrl.map((url) {
                              return NetworkImage(url!);
                            }).toList(),
                            boxFit: BoxFit.contain,
                            showIndicator: imagesUrl.length > 1,
                            dotSize: 4.0 * fem,
                            dotSpacing: 15.0 * fem,
                            dotColor: Colors.grey,
                            dotIncreasedColor:
                                Theme.of(context).colorScheme.primary,
                            dotBgColor: Colors.transparent,
                            borderRadius: false,
                          )
                        : Center(
                            child:
                                Text(context.translate('no_images_available'))),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20 * fem,
                      vertical: 5 * fem,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(
                          height: 20.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              child: Text(
                                prdtName,
                                textAlign: TextAlign.left,
                                style: SafeGoogleFont(
                                  'Mulish',
                                  fontSize: 30 * ffem,
                                  fontWeight: FontWeight.w800,
                                  height: 1.255 * ffem / fem,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                price == 0
                                    ? context.translate('free')
                                    : '$price FCFA',
                                textAlign: TextAlign.left,
                                style: SafeGoogleFont(
                                  'Mulish',
                                  fontSize: 25 * ffem,
                                  fontWeight: FontWeight.w800,
                                  height: 1.255 * ffem / fem,
                                  color: Color(0xfff49101),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Center(
                          child: InkWell(
                            onTap: () {
                              showRatingBar(context, widget.productId);
                            },
                            child: RatingBar.builder(
                              initialRating: rating,
                              minRating: 0,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              ignoreGestures: true,
                              itemSize: 20,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 2.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {},
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        ReusableButton(
                          title: context.translate('share'),
                          onPress: () {
                            Share.share(shareLink);
                          },
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        _division(fem, ffem, context.translate('description'),
                            description),
                        _division(fem, ffem, context.translate('localization'),
                            '${sellerCountry} - $sellerRegion'),
                        _division(
                            fem, ffem, context.translate('seller_info'), ''),
                        FilleulsCard(
                          url: seller['avatarId'] != null &&
                                  seller['avatarId'].isNotEmpty
                              ? '$settingsFileBaseUrl${seller['avatarId']}'
                              : null, // Pass null or default if no avatarId
                          name: sellerName,
                          email: sellerPhone,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        ReusableButton(
                          title: context.translate('contact_now'),
                          onPress: () {
                            launchURL(link);
                          },
                        ),
                        const SizedBox(
                            height: 20.0), // Add space before ratings
                        _buildRatingsSection(fem, ffem), // Add ratings section
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper widget for Ratings Section ---
  Widget _buildRatingsSection(double fem, double ffem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
            color: Theme.of(context).colorScheme.outlineVariant, thickness: 1),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10 * fem),
          child: Text(
            context.translate('ratings_reviews'), // Add translation key
            style: SafeGoogleFont(
              'Montserrat',
              fontSize: 16 * ffem,
              fontWeight: FontWeight.w700,
              color: Color(0xff25313c),
            ),
          ),
        ),
        if (_ratingsList.isEmpty && !_isRatingsLoading)
          Padding(
            padding: EdgeInsets.all(16 * fem),
            child: Center(
                child: Text(context
                    .translate('no_ratings_yet'))), // Add translation key
          )
        else
          Container(
            // Constrain the height to avoid unbounded height error in SingleChildScrollView
            height: 300 * fem, // Adjust height as needed
            child: ListView.builder(
              controller: _ratingsScrollController,
              itemCount: _ratingsList.length + (_hasMoreRatings ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _ratingsList.length) {
                  // Loading indicator at the bottom
                  return _isRatingsLoading
                      ? Center(
                          child: Padding(
                          padding: EdgeInsets.all(8.0 * fem),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ))
                      : SizedBox.shrink(); // Hide if not loading
                }
                final ratingData = _ratingsList[index];
                return _RatingCard(
                    ratingData: ratingData, fem: fem, ffem: ffem);
              },
            ),
          ),
      ],
    );
  }
  // --- End Ratings Section ---

  // --- Helper widget for individual rating card ---
  Widget _RatingCard(
      {required Map<String, dynamic> ratingData,
      required double fem,
      required double ffem}) {
    final ratingValue = (ratingData['rating'] as num?)?.toDouble() ?? 0.0;
    final review = ratingData['review'] as String?;
    final createdAtString = ratingData['createdAt'] as String?;
    DateTime? createdAt;
    if (createdAtString != null) {
      createdAt = DateTime.tryParse(createdAtString);
    }

    // TODO: Fetch user details based on ratingData['userId'] if needed
    // For now, we'll just display the rating and review

    return Card(
      margin: EdgeInsets.symmetric(vertical: 5 * fem),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(10 * fem),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RatingBar.builder(
                  initialRating: ratingValue,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 16 * fem,
                  ignoreGestures: true,
                  itemPadding: EdgeInsets.symmetric(horizontal: 1.0 * fem),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {},
                ),
                Spacer(),
                if (createdAt != null)
                  Text(
                    DateFormat('MMM d, yyyy').format(createdAt), // Format date
                    style: SafeGoogleFont(
                      'Montserrat',
                      fontSize: 10 * ffem,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
            if (review != null && review.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8 * fem),
                child: Text(
                  review,
                  style: SafeGoogleFont(
                    'Montserrat',
                    fontSize: 12 * ffem,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  // --- End Rating Card ---

  Column _division(double fem, double ffem, title, description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: Theme.of(context).colorScheme.outlineVariant,
          thickness: 1,
        ),
        Container(
          margin: EdgeInsets.fromLTRB(
            0 * fem,
            0 * fem,
            0 * fem,
            5 * fem,
          ),
          child: Text(
            title,
            style: SafeGoogleFont(
              'Montserrat',
              fontSize: 12 * ffem,
              fontWeight: FontWeight.w800,
              height: 1.3333333333 * ffem / fem,
              letterSpacing: 0.400000006 * fem,
              color: Color(0xff6d7d8b),
            ),
          ),
        ),
        Container(
          child: Text(
            description,
            textAlign: TextAlign.left,
            style: SafeGoogleFont(
              'Montserrat',
              fontSize: 12 * ffem,
              fontWeight: FontWeight.w600,
              height: 1.5 * ffem / fem,
              color: Colors.grey,
            ),
          ),
        ),
        if (description != '')
          SizedBox(
            height: 20.0,
          ),
      ],
    );
  }
}
