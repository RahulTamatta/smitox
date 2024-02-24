import 'dart:async';
import 'dart:convert';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/routes.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/Favourite/FavoriteProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Provider/authenticationProvider.dart';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:eshop_multivendor/Provider/productDetailProvider.dart';
import 'package:eshop_multivendor/Screen/Auth/Set_Password.dart';
import 'package:eshop_multivendor/Screen/Auth/SignUp.dart';
import 'package:eshop_multivendor/Screen/Dashboard/Dashboard.dart';
import 'package:eshop_multivendor/Screen/PushNotification/PushNotificationService.dart';
import 'package:eshop_multivendor/repository/systemRepository.dart';
import 'package:eshop_multivendor/widgets/security.dart';
import 'package:eshop_multivendor/widgets/systemChromeSettings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/desing.dart';
import '../../widgets/snackbar.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';

class VerifyOtp extends StatefulWidget {
  const VerifyOtp(
      {Key? key,
      required String this.mobileNumber,
      this.countryCode,
      this.userExists,
      this.title,
      required this.isPop,
      this.isRefresh})
      : super(key: key);

  final String? mobileNumber, countryCode, title;
  final bool? userExists;
  final bool isPop;
  final bool? isRefresh;
  @override
  _MobileOTPState createState() => _MobileOTPState();
}

class _MobileOTPState extends State<VerifyOtp> with TickerProviderStateMixin {
  AnimationController? buttonController;
  Animation? buttonSqueezeanimation;
  final dataKey = GlobalKey();
  bool isCodeSent = false;
  String? otp;
  String? password;
  String signature = '';
  bool acceptTnC = false;
  bool? googleLogin, appleLogin;
  String? countryName;
  bool isShowPass = true;
  final mobileController = TextEditingController(text: '1020304050');
  FocusNode? passFocus, monoFocus = FocusNode();
  final passwordController = TextEditingController(text: 'TestUser@1234');
  bool socialLoginLoading = false;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _isClickable = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _verificationId = ''; // Initialize with an empty string

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChromeSettings.setSystemUIOverlayStyleWithNoSpecification();
    buttonController!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    SystemChromeSettings.setSystemButtomNavigationBarithTopAndButtom();
    SystemChromeSettings.setSystemUIOverlayStyleWithNoSpecification();
    getSystemSettings();
    super.initState();

    getSingature();
    _onVerifyCode();
    Future.delayed(const Duration(seconds: 60)).then(
      (_) {
        _isClickable = true;
      },
    );
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
  }

  void validateAndSubmit() async {
    _playAnimation();
    checkNetwork();
  }

  // bool validateAndSave() {
  //   final form = _formkey.currentState!;
  //   form.save();
  //   if (form.validate()) {
  //     return true;
  //   }
  //   return false;
  // }

  clearYouCartDialog() async {
    await DesignConfiguration.dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    circularBorderRadius5,
                  ),
                ),
              ),
              title: Text(
                getTranslated(context,
                    'Your cart already has an items of another seller would you like to remove it ?')!,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal,
                  fontSize: textFontSize16,
                  fontFamily: 'ubuntu',
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: SvgPicture.asset(
                        DesignConfiguration.setSvgPath('appbarCart'),
                        colorFilter: const ColorFilter.mode(
                            colors.primary, BlendMode.srcIn),
                        height: 50,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text(
                          getTranslated(context, 'CANCEL')!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.lightBlack,
                            fontSize: textFontSize15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ubuntu',
                          ),
                        ),
                        onPressed: () {
                          Routes.pop(context);
                          db.clearSaveForLater();
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/home', (r) => false);
                        },
                      ),
                      TextButton(
                        child: Text(
                          getTranslated(context, 'Clear Cart')!,
                          style: const TextStyle(
                            color: colors.primary,
                            fontSize: textFontSize15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ubuntu',
                          ),
                        ),
                        onPressed: () {
                          if (context.read<UserProvider>().userId != '') {
                            context.read<UserProvider>().setCartCount('0');
                            context
                                .read<ProductDetailProvider>()
                                .clearCartNow(context)
                                .then(
                              (value) async {
                                if (context
                                        .read<ProductDetailProvider>()
                                        .error ==
                                    false) {
                                  if (context
                                          .read<ProductDetailProvider>()
                                          .snackbarmessage ==
                                      'Data deleted successfully') {
                                  } else {
                                    setSnackbar(
                                        context
                                            .read<ProductDetailProvider>()
                                            .snackbarmessage,
                                        context);
                                  }
                                } else {
                                  setSnackbar(
                                      context
                                          .read<ProductDetailProvider>()
                                          .snackbarmessage,
                                      context);
                                }
                                Routes.pop(context);
                                await offCartAdd();
                                db.clearSaveForLater();
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home',
                                  (r) => false,
                                );
                              },
                            );
                          } else {
                            Routes.pop(context);
                            db.clearSaveForLater();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (r) => false,
                            );
                          }
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> getSystemSettings() async {
    try {
      setState(() {
        socialLoginLoading = true;
      });
      var getData = await SystemRepository.fetchSystemSetting(parameter: {});
      if (!getData['error']) {
        var data = getData['systemSetting']['system_settings'][0];

        setState(() {
          googleLogin = data[GOOGLE_LOGIN] == '1';
          appleLogin = data[APPLE_LOGIN] == '1';
        });
      } else {
        setSnackbar(getData['message'], context);
      }
    } catch (e) {
      throw ApiException(e.toString());
    } finally {
      setState(() {
        socialLoginLoading = false;
      });
    }
  }

  saveAndNavigate(var getdata) async {
    SettingProvider settingProvider =
        Provider.of<SettingProvider>(context, listen: false);
    settingProvider.saveUserDetail(
      getdata[ID],
      getdata[USERNAME],
      getdata[EMAIL],
      getdata[MOBILE],
      getdata[CITY],
      getdata[AREA],
      getdata[ADDRESS],
      getdata[PINCODE],
      getdata[LATITUDE],
      getdata[LONGITUDE],
      getdata[IMAGE],
      getdata[TYPE],
      getdata[REFERCODE],
      context,
    );
    print('User details saved successfully.');

    Future.delayed(Duration.zero, () {
      PushNotificationService(context: context).setDeviceToken(
          clearSesssionToken: true, settingProvider: settingProvider);
    });
    print('Device token set.');

    offFavAdd().then(
      (value) async {
        print('Cleared favorites.');
        db.clearFav();
        context.read<FavoriteProvider>().setFavlist([]);
        List cartOffList = await db.getOffCart();
        if (singleSellerOrderSystem && cartOffList.isNotEmpty) {
          forLoginPageSingleSellerSystem = true;
          offSaveAdd().then(
            (value) {
              print('Saved items for later.');
              clearYouCartDialog();
            },
          );
        } else {
          offCartAdd().then(
            (value) {
              print('Cleared cart.');
              db.clearCart();
              offSaveAdd().then(
                (value) {
                  print('Cleared items saved for later.');
                  db.clearSaveForLater();
                  if (widget.isPop) {
                    if (widget.isRefresh != null) {
                      print('Is pop ${widget.isRefresh}');
                      Navigator.pop(context, 'refresh');
                    } else {
                      context.read<HomePageProvider>().getFav(context);
                      context
                          .read<CartProvider>()
                          .getUserCart(save: '0', context: context);

                      Future.delayed(const Duration(seconds: 2)).whenComplete(
                        () {
                          print('Navigating to previous screen.');
                          Navigator.of(context).pop();
                        },
                      );
                    }
                  } else {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const Dashboard()),
                        (route) => false);
                  }
                  /*  Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (r) => false,
                ); */
                },
              );
            },
          );
        }
      },
    );
  }

  Future<void> checkNetwork() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      Future.delayed(Duration.zero).then(
        (value) => context
            .read<AuthenticationProvider>()
            .getLoginData(widget.mobileNumber)
            .then(
          (
            value,
          ) async {
            bool error = value['error'];
            String? errorMessage = value['message'];
            if (!error) {
              print('Inside the  getData');

              var getdata = value['data'][0];
              saveAndNavigate(getdata);
              print('Inside the  save $getdata');
              // setSnackbar(errorMessage!, context);
            } else {
              setSnackbar(errorMessage!, context);
            }
          },
        ),
      );
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          if (buttonController != null && buttonController!.isAnimating) {
            await buttonController!.reverse();
          }
          if (mounted) {
            setState(() {
              isNetworkAvail = false;
            });
          }
        },
      );
    }
  }

  Future<void> getSingature() async {
    signature = await SmsAutoFill().getAppSignature;
    SmsAutoFill().listenForCode;
  }

  Future<void> checkNetworkOtp() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (_isClickable) {
        _onVerifyCode();
      } else {
        setSnackbar(getTranslated(context, 'OTPWR')!, context);
      }
    } else {
      if (mounted) setState(() {});

      Future.delayed(const Duration(seconds: 60)).then(
        (_) async {
          isNetworkAvail = await isNetworkAvailable();
          if (isNetworkAvail) {
            if (_isClickable) {
              _onVerifyCode();
            } else {
              setSnackbar(getTranslated(context, 'OTPWR')!, context);
            }
          } else {
            await buttonController!.reverse();
            setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          }
        },
      );
    }
  }

  Widget verifyBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Center(
        child: AppBtn(
          title: getTranslated(context, 'VERIFY_AND_PROCEED'),
          btnAnim: buttonSqueezeanimation,
          btnCntrl: buttonController,
          onBtnSelected: () async {
            FocusScope.of(context).unfocus();
            _onFormSubmitted();
          },
        ),
      ),
    );
  }

  monoVarifyText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 60.0,
      ),
      child: Text(
        getTranslated(context, 'MOBILE_NUMBER_VARIFICATION')!,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
              fontSize: textFontSize23,
              letterSpacing: 0.8,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  otpText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 13.0,
      ),
      child: Text(
        getTranslated(context, 'SENT_VERIFY_CODE_TO_NO_LBL')!,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  mobText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 5.0),
      child: Text(
        '+${widget.countryCode}-${widget.mobileNumber}',
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  Widget otpLayout() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30),
      child: PinFieldAutoFill(
        decoration: BoxLooseDecoration(
            textStyle: TextStyle(
                fontSize: textFontSize20,
                color: Theme.of(context).colorScheme.fontColor),
            radius: const Radius.circular(circularBorderRadius4),
            gapSpace: 15,
            bgColorBuilder: FixedColorBuilder(
                Theme.of(context).colorScheme.lightWhite.withOpacity(0.4)),
            strokeColorBuilder: FixedColorBuilder(
                Theme.of(context).colorScheme.fontColor.withOpacity(0.2))),
        currentCode: otp,
        codeLength: 6,
        onCodeChanged: (String? code) {
          otp = code;
        },
        onCodeSubmitted: (String code) {
          otp = code;
        },
      ),
    );
  }

  Widget resendText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30.0),
      child: Row(
        children: [
          Text(
            getTranslated(context, 'DIDNT_GET_THE_CODE')!,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ubuntu',
                ),
          ),
          InkWell(
            onTap: () async {
              await buttonController!.reverse();
              checkNetworkOtp();
            },
            child: Text(
              getTranslated(context, 'RESEND_OTP')!,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ubuntu',
                  ),
            ),
          )
        ],
      ),
    );
  }

  Widget getLogo() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 60),
      child: SvgPicture.asset(
        DesignConfiguration.setSvgPath('homelogo'),
        alignment: Alignment.center,
        height: 90,
        width: 90,
        fit: BoxFit.contain,
      ),
    );
  }

  void _onVerifyCode() async {
    if (mounted) {
      setState(
        () {
          isCodeSent = true;
        },
      );
    }
    PhoneVerificationCompleted verificationCompleted() {
      return (AuthCredential phoneAuthCredential) {
        _firebaseAuth.signInWithCredential(phoneAuthCredential).then(
          (UserCredential value) {
            if (value.user != null) {
              /*  SettingProvider settingsProvider =
                  Provider.of<SettingProvider>(context, listen: false);
               */
              setSnackbar(getTranslated(context, 'OTPMSG')!, context);
              /*  settingsProvider.setPrefrence(MOBILE, widget.mobileNumber!);
              settingsProvider.setPrefrence(COUNTRY_CODE, widget.countryCode!); */
              if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
                Future.delayed(const Duration(seconds: 2)).then((_) {
                  Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => SignUp(
                                mobileNumber: widget.mobileNumber!,
                                countryCode: widget.countryCode!,
                              )));
                });
              } else if (widget.title ==
                  getTranslated(context, 'FORGOT_PASS_TITLE')) {
                Future.delayed(const Duration(seconds: 2)).then(
                  (_) {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => SetPass(
                          mobileNumber: widget.mobileNumber!,
                        ),
                      ),
                    );
                  },
                );
              }
            } else {
              setSnackbar(getTranslated(context, 'OTPERROR')!, context);
            }
          },
        ).catchError(
          (error) {
            setSnackbar(error.toString(), context);
          },
        );
      };
    }

    PhoneVerificationFailed verificationFailed() {
      return (FirebaseAuthException authException) {
        if (mounted) {
          setState(
            () {
              isCodeSent = false;
            },
          );
        }
      };
    }

    PhoneCodeSent codeSent() {
      return (String verificationId, [int? forceResendingToken]) async {
        // _verificationId = verificationId;

        setState(
          () {
            _verificationId = verificationId; // Assign the value here
          },
        );
      };
    }

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout() {
      return (String verificationId) {
        // _verificationId = verificationId;

        setState(
          () {
            _isClickable = true;
            _verificationId = verificationId; // Assign the value here
          },
        );
      };
    }

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: '+${widget.countryCode}${widget.mobileNumber}',
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted(),
      verificationFailed: verificationFailed(),
      codeSent: codeSent(),
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout(),
    );
  }

  void _onFormSubmitted() async {
    String code = otp!.trim();

    if (code.length == 6) {
      _playAnimation();
      AuthCredential authCredential = PhoneAuthProvider.credential(
          verificationId: _verificationId, smsCode: code);

      _firebaseAuth
          .signInWithCredential(authCredential)
          .then((UserCredential value) async {
        if (value.user != null) {
          // Your code...

          await buttonController!.reverse();
          setSnackbar(getTranslated(context, 'OTPMSG')!, context);
          // settingsProvider.setPrefrence(MOBILE, widget.mobileNumber!);
          // settingsProvider.setPrefrence(COUNTRY_CODE, widget.countryCode!);
          if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
            Future.delayed(const Duration(seconds: 2)).then((_) {
              if (widget.userExists == true) {
                validateAndSubmit();
                Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const Dashboard()));
              } else {
                Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => SignUp(
                              mobileNumber: widget.mobileNumber!,
                              countryCode: widget.countryCode!,
                            )));
              }
            });
          } else if (widget.title ==
              getTranslated(context, 'FORGOT_PASS_TITLE')) {
            Future.delayed(const Duration(seconds: 2)).then(
              (_) {
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => SetPass(
                      mobileNumber: widget.mobileNumber!,
                    ),
                  ),
                );
              },
            );
          }
          // Check if the controller is not disposed before calling reverse
          if (buttonController != null && buttonController!.isAnimating) {
            await buttonController!.reverse();
          }
        } else {
          setSnackbar(getTranslated(context, 'OTPERROR')!, context);
          // Check if the controller is not disposed before calling reverse
          if (buttonController != null && buttonController!.isAnimating) {
            await buttonController!.reverse();
          }
        }
      }).catchError((error) async {
        setSnackbar(getTranslated(context, 'WRONGOTP')!, context);

        // Check if the controller is not disposed before calling reverse
        if (buttonController != null && buttonController!.isAnimating) {
          await buttonController!.reverse();
        }
      });
    } else {
      setSnackbar(getTranslated(context, 'ENTEROTP')!, context);
    }
  }

  setStateNoInternate() async {
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (BuildContext context) => super.widget,
            ),
          );
        } else {
          await buttonController!.reverse();
          if (mounted) {
            setState(
              () {},
            );
          }
        }
      },
    );
  }

  Future<void> offFavAdd() async {
    List favOffList = await db.getOffFav();
    if (favOffList.isNotEmpty) {
      for (int i = 0; i < favOffList.length; i++) {
        _setFav(favOffList[i]['PID']);
      }
    }
  }

  _setFav(String pid) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          USER_ID: context.read<UserProvider>().userId,
          PRODUCT_ID: pid
        };
        Response response =
            await post(setFavoriteApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata['error'];
        String? msg = getdata['message'];
        if (!error) {
          setSnackbar(msg!, context);
        } else {
          setSnackbar(msg!, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }

  Future<void> offCartAdd() async {
    List cartOffList = await db.getOffCart();
    if (cartOffList.isNotEmpty) {
      for (int i = 0; i < cartOffList.length; i++) {
        addToCartCheckout(cartOffList[i]['VID'], cartOffList[i]['QTY']);
      }
    }
  }

  Future<void> addToCartCheckout(String varId, String qty) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_VARIENT_ID: varId,
          USER_ID: context.read<UserProvider>().userId,
          QTY: qty,
        };

        Response response =
            await post(manageCartApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
          if (getdata['message'] == 'One of the product is out of stock.') {
            homePageSingleSellerMessage = true;
          }
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) isNetworkAvail = false;

      setState(() {});
    }
  }

  Future<void> offSaveAdd() async {
    List saveOffList = await db.getOffSaveLater();

    if (saveOffList.isNotEmpty) {
      for (int i = 0; i < saveOffList.length; i++) {
        saveForLater(saveOffList[i]['VID'], saveOffList[i]['QTY']);
      }
    }
  }

  saveForLater(String vid, String qty) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_VARIENT_ID: vid,
          USER_ID: context.read<UserProvider>().userId,
          QTY: qty,
          SAVE_LATER: '1'
        };
        Response response =
            await post(manageCartApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));
        var getdata = json.decode(response.body);
        bool error = getdata['error'];
        String? msg = getdata['message'];
        if (!error) {
        } else {
          setSnackbar(msg!, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
              top: 23,
              left: 23,
              right: 23,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getLogo(),
              monoVarifyText(),
              otpText(),
              mobText(),
              otpLayout(),
              resendText(),
              verifyBtn(),
            ],
          ),
        ),
      ),
    );
  }
}
