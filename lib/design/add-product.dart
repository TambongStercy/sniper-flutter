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
    setState(() => showSpinner = true);

    try {
      if (!isSubscribed) {
        String msg = context.translate('not_subscribed_message');
        String title = context.translate('error');
        showPopupMessage(context, title, msg);
        setState(() => showSpinner = false);
        return;
      }

      if (images.isEmpty ||
          prdtName.trim().isEmpty ||
          price.trim().isEmpty ||
          description.trim().isEmpty ||
          category.trim().isEmpty ||
          subcategory.trim().isEmpty) {
        showPopupMessage(
          context,
          context.translate('error'),
          context.translate('fill_all_fields_message'),
        );
        setState(() => showSpinner = false);
        return;
      }

      final productData = {
        'name': prdtName.trim(),
        'price': price.trim(),
        'description': description.trim(),
        'category': category.trim(),
        'subcategory': subcategory.trim(),
      };

      final response = await apiService.createProduct(
          productData, List<String>.from(images));

      if (response['statusCode'] != null &&
          response['statusCode'] >= 200 &&
          response['statusCode'] < 300) {
        showPopupMessage(
          context,
          context.translate('success'),
          response['message'] ??
              context.translate('product_added_successfully'),
        );
      } else {
        String errorMsg = response['message'] ??
            response['error'] ??
            context.translate('try_again_message');
        showPopupMessage(
          context,
          context.translate('error'),
          errorMsg,
        );
        print('API Error addProduct: ${response['statusCode']} - $errorMsg');
      }
    } catch (e) {
      String msg = context.translate('error_occurred') + ': ${e.toString()}';
      String title = context.translate('error');
      showPopupMessage(context, title, msg);
      print('Exception in addProduct: $e');
    } finally {
      setState(() => showSpinner = false);
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
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
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

              // Form fields
              Padding(
                padding: EdgeInsets.all(24 * fem),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _formField(
                      label: context.translate('product_name'),
                      field: CustomTextField(
                        hintText: '',
                        onChange: (val) {
                          prdtName = val;
                        },
                        margin: 0,
                        value: name,
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
                      ),
                      fem: fem,
                      ffem: ffem,
                    ),
                    SizedBox(height: 32 * fem),
                    ReusableButton(
                      title: context.translate('post'),
                      lite: false,
                      onPress: addProduct,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
