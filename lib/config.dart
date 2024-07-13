import 'dart:ui';

// const host = 'http://127.0.0.1:5000/';//local host
// const host = 'http://192.168.43.224:5000/';//your hotspot
// const host = 'http://192.168.1.103:5000/';//wifi MTN BOX
const host = 'https://sniper-xvs9.onrender.com/';//online

const url = '${host}api/user/';
const registration = "${url}register";
const login = '${url}login';
const logout = '${url}logout';
const update = '${url}update';
const uploadPP = '${url}upload-avatar';
const downloadPP = '${url}download-avatar';
const downloadVcf = '${url}download-vcf';

const downloadPoliss = '${url}download-policies';
const downloadPres = '${url}download-presentation';
const downloadContacts = '${url}download-contacts';
const downloadContactsUpdates = '${url}download-contacts-updates';

const subscriptiion = '${url}subscription';
const withdraw = '${url}withdraw';
const getUpdates = '${url}get-infos';
const getReferals = '${url}get-referals';

const getProducts = '${url}get-products';
const rateThisProduct = '${url}rate-product';
const uploadProduct = '${url}add-product';
const findUrProduct = '${url}your-product';
const updateProduct = '${url}modify-product';
const deleteProduct = '${url}delete-product';

const sendfOTP = '${url}send-fpw-otp';
const modEmail = '${url}modify-email';
const validatefOTP = '${url}validate-fpw-otp';
const validateEOTP = '${url}validate-email-otp';


const blue = Color(0xff1862f0);
const limeGreen = Color(0xff92b127);


  const subProducts = [
    "",
    "mode et vêtements",
    "électronique et gadgets",
    "maison et jardin",
    "beauté et soins personnels",
    "alimentation et boissons",
    "santé et bien-être",
    "sport et loisirs",
    "jouets et jeux",
    "accessoires automobiles",
    "outils et équipements de bricolage",
    "animaux de compagnie",
    "livres et médias",
    "art et artisanat",
    "produits pour bébés et enfants",
    "fournitures de bureau et papeterie",
    "équipements de voyage",
    "instruments de musique",
    "produits technologiques",
    "produits écologiques et durables",
    "autres"
  ];

  const subServices = [
    "",
    "consultation professionnelle",
    "services de formation et d'apprentissage",
    "services de design",
    "services de rédaction et de traduction",
    "services de programmation et de développement",
    "services de marketing et de publicité",
    "services de maintenance et de réparation",
    "services de santé et de bien-être",
    "services de consultation juridique",
    "services de planification d'événements",
    "autres"
  ];


const onesignalAppId = 'f7b51254-5fba-4b77-b8c3-8b24a7c55f8e';
