// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    var cartList = cart.items.values.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Total',
                  style: TextStyle(fontSize: 20),
                ),
                Spacer(),
                Chip(
                  label: Text(
                    '\$${cart.totalAmount}',
                    style: TextStyle(
                      color:
                          Theme.of(context).primaryTextTheme.titleMedium.color,
                    ),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                FlatButton(
                  onPressed: () {},
                  child: Text('Order Now'),
                  textColor: Theme.of(context).primaryColor,
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, index) => CartItemWidget(
                cartList[index].id,
                cart.items.keys.toList()[index],
                cartList[index].price,
                cartList[index].quantity,
                cartList[index].title,
              ),
              itemCount: cart.itemCount,
            ),
          ),
        ],
      ),
    );
  }
}
