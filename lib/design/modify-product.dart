import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/dropdown.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/components/top_notification_banner.dart';

class ModifyProduct extends StatefulWidget {
  static const id = 'modProduct';

  ModifyProduct({required this.product});

  final Map<String, dynamic> product;

  @override
  State<ModifyProduct> createState() => _ModifyProductState();
}

class _ModifyProductState extends State<ModifyProduct> {
  bool isUploading = false;
  String? uploadStatus;
  final ApiService apiService = ApiService();

  late SharedPreferences prefs;

  Map<String, dynamic> get product => widget.product;

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');
    email = prefs.getString('email');
    name = prefs.getString('name');
    region = prefs.getString('region');
    phone = prefs.getString('phone');
    avatar = prefs.getString('avatar') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;

    isUploading = false;
  }

  String? email;
  String? name;
  String? region;
  String? phone;
  String? token;
  String avatar = '';
  bool isSubscribed = false;
  List<String> images = [];
  List<Map<String, dynamic>> existingImages = [];

  String prdtid = '';
  String prdtName = '';
  String price = '';
  String description = '';

  @override
  void initState() {
    super.initState();

    final imageListFromProduct =
        widget.product['images'] as List<dynamic>? ?? [];
    existingImages = imageListFromProduct
        .map((img) => Map<String, dynamic>.from(img))
        .toList();

    prdtid = widget.product['_id'] as String? ?? '';
    prdtName = widget.product['name'] as String? ?? '';
    price = (widget.product['price'] as num?)?.toString() ?? '0';
    description = widget.product['description'] as String? ?? '';
    category = widget.product['category'] as String? ?? 'produits';
    subcategory = widget.product['subcategory'] as String? ?? '';

    subcategories =
        List.from(category == 'produits' ? subProducts : subServices);

    print(category);
    print(subcategory);
    print(subcategories);

    // Create anonymous function:
    () async {
      await initSharedPref();
      setState(() {
        // Update your UI with the desired changes.
      });
    }();
  }

  refreshPage() {
    if (mounted) {
      setState(() {
        isUploading = false;
        initSharedPref();
      });
    }
  }

  refreshPageRemove() {
    if (mounted) {
      setState(() {
        isUploading = false;
      });
    }
  }

  refreshPageWait() {
    if (mounted) {
      setState(() {
        isUploading = true;
      });
    }
  }

  refresh() {
    if (mounted) {
      setState(() {
        isUploading = true;
      });
    }
  }

  List<String> categories = [
    "services",
    "produits",
  ];
  List<String> subcategories = [];

  String category = "produits";
  String subcategory = "électronique et gadgets";

  Future<void> modifyProduct(BuildContext context) async {
    setState(() {
      isUploading = true;
      uploadStatus = null;
    });
    try {
      final Map<String, String> productUpdates = {
        'name': prdtName.trim(),
        'price': price.trim().isEmpty ? '0' : price.trim(),
        'description': description.trim(),
        'category': category.trim(),
        'subcategory': subcategory.trim(),
      };
      List<String> imagePayload = List<String>.from(images);
      final response = await apiService.updateProduct(
        prdtid,
        productUpdates,
        imageFiles: imagePayload.isNotEmpty ? imagePayload : null,
      );
      final msg = response.message;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          uploadStatus = context.translate('product_modified_successfully');
        });
        showPopupMessage(
          context,
          context.translate('success'),
          msg.isNotEmpty
              ? msg
              : context.translate('product_modified_successfully'),
        );
      } else {
        setState(() {
          uploadStatus =
              msg.isNotEmpty ? msg : context.translate('error_occurred_retry');
        });
        print('API Error modifyProduct: ${response.statusCode} - $msg');
        showPopupMessage(
          context,
          context.translate('error'),
          uploadStatus!,
        );
      }
    } catch (e) {
      String errorMsg = e.toString();
      String title = context.translate('error');
      setState(() {
        uploadStatus = errorMsg;
      });
      showPopupMessage(context, title, errorMsg);
      print('Exception in modifyProduct: $e');
    } finally {
      setState(() => isUploading = false);
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
          context.translate('modify_product'),
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Card(
                margin: EdgeInsets.all(24 * fem),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24 * fem),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image selection section
                      Container(
                        height: 245 * fem,
                        color: Colors.grey.shade100,
                        padding: EdgeInsets.symmetric(vertical: 16 * fem),
                        alignment: Alignment.center,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(horizontal: 16 * fem),
                          children: [
                            ...imageDisplay(fem),
                            if (images.length + existingImages.length < 5)
                              addImage(fem),
                          ],
                        ),
                      ),
                      SizedBox(height: 24 * fem),
                      _formField(
                        label: context.translate('product_name'),
                        field: CustomTextField(
                          hintText: prdtName,
                          onChange: (val) {
                            prdtName = val;
                          },
                          margin: 0,
                          value: prdtName,
                        ),
                        fem: fem,
                        ffem: ffem,
                      ),
                      _formField(
                        label: context.translate('category'),
                        field: CustomDropdown(
                          items: categories,
                          value: category,
                          ffem: ffem,
                          onChange: onChangeCategory,
                        ),
                        fem: fem,
                        ffem: ffem,
                      ),
                      _formField(
                        label: context.translate('subcategory'),
                        field: CustomDropdown(
                          items: subcategories,
                          value: subcategory,
                          ffem: ffem,
                          onChange: onChangeSubCategory,
                        ),
                        fem: fem,
                        ffem: ffem,
                      ),
                      _formField(
                        label: context.translate('price'),
                        field: CustomTextField(
                          hintText: price,
                          value: price,
                          onChange: (val) {
                            price = val;
                          },
                          margin: 0,
                          fieldType: CustomFieldType.number,
                        ),
                        fem: fem,
                        ffem: ffem,
                      ),
                      _formField(
                        label: context.translate('description'),
                        field: CustomTextField(
                          hintText: description,
                          value: description,
                          onChange: (val) {
                            description = val;
                          },
                          margin: 0,
                          fieldType: CustomFieldType.multiline,
                        ),
                        fem: fem,
                        ffem: ffem,
                      ),
                      SizedBox(height: 32 * fem),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isUploading
                              ? () {}
                              : () {
                                  modifyProduct(context);
                                },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isUploading
                                ? context.translate('uploading')
                                : context.translate('modify'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (uploadStatus != null)
            TopNotificationBanner(
              message: uploadStatus!,
              visible: uploadStatus != null,
              status: uploadStatus ==
                      context.translate('product_modified_successfully')
                  ? 'success'
                  : 'error',
              onDismiss: () => setState(() => uploadStatus = null),
            ),
        ],
      ),
    );
  }

  Widget _formField({
    required String label,
    required Widget field,
    required double fem,
    required double ffem,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24 * fem),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8 * fem),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16 * ffem,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          field,
        ],
      ),
    );
  }

  void onChangeCategory(String? newValue) {
    if (mounted)
      setState(() {
        category = newValue!;

        // Initialize subcategories based on the selected category
        subcategories.clear();
        if (category == 'produits') {
          subcategories.addAll(subProducts);
        } else if (category == 'services') {
          subcategories.addAll(subServices);
        }

        subcategory = category == 'produits'
            ? 'électronique et gadgets'
            : 'services de design';
      });
  }

  void onChangeSubCategory(String? newValue) {
    if (mounted)
      setState(() {
        subcategory = newValue ?? subcategory;
      });
  }

  Container _label(double fem, double ffem, title) {
    return Container(
      margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 7 * fem),
      child: Text(
        title,
        style: SafeGoogleFont(
          'Montserrat',
          fontSize: 12 * ffem,
          fontWeight: FontWeight.w500,
          height: 1.3333333333 * ffem / fem,
          letterSpacing: 0.400000006 * fem,
          color: Color(0xff6d7d8b),
        ),
      ),
    );
  }

  Center addImage(double fem) {
    return Center(
      child: InkWell(
        onTap: () async {
          try {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.image,
              allowMultiple: true,
            );

            if (result == null) return;

            bool heavy = false;

            for (final file in result.files) {
              print(file);

              if (images.length + existingImages.length >= 5) break;

              if (file.size > 5242880) {
                heavy = true;
                continue;
              }

              List<int>? fileBytes = file.bytes;

              final filePath = kIsWeb ? base64.encode(fileBytes!) : file.path!;

              images.add(filePath);
            }

            refreshPageRemove();

            if (heavy)
              showPopupMessage(context, 'Fichier trop volumineux',
                  'Un ou plusieures images sont trop lourdes, chaque ficher dois être inferieur a 5Mo');
          } catch (e) {
            print(e);
            refreshPageRemove();
          }
        },
        child: Container(
          margin: EdgeInsets.symmetric(
            vertical: 25 * fem,
            horizontal: 5 * fem,
          ),
          child: DottedBorder(
            borderType: BorderType.RRect,
            dashPattern: [8, 4],
            radius: Radius.circular(12),
            color: Colors.grey,
            strokeWidth: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      size: 50,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Text(
                      'Ajouter une image',
                      style: SafeGoogleFont(
                        'Mulish',
                        height: 1.255,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.0,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Stack> imageDisplay(double fem) {
    // Combine existing images (as Maps) and new images (as Strings) for display purposes
    final List<dynamic> displayList = [...existingImages, ...images];

    return displayList.map((image) {
      // Check if the current item is from the existingImages list (it will be a Map)
      bool isExistingImage = image is Map<String, dynamic>;

      return Stack(
        children: [
          Container(
            width: 122 * fem,
            margin: EdgeInsets.symmetric(
              vertical: 25 * fem,
              horizontal: 5 * fem,
            ),
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
              border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12 * fem),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: isExistingImage
                    ? NetworkImage(
                        // Construct URL for existing using fileId directly
                        '$settingsFileBaseUrl${image['fileId'] ?? ''}')
                    : productImage(
                        image as String), // Use helper for new (path/base64)
              ),
            ),
          ),
          Positioned(
            top: 5,
            right: -10,
            child: IconButton(
              onPressed: () {
                if (mounted)
                  setState(() {
                    // Remove from the correct list based on type
                    if (isExistingImage) {
                      existingImages.removeWhere((imgMap) =>
                          imgMap['fileId'] ==
                          image['fileId']); // Match by fileId
                    } else {
                      images.remove(image as String);
                    }
                  });
              },
              icon: Container(
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(12 * fem),
                  color: Colors.white,
                ),
                child: Icon(Icons.close, size: 20),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  ImageProvider<Object> productImage(String avatarPath) {
    if (kIsWeb) {
      final bytes = base64.decode(avatarPath);

      return MemoryImage((bytes));
    }

    if (ppExist(avatarPath)) {
      // Check if the user's profile picture path is not empty and the file exists.

      return FileImage(File(avatarPath));
    }

    // Return the default profile picture from the asset folder.
    return const AssetImage(
      'assets/design/images/your picture.png',
    );
  }

  Future<bool> checkIfImageExists(String imageUrl) async {
    try {
      final response = await http.head(Uri.parse(imageUrl));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false; // An error occurred, so image may not exist
    }
  }
}
