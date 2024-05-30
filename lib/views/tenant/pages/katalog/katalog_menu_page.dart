import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/provider/katalog_menu_provider.dart';
import 'package:testgetdata/views/components/appbar.dart';
import 'package:testgetdata/views/tenant/pages/katalog/menu_habis_page.dart';
import 'package:testgetdata/views/tenant/pages/katalog/menu_tersedia_page.dart';

class KatalogMenu extends StatelessWidget {
  const KatalogMenu({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoading = true;

    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;

    return FutureBuilder(
        future: context.read<KatalogMenuProvider>().fetchData(user.token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return Consumer<KatalogMenuProvider>(
              builder: (context, provider, child) {
                return DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    appBar: AppBarWidget(
                      leadingIcon: Icons.keyboard_backspace,
                      onLeadingPressed: () {
                        Navigator.of(context).pop();
                      },
                      title: "Katalog Menu",
                      tab1Title: "Tersedia",
                      tab2Title: "Habis",
                      // tab3Title: "harusnya ga ada",
                    ),
                    body: TabBarView(
                      key: UniqueKey(),
                      children: [
                        provider.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : MenuTersedia(
                                data: provider.data,
                              ),
                        provider.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : MenuHabis(
                                data: provider.data,
                              ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        }
        // builder: (context, snapshot){
        //   if(snapshot)
        // },
        // (context) => KatalogMenuProvider(bearerToken: user.token),
        // child:
        // Consumer<KatalogMenuProvider>(builder: (context, provider, child) {
        //   return DefaultTabController(
        //     length: 2,
        //     child: Scaffold(
        //       appBar: AppBarWidget(
        //         leadingIcon: Icons.keyboard_backspace,
        //         onLeadingPressed: () {
        //           Navigator.of(context).pop();
        //         },
        //         title: "Katalog Menu",
        //         tab1Title: "Tersedia",
        //         tab2Title: "Habis",
        //         // tab3Title: "harusnya ga ada",
        //       ),
        //       body: TabBarView(
        //         key: UniqueKey(),
        //         children: [
        //           provider.isLoading
        //               ? const Center(
        //                   child: CircularProgressIndicator(),
        //                 )
        //               : MenuTersedia(
        //                   data: provider.data,
        //                 ),
        //           provider.isLoading
        //               ? const Center(
        //                   child: CircularProgressIndicator(),
        //                 )
        //               : MenuHabis(
        //                   data: provider.data,
        //                 ),
        //         ],
        //       ),
        //     ),
        //   );
        // }
        );
  }
}
