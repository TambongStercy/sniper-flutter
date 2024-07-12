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
import 'package:snipper_frontend/utils.dart';

class ModifyProduct extends StatefulWidget {
  // static const id = 'addProduct';

  ModifyProduct({required this.product});

  final Map<String, dynamic> product;

  @override
  State<ModifyProduct> createState() => _ModifyProductState();
}

class _ModifyProductState extends State<ModifyProduct> {
  bool showSpinner = false;

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
  List existingImages = [];

  String prdtid = '';
  String prdtName = '';
  String price = '';
  String description = '';

  @override
  void initState() {
    super.initState();

    existingImages = product['urls'];

    prdtid = product['id'];
    prdtName = product['name'];
    price = product['price'].toString();
    description = product['description'];
    category = product['category'];
    subcategory = product['subcategory'];

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
        showSpinner = false;
        initSharedPref();
      });
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

  refresh() {
    if (mounted) {
      setState(() {
        showSpinner = true;
      });
    }
  }

  List<String> categories = [
    "services",
    "produits",
  ];
  String category = "produits";

  List<String> subcategories = [];
  String subcategory = "électronique et gadgets";

  Future<void> modifyProduct(BuildContext context) async {
    try {
      final body = {
        'id': prdtid,
        'name': prdtName,
        'price': price,
        'description': description,
        'category': category,
        'subcategory': subcategory,
        'existingImages': jsonEncode(existingImages),
      };

      final url = Uri.parse('$updateProduct?email=$email');

      final request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['email'] = email ?? '';

      for (final filePath in images) {
        final fileName = kIsWeb
            ? generateUniqueFileName('prdt', 'jpg')
            : Uri.file(filePath).pathSegments.last;

        if (kIsWeb) {
          print('filePath is fileBytes but in String form');

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

      // Add body parameters
      request.fields.addAll(body);

      final response = await request.send();

      if (response.statusCode == 200) {
        showPopupMessage(
          context,
          'Succès',
          'Produit, modifié avec succès',
        );

        refresh();
      } else {
        print('request failed with status: ${response.statusCode}');
        // ignore: use_build_context_synchronously
        showPopupMessage(
          context,
          'Erreur',
          'Une erreur est survenue. Veuillez reessayer plus tard',
        );
      }

      showSpinner = false;
    } catch (e) {
      String msg = e.toString();
      String title = 'Error';
      showPopupMessage(context, title, msg);
      print(e);
      showSpinner = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return SimpleScaffold(
      title: 'Modifier le produit',
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
                  if (images.length + existingImages.length < 5) addImage(fem),
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
                      _label(fem, ffem, 'Nom du produit/service'),
                      CustomTextField(
                        hintText: prdtName,
                        onChange: (val) {
                          prdtName = val;
                        },
                        margin: 0,
                        value: prdtName,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15 * fem,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(fem, ffem, 'Catégorie'),
                      CustomDropdown(
                        items: categories,
                        value: category,
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
                      _label(fem, ffem, 'Sous-catégorie'),
                      CustomDropdown(
                        items: subcategories,
                        value: subcategory,
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
                      _label(fem, ffem, 'Prix(FCFA)'),
                      CustomTextField(
                        hintText: price,
                        value: price,
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
                      _label(fem, ffem, 'Déscription'),
                      CustomTextField(
                        hintText: description,
                        value: description,
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
              title: 'Modifier',
              lite: false,
              onPress: () async {
                try {
                  refreshPageWait();
                  await modifyProduct(context);
                  refreshPageRemove();
                } catch (e) {
                  String msg = e.toString();
                  String title = 'Error';
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

            if(heavy)
            showPopupMessage(context, 'Fichier trop volumineux', 'Un ou plusieures images sont trop lourdes, chaque ficher dois être inferieur a 5Mo');
            
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
                      'Ajouter une image',
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
    final imageList = existingImages + images;

    return imageList.map((image) {
      bool isExistingImage = existingImages.contains(image);

      final imageUse = isExistingImage ? existingImages : images;

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
                fit: BoxFit.cover,
                image:
                    isExistingImage ? NetworkImage(image) : productImage(image),
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
                    imageUse.remove(image);
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
