import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/component/list_tenant.dart';
import 'package:testgetdata/http/fetch_all_tenant.dart';
import 'package:testgetdata/model/tenant_model.dart';
import 'package:testgetdata/provider/user_provider.dart';
import 'package:testgetdata/theme/deskripsi_theme.dart';
import 'package:testgetdata/theme/judul_font.dart';
import 'package:testgetdata/theme/sub_judul_theme.dart';
import 'package:testgetdata/views/home/navbar_home.dart';
import 'package:testgetdata/views/list_makanan.dart';
import 'package:testgetdata/views/list_tenant.dart';

import 'package:testgetdata/provider/cart_provider.dart';

import '../cart.dart';

class HomePage extends StatefulWidget {
  static const int homeIndex = 0;

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<TenantModel>> futureTenant;
  String url = "http://masbrocanteen.me/api/tenant";
  List<TenantModel> foundTenant = [];
  List<TenantModel> fullTenant = [];

  @override
  void initState() {
    // TODO: implement initState'
    super.initState();
    futureTenant = fetchTenant(url);
  }

  FocusNode myfokus = new FocusNode();
  bool ispertama = true;

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context).debugPrintToken();
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "Mau makan apa \nhari ini ?",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                // Container(
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(18),
                //     ),
                //     margin: const EdgeInsets.only(
                //       left: 20.0,
                //       right: 20.0,
                //     ),
                //     height: 47,
                //     child:
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        cursorColor: Colors.grey,
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (value) {
                          List<TenantModel> result = [];
                          if (value.isEmpty) {
                            result = fullTenant;
                          } else {
                            result = fullTenant
                                .where((tenant) => (tenant.name +
                                        tenant.subname +
                                        tenant.foods.toString())
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          }
                          print(result);
                          setState(() {
                            foundTenant = result;
                          });
                        },
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            prefixIcon: Icon(Icons.search, color: Colors.grey,),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 3),
                              borderRadius: BorderRadius.circular(10),
                            )),
                      ),
                    // )
                    ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25.0),
                    child: Image.asset('assets/images/ads.png'),
                  ),
                ),
                FutureBuilder<List<TenantModel>>(
                  future: futureTenant,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      fullTenant = snapshot.data!;
                      print('1');
                      if(ispertama){
                        foundTenant = fullTenant;
                        ispertama = false;
                      }else{
                        if (foundTenant.isEmpty) {
                          print('2');
                          foundTenant = [];
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //       content: Text("Tidak ada data yang ditemukan")),
                          // );
                          return Center(child : Text("Data Tidak Ditemukan", style: GoogleFonts.poppins(
                              color: Colors.black26,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),));
                        }
                      }
                      // if (foundTenant.isEmpty) {
                      //   print('2');
                      //   foundTenant = [];
                      //   // ScaffoldMessenger.of(context).showSnackBar(
                      //   //   const SnackBar(
                      //   //       content: Text("Tidak ada data yang ditemukan")),
                      //   // );
                      //   return ListTenantBaru(
                      //       url: url, foundTenant: foundTenant);
                      // } else {
                      //   print('3');
                      //   print(foundTenant);
                      //   return ListTenantBaru(
                      //       url: url, foundTenant: foundTenant);
                      // }
                      return ListTenantBaru(
                              url: url, foundTenant: foundTenant);
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.red,
                    ));
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton:
        context.watch<CartProvider>().isCartShow
            ? Consumer<CartProvider>(
          builder: (context, data, _) {
            return Container(
              // margin: const EdgeInsets.all(20),
              width: 360,
              height: 63,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                        return const Cart();
                      }));
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        NumberFormat.currency(
                          symbol: 'Rp',
                          decimalDigits: 0,
                          locale: 'id-ID',
                        ).format(data.cost),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        data.total >= 2
                            ? "${data.total} items"
                            : "${data.total} item",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        )
            : null,

        // FloatingActionButton(
        //   shape: BeveledRectangleBorder(),
        //   onPressed: (){
        //
        //   },
        // ),

        bottomNavigationBar: NavbarHome(pageIndex: HomePage.homeIndex,)
        );
  }
}
