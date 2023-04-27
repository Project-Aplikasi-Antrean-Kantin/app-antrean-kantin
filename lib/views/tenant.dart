import 'package:flutter/material.dart';
import 'package:testgetdata/component/list_tenant.dart';
import 'package:testgetdata/http/fetch_all_tenant.dart';
import 'package:testgetdata/model/tenant_model.dart';
import 'package:testgetdata/theme/deskripsi_theme.dart';
import 'package:testgetdata/theme/judul_font.dart';
import 'package:testgetdata/theme/sub_judul_theme.dart';
import 'package:testgetdata/views/list_makanan.dart';
import 'package:testgetdata/views/list_tenant.dart';

class Tenant extends StatefulWidget {
  const Tenant({Key? key}) : super(key: key);

  @override
  State<Tenant> createState() => _TenantState();
}

class _TenantState extends State<Tenant> {
  late Future<List<TenantModel>> futureTenant;
  String url = "http://masbrocanteen.me/api/tenant";
  List<TenantModel> foundTenant = [];
  List<TenantModel> fullTenant = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureTenant = fetchTenant(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
// <<<<<<< HEAD
      backgroundColor: Color.fromARGB(255, 235, 235, 235),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Mau Makan Apa \nHari Ini ?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                ),
                height: 47,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: TextField(
                    onChanged: (value) {
                      List<TenantModel> result = [];
                      if (value.isEmpty) {
                        result = [];
                      } else {
                        result = fullTenant
                            .where((tenant) => tenant.name
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      }
                      setState(() {
                        foundTenant = result;
                      });
                    },
                    decoration: InputDecoration(
                        icon: Icon(Icons.search_rounded),
                        border: InputBorder.none),
                  ),
                )),
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
                  if (foundTenant.length == 0) {
                    foundTenant = snapshot.data!;
                    return ListTenantBaru(url: url, foundTenant: foundTenant);
                  } else {
                    print(foundTenant);
                    return ListTenantBaru(url: url, foundTenant: foundTenant);
                  }
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
// =======
      // body: SafeArea(
      //   child: SingleChildScrollView(
      //     child: Column(
      //       children: <Widget> [
      //         Padding(
      //           padding: const EdgeInsets.only(
      //             left: 20.0,
      //             right: 20.0,
      //             top: 70.0
      //           ),
      //           child: ClipRRect(
      //             borderRadius: BorderRadius.circular(25.0),
      //             child: Image.asset('assets/images/ads.png'),
      //           ),
      //         ),
      //         FutureBuilder<List<TenantModel>>(
      //             future: futureTenant,
      //             builder: (context, snapshot){
      //               if(snapshot.hasData){
      //                 return Container(
      //                   margin: const EdgeInsets.all (20.0),
      //                   child: GridView.builder(
      //                     shrinkWrap: true,
      //                     physics: const ScrollPhysics(),
      //                     itemCount: snapshot.data!.length,
      //                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //                         crossAxisCount: 2,
      //                         crossAxisSpacing: 20.0
      //                     ),
      //                     itemBuilder: (context, index) {
      //                       return Center(
      //                           child: InkWell(
      //                             onTap: (){
      //                               Navigator.push(context, MaterialPageRoute(builder: (context){
      //                                 return ListTenant(url: '$url/${index+1}',);
      //                               }));
      //                             },
      //                             child: Stack(
      //                               children: <Widget> [
      //                                 ClipRRect(
      //                                     borderRadius: BorderRadius.circular(25.0),
      //                                     child: Image.network(snapshot.data![index].gambar),
      //                                 ),
      //                                 Positioned(
      //                                   bottom: 0,
      //                                   right: 10,
      //                                   child: Container(
      //                                     decoration: BoxDecoration(
      //                                       color: Colors.black12, // warna background
      //                                       borderRadius: BorderRadius.circular(10), // radius border
      //                                     ),
      //                                     child: Padding(
      //                                       padding: const EdgeInsets.only(
      //                                           right: 4.0,
      //                                           left: 4.0
      //                                       ),
      //                                       child: Text(
      //                                         snapshot.data![index].name,
      //                                         style: const TextStyle(
      //                                             fontSize: 18.0,
      //                                             fontWeight: FontWeight.bold,
      //                                             fontFamily: 'Oxygen'
      //                                         ),
      //                                       ),
      //                                     ),
      //                                   ),
      //                                 ),
      //                               ],
      //                             ),
      //                           ),
      //                       );
      //                     },
      //                   ),
      //                 );
      //               }else if(snapshot.hasError){
      //                 return Text(snapshot.error.toString());
      //               }
      //               return const Center(child: CircularProgressIndicator(color: Colors.red,));
      //             },
      //           ),
      //       ],
      //     ),
      //   ),
      // ),
// >>>>>>> 6bca1ae84da46731acf6c21b9926048d8aeba190
    );
  }
}
