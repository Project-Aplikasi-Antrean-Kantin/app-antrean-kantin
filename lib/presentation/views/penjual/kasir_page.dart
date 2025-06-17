import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/widgets/appbar.dart';
import 'package:testgetdata/presentation/views/penjual/menu_kasir.dart';
import 'package:testgetdata/presentation/widgets/shimmer_widget.dart';

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
                    ? const ShimmerLoadingWidget(
                        itemCount: 4,
                        itemHeight: 120,
                        showContainer: true,
                        shimmerContainerHome: true,
                      )
                    : MenuKasir(
                        data: provider.tenantFoodsList,
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
