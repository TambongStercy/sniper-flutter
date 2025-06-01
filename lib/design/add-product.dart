import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/dropdown.dart';
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:snipper_frontend/api_service.dart';
import 'package:snipper_frontend/components/top_notification_banner.dart';

class AjouterProduit extends StatefulWidget {
  static const id = 'addProduct';

  @override
  State<AjouterProduit> createState() => _AjouterProduitState();
}

class _AjouterProduitState extends State<AjouterProduit> {
  bool showSpinner = false;
  final ApiService apiService = ApiService();

  late SharedPreferences prefs;

  String? email;
  String? name;
  String? region;
  String? phone;
  String? token;
  String avatar = '';
  bool isSubscribed = false;
  List images = [];

  String prdtName = '';
  String price = '';
  String description = '';

  List<String> categories = [];
  String category = '';
  List<String> subcategories = [];
  String subcategory = '';

  bool isUploading = false; // Track upload status
  String? uploadStatus; // For showing upload status

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      await initSharedPref();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');
    email = prefs.getString('email');
    name = prefs.getString('name');
    region = prefs.getString('region');
    phone = prefs.getString('phone');
    avatar = prefs.getString('avatar') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;
  }

  Future<void> addProduct() async {
    setState(() {
      isUploading = true;
      uploadStatus = null;
    });

    try {
      if (!isSubscribed) {
        String msg = context.translate('not_subscribed_message');
        String title = context.translate('error');
        showPopupMessage(context, title, msg);
        setState(() => isUploading = false);
        return;
      }

      if (images.isEmpty ||
          prdtName.trim().isEmpty ||
          price.trim().isEmpty ||
          price.trim() == '' ||
          description.trim().isEmpty) {
        showPopupMessage(
          context,
          context.translate('error'),
          context.translate('fill_all_fields_message'),
        );
        setState(() => isUploading = false);
        return;
      }

      final parsedPrice = num.tryParse(price.trim());
      if (parsedPrice == null || parsedPrice < 0) {
        showPopupMessage(
          context,
          context.translate('error'),
          context.translate('invalid_price'),
        );
        setState(() => isUploading = false);
        return;
      }

      final productData = {
        'name': prdtName.trim(),
        'price': price.trim(),
        'description': description.trim(),
        'category':
            category.trim().isEmpty ? categories.first : category.trim(),
        'subcategory': subcategory.trim().isEmpty
            ? subcategories.first
            : subcategory.trim(),
      };

      List imagePayload;
      if (kIsWeb) {
        imagePayload = List<String>.from(images);
      } else {
        imagePayload = List<String>.from(images);
      }

      final response =
          await apiService.addProduct(productData, imageFiles: imagePayload);

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.apiReportedSuccess) {
        setState(() {
          uploadStatus = context.translate('product_added_successfully');
        });
        showPopupMessage(
          context,
          context.translate('success'),
          response.message.isNotEmpty
              ? response.message
              : context.translate('product_added_successfully'),
        );
        setState(() {
          images.clear();
          prdtName = '';
          price = '';
          description = '';
        });
      } else {
        String errorMsg = response.message.isNotEmpty
            ? response.message
            : context.translate('try_again_message');
        setState(() {
          uploadStatus = errorMsg;
        });
        showPopupMessage(
          context,
          context.translate('error'),
          errorMsg,
        );
        print('API Error addProduct: ${response.statusCode} - $errorMsg');
      }
    } catch (e) {
      String msg = context.translate('error_occurred') + ': ${e.toString()}';
      String title = context.translate('error');
      setState(() {
        uploadStatus = msg;
      });
      showPopupMessage(context, title, msg);
      print('Exception in addProduct: $e');
    } finally {
      setState(() => isUploading = false);
    }
  }

  void onChangeCategory(String? newValue) {
    category = newValue!;

    subcategories.clear();
    if (category == context.translate('products')) {
      subcategories.addAll(subProducts);
    } else if (category == context.translate('services')) {
      subcategories.addAll(subServices);
    }

    subcategory = category == context.translate('products')
        ? context.translate('electronics_and_gadgets')
        : context.translate('design_services');
    setState(() {});
  }

  void onChangeSubCategory(String? newValue) {
    subcategory = newValue ?? subcategory;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    categories = [
      context.translate('services'),
      context.translate('products'),
    ];
    category = context.translate('products');
    subcategories = subProducts;
    subcategory = context.translate('electronics_and_gadgets');

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
          context.translate('add_product'),
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
                            if (images.length < 5) addImage(fem),
                          ],
                        ),
                      ),
                      SizedBox(height: 24 * fem),
                      _formField(
                        label: context.translate('product_name'),
                        field: CustomTextField(
                          hintText: '',
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
                          value: categories.contains(category)
                              ? category
                              : categories.first,
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
                          value: subcategories.contains(subcategory)
                              ? subcategory
                              : subcategories.first,
                          ffem: ffem,
                          onChange: onChangeSubCategory,
                        ),
                        fem: fem,
                        ffem: ffem,
                      ),
                      _formField(
                        label: context.translate('price'),
                        field: CustomTextField(
                          hintText: '',
                          onChange: (val) {
                            price = val;
                          },
                          margin: 0,
                          fieldType: CustomFieldType.number,
                          value: price,
                        ),
                        fem: fem,
                        ffem: ffem,
                      ),
                      _formField(
                        label: context.translate('description'),
                        field: CustomTextField(
                          hintText: '',
                          onChange: (val) {
                            description = val;
                          },
                          margin: 0,
                          fieldType: CustomFieldType.multiline,
                          value: description,
                        ),
                        fem: fem,
                        ffem: ffem,
                      ),
                      SizedBox(height: 32 * fem),
                      ReusableButton(
                        title: isUploading
                            ? context.translate('uploading')
                            : context.translate('post'),
                        lite: false,
                        onPress: isUploading
                            ? () {}
                            : () {
                                addProduct();
                              },
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
                      context.translate('product_added_successfully')
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

  Center addImage(double fem) {
    return Center(
      child: InkWell(
        onTap: () async {
          try {
            setState(() => showSpinner = true);

            final result = await FilePicker.platform.pickFiles(
              type: FileType.image,
              allowMultiple: true,
            );

            if (result == null) {
              setState(() => showSpinner = false);
              return;
            }

            bool heavy = false;

            for (final file in result.files) {
              if (images.length >= 5) break;

              if (file.size > 5242880) {
                heavy = true;
                continue;
              }
              List<int>? fileBytes = file.bytes;

              final filePath = kIsWeb ? base64.encode(fileBytes!) : file.path!;

              images.add(filePath);
            }

            if (heavy) {
              showPopupMessage(
                context,
                context.translate('file_too_large'),
                context.translate('image_size_warning'),
              );
            }

            setState(() => showSpinner = false);
          } catch (e) {
            print(e);
            setState(() => showSpinner = false);
          }
        },
        child: Container(
          margin: EdgeInsets.symmetric(
            vertical: 12 * fem,
            horizontal: 8 * fem,
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
                padding: EdgeInsets.symmetric(
                    horizontal: 32 * fem, vertical: 24 * fem),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48 * fem,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(height: 12 * fem),
                    Text(
                      context.translate('add_image'),
                      style: TextStyle(
                        fontSize: 16 * fem,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
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
    return images.map((image) {
      return Stack(
        children: [
          Container(
            width: 150 * fem,
            margin: EdgeInsets.symmetric(
              vertical: 12 * fem,
              horizontal: 8 * fem,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12 * fem),
              image: DecorationImage(
                  fit: BoxFit.cover, image: productImage(image)),
            ),
          ),
          Positioned(
            top: 8 * fem,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.close, size: 20, color: Colors.red),
                onPressed: () {
                  setState(() {
                    images.remove(image);
                  });
                },
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
      return FileImage(File(avatarPath));
    }
    return const AssetImage(
      'assets/design/images/your picture.png',
    );
  }
}
