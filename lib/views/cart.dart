import 'package:flutter/material.dart';
// import 'package:open_whatsapp/open_whatsapp.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/component/list_cart.dart';
import 'package:testgetdata/provider/cart_provider.dart';
import 'package:testgetdata/model/cart_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {

  TextEditingController namaPembeli = TextEditingController();
  TextEditingController ruanganPembeli = TextEditingController();

  void openDialog(){
    showDialog(context: context, builder: (BuildContext contex){
      return AlertDialog(
        title: const Text("Data Lengkap Pembeli"),
        content: Container(
          height: 200,
          child: Column(
            children: [
              Text("Nama"),
              TextFormField(
                controller: namaPembeli,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              Text("Ruangan"),
              TextFormField(
                controller: ruanganPembeli,
                decoration: InputDecoration(border: OutlineInputBorder()),
             ),
              SizedBox(height: 10),
              Consumer<CartProvider>(
                builder: (contex, data, _){
                  return Expanded(
                    child: ElevatedButton(onPressed: () async{
                      var url = 'whatsapp://send?phone=6285706015892';
                      String strPesanan = '';
                      data.cart.forEach((element) {
                        strPesanan += '${element.menuNama.toString()} (${element.count}) --> {TENANT M-1}\n';
                      });
                      String pesanan =
                          'Nama : ${namaPembeli.text} \n'
                          'Ruangan : ${ruanganPembeli.text} \n'
                          'Pesanan : ${strPesanan} \n'
                      ;
                      url = '${url}&text=${pesanan}';
                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    }, child: Text("Kirim")),
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<CartModel> cart = Provider.of<CartProvider>(context).cart;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            color: Colors.red,
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            Consumer<CartProvider>(
              builder: (context, data, _){
                return ListView.separated(
                    separatorBuilder: (context, index){
                      return Divider();
                    },
                    shrinkWrap: true,
                    itemCount: data.cart.length,
                    itemBuilder: (context, i){
                      // print(cart.length);
                      return ListCart(cart: data.cart[i]);
                    }
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  )
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: <Widget>
                    [
                      Text(
                        "Ringkasan Pembayaran",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                        [
                          Text("Harga"),
                          Column(
                            children: cart.map((e) {
                              return Text((e.menuPrice * e.count).toString());
                            }).toList(),
                          )
                        ],
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                        [
                          Text("Total", style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),),
                          Text(Provider.of<CartProvider>(context).cost.toString(), style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        bottomNavigationBar: InkWell(
          onTap:(){
            return openDialog();
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset.zero,
                          blurRadius: 2,
                          color: Colors.black26.withOpacity(0.3),
                        )
                      ]
                  ),
                  height: 63,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Lanjutkan", style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),)
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


