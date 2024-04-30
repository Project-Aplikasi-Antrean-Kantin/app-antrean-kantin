import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/provider/katalog_menu_provider.dart';
import 'package:testgetdata/views/tenant/pages/menu_habis_page.dart';
import 'package:testgetdata/views/tenant/pages/menu_tersedia_page.dart';
import 'package:testgetdata/components/appbar.dart';

class KatalogMenu extends StatelessWidget {
  const KatalogMenu({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoading = true;

    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;

    return ChangeNotifierProvider(
      create: (context) => KatalogMenuProvider(bearerToken: user.token),
      child: Consumer<KatalogMenuProvider>(builder: (context, provider, child) {
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
      }),
    );
  }
}
