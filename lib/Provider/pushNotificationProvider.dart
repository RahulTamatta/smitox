import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import '../Screen/Product Detail/productDetailHome.dart';
import '../repository/productListRespository.dart';
import '../repository/pushnotificationRepositry.dart';
import 'SettingProvider.dart';

class PushNotificationProvider extends ChangeNotifier {
  void registerToken(String? token, BuildContext context) async {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(context, listen: false);
    if (settingsProvider.getSessionValue(FCMTOKEN).toString().trim() != token) {
      var parameter = {
        FCM_ID: token,
      };
      if (context.read<UserProvider>().userId != '') {
        parameter[USER_ID] = context.read<UserProvider>().userId;
      }

      await NotificationRepository.updateFcmID(parameter: parameter)
          .then((value) {
        if (value['error'] == false) {
          settingsProvider.setPrefrence(FCMTOKEN, token!);
        }
      });
    }
  }

  Future<void> getProduct(
      String id, int index, int secPos, bool list, BuildContext context) async {
    try {
      var parameter = {
        ID: id,
      };

      var result = await ProductListRepository.getList(parameter: parameter);

      bool error = result['error'];
      if (!error) {
        var data = result['data'];

        List<Product> items =
            (data as List).map((data) => Product.fromJson(data)).toList();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => ProductDetailHome(
              index: int.parse(id),
              model: items[0],
              secPos: secPos,
              list: list,
            ),
          ),
        );
      } else {}
    } on Exception {}
  }
}
