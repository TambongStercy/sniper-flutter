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

  @override
  void initState() {
    super.initState();
    subcategories = List.from(subProducts);

    // Create anonymous function:
    () async {
      await initSharedPref();
      if (mounted) {
        setState(() {
          // Update your UI with the desired changes.
        });
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

  List<String> categories = [
    "services",
    "produits",
  ];

  String category = "produits";

  List<String> subcategories = [];
  String subcategory = "électronique et gadgets";

  Future<void> addProduct(BuildContext context) async {
    try {
      if (!isSubscribed) {
        String msg = 'Vous n\'etes pas abonner😔';
        String title = 'Erreur';
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
          'Erreur',
          'Veillez remplir tous les champs',
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
        // request.files.add(await http.MultipartFile.fromPath('files', filePath));

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
          'Success',
          'Produit ajouter avec succes',
        );

        refresh();
      } else {
        // Read the response as a stream
        final stream = response.stream;

        // Create a string buffer to accumulate the chunks of data
        final buffer = StringBuffer();

        // Listen to the stream
        stream.listen((data) {
          // Append the chunk of data to the buffer
          buffer.write(utf8.decode(data));
        }, onDone: () {
          // When the stream is done, parse the accumulated JSON string
          final jsonString = buffer.toString();
          final jsonData = jsonDecode(jsonString);

          // Now you can access the JSON values
          print('Received JSON data: $jsonData');

          final message = jsonData['message'] ?? '';
          final title = 'Erreur';

          // ignore: use_build_context_synchronously
          showPopupMessage(
            context,
            title,
            message,
          );

        }, onError: (error) {
          // ignore: use_build_context_synchronously
          showPopupMessage(
            context,
            'Erreur',
            'Une erreur est survenue. Veuillez reessayer plus tard',
          );
          // Handle any errors that occur during streaming
          print('Error occurred during streaming: $error');
        });
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
                      _label(fem, ffem, 'Nom du produit/service'),
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
                      _label(fem, ffem, 'Déscription'),
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
              title: 'Poster',
              lite: false,
              onPress: () async {
                try {
                  refreshPageWait();

                  await addProduct(context);

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
              print(file);

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
                'Fichier trop volumineux',
                'Un ou plusieures images sont trop lourdes, chaque ficher dois être inferieur a 5Mo',
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
      // Check if the user's profile picture path is not empty and the file exists.

      return FileImage(File(avatarPath));
    }
    // Return the default profile picture from the asset folder.
    return const AssetImage(
      'assets/design/images/your picture.png',
    );
  }
}
