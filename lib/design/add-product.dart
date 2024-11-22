import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snipper_frontend/components/button.dart';
import 'package:snipper_frontend/components/dropdown.dart';
import 'package:snipper_frontend/components/simplescaffold.dart';
import 'package:http/http.dart' as http;
import 'package:snipper_frontend/components/textfield.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/localization_extension.dart';
import 'package:snipper_frontend/utils.dart';

class AjouterProduit extends StatefulWidget {
  static const id = 'addProduct';

  @override
  State<AjouterProduit> createState() => _AjouterProduitState();
}

class _AjouterProduitState extends State<AjouterProduit> {
  bool showSpinner = false;

  late SharedPreferences prefs;

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');
    email = prefs.getString('email');
    name = prefs.getString('name');
    region = prefs.getString('region');
    phone = prefs.getString('phone');
    avatar = prefs.getString('avatar') ?? '';
    isSubscribed = prefs.getBool('isSubscribed') ?? false;

    showSpinner = false;
  }

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
    () async {
      await initSharedPref();
      if (mounted) {
        setState(() {});
      }
    }();
  }

  refreshPage() {
    if (mounted) {
      setState(() {
        showSpinner = false;
        initSharedPref();
      });
    }
  }

  refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  refreshPageRemove() {
    if (mounted) {
      setState(() {
        showSpinner = false;
      });
    }
  }

  refreshPageWait() {
    if (mounted) {
      setState(() {
        showSpinner = true;
      });
    }
  }

  Future<void> addProduct() async {
    try {
      if (!isSubscribed) {
        String msg = context.translate('not_subscribed_message');
        String title = context.translate('error');
        return showPopupMessage(context, title, msg);
      }

      if (images.isEmpty ||
          prdtName == '' ||
          price == '' ||
          description == '' ||
          subcategory == '' ||
          category == '') {
        return showPopupMessage(
          context,
          context.translate('error'),
          context.translate('fill_all_fields_message'),
        );
      }

      final body = {
        'name': prdtName,
        'price': price,
        'description': description,
        'category': category,
        'subcategory': subcategory,
      };

      final url = Uri.parse('$uploadProduct?email=$email');

      final request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['email'] = email ?? '';

      for (final filePath in images) {
        final fileName = kIsWeb
            ? generateUniqueFileName('prdt', 'jpg')
            : Uri.file(filePath).pathSegments.last;

        if (kIsWeb) {
          final fileBytes = base64.decode(filePath);

          request.files.add(http.MultipartFile.fromBytes(
            'files',
            fileBytes,
            filename: fileName,
          ));
        } else {
          request.files
              .add(await http.MultipartFile.fromPath('files', filePath));
        }
      }

      request.fields.addAll(body);

      final response = await request.send();

      if (response.statusCode == 200) {
        showPopupMessage(
          context,
          context.translate('success'),
          context.translate('product_added_successfully'),
        );

        refresh();
      } else {
        final stream = response.stream;

        final buffer = StringBuffer();

        stream.listen((data) {
          buffer.write(utf8.decode(data));
        }, onDone: () {
          final jsonString = buffer.toString();
          final jsonData = jsonDecode(jsonString);

          print('Received JSON data: $jsonData');

          final message = jsonData['message'] ?? '';
          final title = context.translate('error');

          showPopupMessage(
            context,
            title,
            message,
          );
        }, onError: (error) {
          showPopupMessage(
            context,
            context.translate('error'),
            context.translate('try_again_message'),
          );
          print('Error occurred during streaming: $error');
        });
      }

      showSpinner = false;
    } catch (e) {
      String msg = e.toString();
      String title = context.translate('error');
      showPopupMessage(context, title, msg);
      print(e);
      showSpinner = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize categories and subcategories inside build() where `context` is available
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

    return SimpleScaffold(
      title: 'Ajouter un produit',
      inAsyncCall: showSpinner,
      child: Container(
        padding: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 0 * fem),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xffffffff),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 245 * fem,
              color: Colors.grey.shade200,
              padding: EdgeInsets.symmetric(vertical: 10 * fem),
              alignment: Alignment.center,
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: [
                  ...imageDisplay(fem),
                  if (images.length < 5) addImage(fem),
                ],
              ),
            ),
            SizedBox(
              height: 15 * fem,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 10.0),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(fem, ffem, context.translate('product_name')),
                      CustomTextField(
                        hintText: '',
                        onChange: (val) {
                          prdtName = val;
                        },
                        margin: 0,
                        value: name,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15 * fem,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(fem, ffem, context.translate('category')),
                      CustomDropdown(
                        items: categories,
                        value: categories.contains(category) ? category : categories.first,
                        ffem: ffem,
                        onChange: onChangeCategory,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15 * fem,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(fem, ffem, context.translate('subcategory')),
                      CustomDropdown(
                        items: subcategories,
                        value: subcategories.contains(subcategory) ? subcategory : subcategories.first,
                        ffem: ffem,
                        onChange: onChangeSubCategory,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15 * fem,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(fem, ffem, context.translate('price')),
                      CustomTextField(
                        hintText: '',
                        onChange: (val) {
                          price = val;
                        },
                        margin: 0,
                        type: 2,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15 * fem,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(fem, ffem, context.translate('description')),
                      CustomTextField(
                        hintText: '',
                        onChange: (val) {
                          description = val;
                        },
                        margin: 0,
                        type: 6,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15 * fem,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15 * fem,
            ),
            ReusableButton(
              title: context.translate('post'),
              lite: false,
              onPress: () async {
                try {
                  refreshPageWait();

                  await addProduct();

                  refreshPageRemove();
                } catch (e) {
                  String msg = e.toString();
                  String title = context.translate('error');
                  showPopupMessage(context, title, msg);
                  print(e);
                  refreshPageRemove();
                }
              },
            ),
          ],
        ),
      ),
    );
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
    refresh();
  }

  void onChangeSubCategory(String? newValue) {
    subcategory = newValue ?? subcategory;

    refresh();
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
              if (images.length >= 5) break;

              if (file.size > 5242880) {
                heavy = true;
                continue;
              }
              List<int>? fileBytes = file.bytes;

              final filePath = kIsWeb ? base64.encode(fileBytes!) : file.path!;

              images.add(filePath);
            }

            if (heavy)
              showPopupMessage(
                context,
                context.translate('file_too_large'),
                context.translate('image_size_warning'),
              );

            refreshPageRemove();
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
                      color: blue,
                    ),
                    Text(
                      context.translate('add_image'),
                      style: SafeGoogleFont(
                        'Mulish',
                        height: 1.255,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.0,
                        color: blue,
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
            width: 122 * fem,
            margin: EdgeInsets.symmetric(
              vertical: 25 * fem,
              horizontal: 5 * fem,
            ),
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(12 * fem),
              image: DecorationImage(
                  fit: BoxFit.cover, image: productImage(image)),
            ),
          ),
          Positioned(
            top: 5,
            right: -10,
            child: IconButton(
              onPressed: () {
                images.remove(image);
                refresh();
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
      return FileImage(File(avatarPath));
    }
    return const AssetImage(
      'assets/design/images/your picture.png',
    );
  }
}
