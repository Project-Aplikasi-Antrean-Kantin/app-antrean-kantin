import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant/widgets/exit_dialog_self_service.dart';

class HeaderMenuTenant extends StatefulWidget {
  final bool requiredExitCode;
  final CartProvider cartProvider;
  final ValueChanged<String> onSearch;
  final VoidCallback onSearchClear;

  const HeaderMenuTenant(
      {super.key,
      required this.requiredExitCode,
      required this.cartProvider,
      required this.onSearch,
      required this.onSearchClear});

  @override
  State<HeaderMenuTenant> createState() => _HeaderMenuTenantState();
}

class _HeaderMenuTenantState extends State<HeaderMenuTenant> {
  bool _isSearchMode = false;
  final TextEditingController _searchController = TextEditingController();
  late ValueNotifier<Color> _iconColorNotifier;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _iconColorNotifier = ValueNotifier<Color>(Colors.grey);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _iconColorNotifier.value = AppColors.primaryColor;
      } else {
        _iconColorNotifier.value = Colors.grey;
      }
      setState(() {}); // untuk update border container
    });
  }

  @override
  void dispose() {
    _iconColorNotifier.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Tombol Back
        Semantics(
          identifier: 'backButton',
          child: GestureDetector(
            onTap: () async {
              if (widget.requiredExitCode == true) {
                final result = await showExitDialogSelfService(context);
                if (result == true) {
                  widget.cartProvider.popTenant();
                  Navigator.pop(context);
                }
                return;
              }
              widget.cartProvider.popTenant();
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.all(12),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft02,
                color: AppColors.whiteColor900,
                size: 20,
              ),
            ),
          ),
        ),

        // Search Area
        Flexible(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation, axis: Axis.horizontal, child: child),
            child: _isSearchMode
                ? Container(
                    height: 44,
                    key: const ValueKey('searchField'),
                    margin: const EdgeInsets.only(left: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        width: 1,
                        color: _focusNode.hasFocus
                            ? AppColors.primaryColor
                            : AppColors.backgroundColor,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      autofocus: true,
                      onChanged: (value) {
                        widget.onSearch(value); // ← kirim ke parent
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,

                        // 🔥 prefixIcon berubah warna ikut focus
                        prefixIcon: ValueListenableBuilder<Color>(
                          valueListenable: _iconColorNotifier,
                          builder: (context, color, child) {
                            return Icon(
                              Iconsax.search_normal_1_copy,
                              size: 20,
                              color: color,
                            );
                          },
                        ),

                        hintText: "Lagi pengen makan apa?",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.withOpacity(0.7),
                          fontSize: 12,
                        ),

                        // 🔥 tombol clear
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _isSearchMode = false;
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                            });
                            widget.onSearchClear();
                          },
                        ),
                      ),
                    ),
                  )
                : GestureDetector(
                    key: ValueKey('searchIcon'),
                    onTap: () {
                      setState(() {
                        _isSearchMode = true;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.all(12),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01,
                        color: AppColors.whiteColor900,
                        size: 20,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
