// import 'dart:js';

// import 'package:eshop_multivendor/Helper/Constant.dart';
// import 'package:eshop_multivendor/Helper/String.dart';
// import 'package:eshop_multivendor/Model/Section_Model.dart';
// import 'package:eshop_multivendor/Provider/UserProvider.dart';
// import 'package:eshop_multivendor/Screen/ProductList&SectionView/ProductList.dart';
// import 'package:eshop_multivendor/widgets/snackbar.dart';

// import '../../../../Provider/CartProvider.dart';

// void initiateManageCartApiCall() {
//   // Initialize your parameters here if needed
//   var parameter = {
//     // Your parameters
//   };

//   // Your API call
//   apiBaseHelper.postAPICall(manageCartApi, parameter).then(
//     (getdata) {
//       bool error = getdata['error'];
//       String? msg = getdata['message'];
//       if (!error) {
//         var data = getdata['data'];

//         String? qty = data['total_quantity'];
//         context.read<UserProvider>().setCartCount(data['cart_count']);
//         widget.model!.prVarientList![0].cartCount = qty.toString();

//         var cart = getdata['cart'];
//         List<SectionModel> cartList = (cart as List)
//             .map((cart) => SectionModel.fromCart(cart))
//             .toList();
//         context.read<CartProvider>().setCartlist(cartList);
//       } else {
//         setSnackbar(msg!, context);
//       }
//       if (mounted) {
//         isProgress = false;
//         setState(
//           () {},
//         );
//       }
//     },
//     onError: (error) {
//       setSnackbar(error.toString(), context);
//       if (mounted) {
//         isProgress = false;
//         setState(
//           () {},
//         );
//       }
//     },
//   );
// }

// // Now you can call this function whenever you want to initiate the API call
// // For example:
// // initiateManageCartApiCall();
