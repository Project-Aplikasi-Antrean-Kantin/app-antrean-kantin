import 'package:flutter/material.dart';
import 'package:testgetdata/http/fetch_all_tenant.dart';
import 'package:testgetdata/model/tenant_model.dart';
import 'package:testgetdata/views/list_tenant.dart';

class Tenant extends StatefulWidget {
  const Tenant({Key? key}) : super(key: key);

  @override
  State<Tenant> createState() => _TenantState();
}

class _TenantState extends State<Tenant> {
  late Future<List<TenantModel>> futureTenant;
  String url = "http://192.168.1.36:8000/api/tenant";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureTenant = fetchTenant(url);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: SafeArea(
            child: Column(
              children: <Widget> [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    top: 70.0
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25.0),
                    child: Image.asset('assets/images/ads.png'),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<TenantModel>>(
                    future: futureTenant,
                    builder: (context, snapshot){
                      if(snapshot.hasData){
                        return Container(
                          margin: const EdgeInsets.all (20.0),
                          child: GridView.builder(
                            itemCount: snapshot.data!.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 20.0
                            ),
                            itemBuilder: (context, index) {
                              return Center(
                                  child: InkWell(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context){
                                        return ListTenant(url: '${url}/${index+1}',);
                                      }));
                                    },
                                    child: Stack(
                                      children: <Widget> [
                                        ClipRRect(
                                            borderRadius: BorderRadius.circular(25.0),
                                            child: Image.asset('assets/images/tenant.png')
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 10,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black12, // warna background
                                              borderRadius: BorderRadius.circular(10), // radius border
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 4.0,
                                                  left: 4.0
                                              ),
                                              child: Text(
                                                '${snapshot.data![index].name}',
                                                style: const TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Oxygen'
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              );
                            },
                          ),
                        );
                      }else if(snapshot.hasError){
                        return Text(snapshot.error.toString());
                      }
                      return const Center(child: CircularProgressIndicator(color: Colors.red,));
                    },
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
