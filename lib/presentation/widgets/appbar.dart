import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/theme.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? tab1Title;
  final String? tab2Title;
  final String? tab3Title;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingPressed;

  const AppBarWidget({
    Key? key,
    required this.title,
    this.tab1Title,
    this.tab2Title,
    this.tab3Title,
    this.leadingIcon,
    this.onLeadingPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasTabs =
        tab1Title != null && tab2Title != null && tab3Title != null;
    final bool hasTwoTabs = tab1Title != null && tab2Title != null;
    final bool hasThreeTabs = tab1Title != null && tab3Title != null;

    return AppBar(
      backgroundColor: backgroundColor,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: leadingIcon != null
          ? IconButton(
              icon: Icon(
                leadingIcon,
                color: secondaryTextColor,
                size: 24,
              ),
              onPressed: onLeadingPressed,
            )
          : null,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: secondaryTextColor,
        ),
      ),
      centerTitle: true,
      bottom: hasTabs
          ? TabBar(
              indicatorColor: Colors.black,
              indicatorWeight: 1,
              labelColor: Colors.black,
              isScrollable: false,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                  child: Text(
                    tab1Title!,
                    style: GoogleFonts.poppins(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    tab2Title!,
                    style: GoogleFonts.poppins(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    tab3Title!,
                    style: GoogleFonts.poppins(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            )
          : hasTwoTabs
              ? TabBar(
                  indicatorColor: Colors.black,
                  indicatorWeight: 1,
                  labelColor: Colors.black,
                  isScrollable: false,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(
                      child: Text(
                        tab1Title!,
                        style: GoogleFonts.poppins(
                          color: secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        tab2Title!,
                        style: GoogleFonts.poppins(
                          color: secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                )
              : hasThreeTabs
                  ? TabBar(
                      indicatorColor: Colors.black,
                      indicatorWeight: 1,
                      labelColor: Colors.black,
                      isScrollable: false,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(
                          child: Text(
                            tab1Title!,
                            style: GoogleFonts.poppins(
                              color: secondaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            tab3Title!,
                            style: GoogleFonts.poppins(
                              color: secondaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    )
                  : PreferredSize(
                      preferredSize: const Size.fromHeight(5.0),
                      child: Container(
                        color: Colors.grey,
                        height: 0.3,
                      ),
                    ),
      toolbarHeight: hasTabs
          ? kToolbarHeight + kBottomNavigationBarHeight
          : kToolbarHeight,
    );
  }

  @override
  Size get preferredSize {
    final bool hasTabs = tab1Title != null && tab2Title != null;
    final bool hasThreeTabs = tab1Title != null && tab3Title != null;

    final double additionalHeight =
        hasTabs || hasThreeTabs ? kBottomNavigationBarHeight : 0;
    return Size.fromHeight(kToolbarHeight + additionalHeight);
  }
}
