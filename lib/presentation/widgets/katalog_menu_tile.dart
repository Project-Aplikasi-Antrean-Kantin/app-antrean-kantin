import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/remote/tenant_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/katalog_menu_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/penjual/katalog_menu_form.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/custom_toggle.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class KatalogMenuTile extends StatelessWidget {
  final TenantFoods item;
  final void Function(bool) onChanged;

  const KatalogMenuTile({
    super.key,
    required this.item,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   border: Border.all(
      //     width: 1.0,
      //     color: Colors.grey[900]!,
      //   ),
      // ),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // image: DecorationImage(
              //   image: NetworkImage("${MasbroConstants.baseUrl}${item.gambar}"),
              //   fit: BoxFit.cover,
              // ),
            ),
            height: 104,
            width: 104,
            margin: const EdgeInsets.only(right: 15),
            child: item.isReady == 1
                ? ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(10),
                    child: ImageByUrl(
                        key: ValueKey(item.id),
                        url: item.gambar,
                        fit: BoxFit.cover))
                : ColorFiltered(
                    colorFilter: item.isReady == 1
                        ? const ColorFilter.mode(
                            Colors.transparent, BlendMode.multiply)
                        : const ColorFilter.matrix(<double>[
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                          ]),
                    child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(10),
                        child: ImageByUrl(
                            key: Key(item.id.toString() + "menu-image"),
                            url: item.gambar,
                            fit: BoxFit.cover)),
                  ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: semibold,
                    fontSize: 16,
                    color: AppColors.textColorBlack,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  FormatCurrency.intToStringCurrency(item.harga),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.blackColor,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  spacing: 4,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final internetConnection = await hasInternetAccess();
                        if (!internetConnection) {
                          Fluttertoast.showToast(
                              msg: "Tidak ada koneksi internet");
                          return;
                        }
                        Navigator.push(
                          context,
                          CustomPageBuilder(
                            page: KatalogMenuForm(
                              initialData: item,
                            ),
                          ),
                        ).then((value) {
                          if (value == true) {
                            context.read<KatalogMenuProvider>().fetchData(
                                  context.read<AuthProvider>().user.token,
                                );
                          }
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: AppColors.infoColor),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4,
                          children: [
                            HugeIcon(
                                icon: HugeIcons.strokeRoundedEdit02,
                                size: 14,
                                color: AppColors.whiteColor100),
                            Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.whiteColor100,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Consumer2<KatalogMenuProvider, AuthProvider>(
                      builder: (context, katalogProvider, authProvider, _) =>
                          GestureDetector(
                        onTap: () async {
                          final internetConnection = await hasInternetAccess();
                          if (!internetConnection) {
                            Fluttertoast.showToast(
                                msg: "Tidak ada koneksi internet");
                            return;
                          }
                          //show alert dialog
                          showDialog(
                              context: context,
                              builder: (context) => CustomAlertDialog(
                                    title: "Menghapus Menu",
                                    message:
                                        "Apakah anda yakin ingin menghapus menu?",
                                    textButtonOk: "Hapus",
                                    textButtonCancel: "Batal",
                                    colorOkButton: AppColors.errorColor,
                                    titleColor: AppColors.errorColor,
                                    onOkPressed: () async {
                                      try {
                                        await katalogProvider.deleteFood(
                                            authProvider.user.token, item.id);
                                        Fluttertoast.showToast(
                                            msg: "Hapus menu berhasil",
                                            textColor: Colors.white,
                                            backgroundColor:
                                                AppColors.successColor);
                                        Navigator.pop(context);
                                      } catch (e) {
                                        Fluttertoast.showToast(
                                            msg: e.toString());
                                      }
                                    },
                                  ));
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: AppColors.errorColor),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4,
                            children: [
                              HugeIcon(
                                  icon: HugeIcons.strokeRoundedDelete03,
                                  size: 14,
                                  color: AppColors.warningColor100),
                              Text(
                                'Hapus',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.whiteColor100,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: CustomToggle(
              key: Key(item.id.toString() + "toggle"),
              value: item.isReady == 1,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
