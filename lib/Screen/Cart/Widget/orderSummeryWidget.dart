import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/String.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/CartProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';

// ignore: must_be_immutable
class OrderSummery extends StatelessWidget {
  List<SectionModel> cartList;
  OrderSummery({Key? key, required this.cartList}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${getTranslated(context, 'ORDER_SUMMARY')!} (${cartList.length} items)',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ubuntu',
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (context.read<CartProvider>().selectedPe == 'Advance'
                          ? 'Pending'
                          : getTranslated(context, 'SUBTOTAL')!),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.lightBlack2,
                        fontFamily: 'ubuntu',
                      ),
                    ),
                    Text(
                      '${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().selectedPe == 'Advance' ? ((context.read<CartProvider>().oriPrice) - (context.read<CartProvider>().oriPrice * double.parse(context.read<CartProvider>().percentage ?? '0') / 100)) : context.read<CartProvider>().oriPrice)!} ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ubuntu',
                      ),
                    )
                  ],
                ),
                if (cartList[0].productList![0].productType !=
                    'digital_product')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getTranslated(context, 'DELIVERY_CHARGE')!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontFamily: 'ubuntu',
                        ),
                      ),
                      Text(
                        '${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().deliveryCharge)!} ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ubuntu',
                        ),
                      )
                    ],
                  ),
                if (IS_SHIPROCKET_ON == '1' &&
                    context.read<CartProvider>().shipRocketDeliverableDate !=
                        '' &&
                    !context.read<CartProvider>().isLocalDelCharge!)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getTranslated(context, 'DELIVERY_DAY_LBL')!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.lightBlack2),
                      ),
                      Text(
                        context.read<CartProvider>().shipRocketDeliverableDate,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                context.read<CartProvider>().isPromoValid!
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getTranslated(context, 'PROMO_CODE_DIS_LBL')!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.lightBlack2,
                              fontFamily: 'ubuntu',
                            ),
                          ),
                          Text(
                            '- ${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().promoAmt)!} ',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.fontColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ubuntu',
                            ),
                          )
                        ],
                      )
                    : const SizedBox(),
                context.read<CartProvider>().isUseWallet!
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getTranslated(context, 'WALLET_BAL')!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.lightBlack2,
                              fontFamily: 'ubuntu',
                            ),
                          ),
                          Text(
                            '${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().usedBalance)!} ',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.fontColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ubuntu',
                            ),
                          )
                        ],
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color:
                Colors.grey[200], // Use a light grey color for the background
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Text(
              //   'COD Charge: 10% advance amount, rest COD',
              //   style: TextStyle(
              //     fontSize: 10.0,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // SizedBox(
              //     height: 2.0), // Add some vertical spacing between the text
              Text(
                'Delivery Charge: Delivery charge will be added',
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
