import 'dart:ui';

// const host = 'http://127.0.0.1:5000/';
// const host = 'http://192.168.43.224:5000/';
// const host = 'http://192.168.1.138:5000/';
const host = 'https://sniper-xvs9.onrender.com/';

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

const subscriptiion = '${url}subscription';
const withdraw = '${url}withdraw';
const getUpdates = '${url}get-infos';
const getReferals = '${url}get-referals';

const sendfOTP = '${url}send-fpw-otp';
const validatefOTP = '${url}validate-fpw-otp';



const limeGreen = Color(0xff92b127);

const onesignalAppId = 'f7b51254-5fba-4b77-b8c3-8b24a7c55f8e';
