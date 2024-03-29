import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../../Model/Section_Model.dart';
import '../../../widgets/desing.dart';
import '../productDetailHome.dart';
import '../../../Helper/Color.dart';

class ProductItemView extends StatelessWidget {
  int index;
  List<Product> productList;
  String from;
  ProductItemView({
    Key? key,
    required this.productList,
    required this.from,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (index < productList.length) {
      String? offPer;
      double price =
          double.parse(productList[index].prVarientList![0].disPrice!);
      if (price == 0) {
        price = double.parse(productList[index].prVarientList![0].price!);
      } else {
        double off =
            double.parse(productList[index].prVarientList![0].price!) - price;
        offPer = ((off * 100) /
                double.parse(productList[index].prVarientList![0].price!))
            .toStringAsFixed(2);
      }

      double width = deviceWidth! * 0.45;

      return SizedBox(
        height: 255,
        width: width,
        child: Card(
          elevation: 0.2,
          margin: const EdgeInsetsDirectional.only(bottom: 5, end: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(circularBorderRadius10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(circularBorderRadius5),
                    child: Hero(
                      tag:
                          '$heroTagUniqueString$from$index${productList[index].id}0',
                      child: DesignConfiguration.getCacheNotworkImage(
                        boxFit: BoxFit.cover,
                        context: context,
                        heightvalue: double.maxFinite,
                        widthvalue: double.maxFinite,
                        placeHolderSize: double.maxFinite,
                        imageurlString: productList[index].image!,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 5.0,
                    top: 5,
                  ),
                  child: Row(
                    children: [
                      RatingBarIndicator(
                        rating: double.parse(productList[index].rating!),
                        itemBuilder: (context, index) => const Icon(
                          Icons.star_rate_rounded,
                          color: Colors.amber,
                        ),
                        unratedColor: Colors.grey.withOpacity(0.5),
                        itemCount: 5,
                        itemSize: 12.0,
                        direction: Axis.horizontal,
                        itemPadding: const EdgeInsets.all(0),
                      ),
                      Text(
                        ' (${productList[index].noOfRating!})',
                        style: Theme.of(context).textTheme.labelSmall,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                      start: 5.0, top: 5, bottom: 5),
                  child: Text(
                    productList[index].name!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 5.0),
                  child: Row(
                    children: [
                      Text(
                        '${DesignConfiguration.getPriceFormat(context, price)!} ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        double.parse(productList[index]
                                    .prVarientList![0]
                                    .disPrice!) !=
                                0
                            ? DesignConfiguration.getPriceFormat(
                                context,
                                double.parse(productList[index]
                                    .prVarientList![0]
                                    .price!),
                              )!
                            : '',
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: Theme.of(context).colorScheme.lightBlack,
                              decorationColor: colors.darkColor3,
                              decorationStyle: TextDecorationStyle.solid,
                              decorationThickness: 2,
                              letterSpacing: 0,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              Product model = productList[index];
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ProductDetailHome(
                    model: model,
                    secPos: 0,
                    index: index,
                    list: true,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
