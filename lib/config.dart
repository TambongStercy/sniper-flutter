import 'dart:ui';

// const host = 'http://127.0.0.1:5000/';//local host
// const host = 'http://192.168.225.238:5000/';// slade tech
// const host = 'http://192.168.43.191:5000/';//your hotspot
const host = 'http://192.168.1.103:5000/';//wifi MTN BOX
// const host = 'https://sniper-xvs9.onrender.com/';//online

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
const getReferedUsers = '${url}get-refered-users';

const getProducts = '${url}get-products';
const getProduct = '${url}get-product';
const rateThisProduct = '${url}rate-product';
const uploadProduct = '${url}add-product';
const findUrProduct = '${url}your-product';
const updateProduct = '${url}modify-product';
const deleteProduct = '${url}delete-product';

const sendfOTP = '${url}send-fpw-otp';
const modEmail = '${url}modify-email';
const modMomo = '${url}modify-momo';
const validatefOTP = '${url}validate-fpw-otp';
const validateEOTP = '${url}validate-email-otp';

const blue = Color(0xff1862f0);
const limeGreen = Color(0xff92b127);

const subProducts = [
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

const d_PP = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAAPFBMVEXk5ueutLepsLPo6uursbXJzc/p6+zj5ea2u76orrKvtbi0ubzZ3N3O0dPAxcfg4uPMz9HU19i8wcPDx8qKXtGiAAAFTElEQVR4nO2d3XqzIAyAhUD916L3f6+f1m7tVvtNINFg8x5tZ32fQAIoMcsEQRAEQRAEQRAEQRAEQRAEQRAEQRAEQRAEQRAEQTghAJD1jWtnXJPP/54IgNzZQulSmxvTH6oYXX4WS+ivhTbqBa1r26cvCdCu6i0YXbdZ0o4A1rzV+5IcE3YE+z58T45lqo7g1Aa/JY5tgoqQF3qb382x7lNzBLcxft+O17QUYfQI4IIeklKsPSN4i6LKj/7Zm8n99RbHJpEw9gEBXNBpKIYLJqKYRwjOikf//r+J8ZsVuacbqCMNleI9TqGLGqMzhnVdBOdd6F/RlrFijiCoVMk320CBIahUxTWI0KKEcJqKbMdpdJb5QvdHq6wCI5qhKlgGMS/RBHkubWDAE+QZxB4xhCyDiDkLZxgGEVdQldzSKbTIhmZkFkSEPcVvmBn2SMuZB9od7fQDsMiDdKJjFUSCQarM5WirZ3C2TT/htYnyPcPfgrFHWz0BI74gr6J/IZiGUxAZGQLqmvQLTrtE/Go4YxhVRIpEw+sww1IIcqr5NKmUUzLF3d4/qPkYIp2T/obPuemlojFUR4t9Q2Vojhb7BmgElWHzLPH8hucfpefPNFTVgs9h1AdU/Pin96vwWbWdf+X9Absn3OdO34aMdsDnP8WgKYisTqI6CkNGqZQo1XA6Ef6AU32SJzOcBukHPF07/xNSgmHKa5BOhtezv6mA/rYJpwXNAnbRZ1XuF3BzDcO3vpA3+ny2909gbqE4hhD3LIPhLLyBNhPZvbZ3B+3tPYa18A7auSlXQayKwTPNLKDcuOB0xPYKDPFTkWsevQPRZ1J8Hji9I1KQ34r7hZhrwNwOZ97QxNx0drwn4QI0wQk1DcEsfKCWKdxVvxPSNUIp/knmAXT+nT+Ko3+0H96rcNb3m1fx7MBTJdeBJ7uFcWsc0wvgAsC4pROW0l2inbAmIBv/7GZmuhQH6API2rr8T0e6yuZJ+80A9LZeG62T3tik31XwxtwZcizKuTHkMjB1WdZde4Kmic/A5ZI3rr1ae21d08PlVHYfAaxw9G9CYRbJ+8ZdbTcMRV1XM3VdF0M32vtoTdZ0+u29s0OttJ5bz64UwinjaFMVY9vkqc3KKSxN21Xl+0L4Q3Vuv1tYl0pqnX6ms4XetFz7gdZVAgUEoJntfOUe4ZwsHd9FzqQ3Vv6xe41l0XJcqcKl6TZvlv7ClAW3BsqQW4X7ypApB8dmTgK4IX5wvqIVj33HtD2qSG4BqznxdIefL27Y4sahi0MdIdvUsDva8agGGbCtITmCY31MHD2O0uIdh/0rJDQ1VX5Zdxz3rR2QDbv6qXl9vudzqQtGm1Jv9LDXOsfvvB7VcZ8PDKD0mQ1VHPYQ9O+Yj4hR1IUD8rBnn3ho2m8oQMxbCFiKlL2ioSW5heeJqegED52CzxCtcGD3Kv8Wms9EYLyUhwaFIhSMBClevWEmiK/Iaogu4H7sg6ppQhQG8RUqivuTGOAJOg6FfgW0q0M0PQMRMEgXaeNf3SYDZ8PIMI0+wHgr/MgN7wYwpiLjCCqM6ydUDZLQiB6nDdNC8SDyig3jPPpFXGcC9O8BUBDVmgBY59E7Md/35Loe/UVEECEJwYggJjELZ4J71SaQSBeC02n4Da29CayJNA28SAhd2CQyC1Xw6pSmGSINQVuMhAZp4DClan9MgmkDDNmezqwS8sgtlXK/EPBhoaSmYVC/F7IO1jQEdHOlabpKh3+jzLQSTUiq4X2I+Ip/zU8rlaqAvkS21ElR+gqu3zbjjL+hIAiCIAiCIAiCIAiCsCf/AKrfVhSbvA+DAAAAAElFTkSuQmCC';
