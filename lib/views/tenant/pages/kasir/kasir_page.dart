import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/provider/kasir_provider.dart';
import 'package:testgetdata/views/components/appbar.dart';
import 'package:testgetdata/views/tenant/pages/kasir/menu_kasir.dart';
import 'package:testgetdata/views/theme.dart';

class KasirPage extends StatelessWidget {
  const KasirPage({super.key});

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;

    return FutureBuilder(
      future: context.read<KasirProvider>().fetchData(user.token),
      builder: (context, snapshot) {
        return Consumer<KasirProvider>(
          builder: (context, provider, child) {
            return DefaultTabController(
              length: 1,
              child: Scaffold(
                appBar: const AppBarWidget(
                  title: "Kasir",
                ),
                body: provider.isLoading
                    ? Container(
                        color: backgroundColor,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryColor,
                            ),
                          ),
                        ),
                      )
                    : MenuKasir(
                        data: provider.data,
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
