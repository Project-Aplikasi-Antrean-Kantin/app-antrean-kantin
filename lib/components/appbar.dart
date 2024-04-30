// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final String? tab1Title;
//   final String? tab2Title;
//   final String? tab3Title;
//   // final Widget? leading;
//   final IconData? leadingIcon; // Tambahkan parameter leadingIcon
//   final VoidCallback? onLeadingPressed; // Tambahkan parameter onLeadingPressed

//   const AppBarWidget({
//     Key? key,
//     required this.title,
//     this.tab1Title,
//     this.tab2Title,
//     this.tab3Title,
//     // this.leading,
//     this.leadingIcon, // Inisialisasi parameter leadingIcon
//     this.onLeadingPressed, // Inisialisasi parameter onLeadingPressed
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final bool hasTabs =
//         tab1Title != null && tab2Title != null && tab3Title != null;

//     return AppBar(
//       scrolledUnderElevation: 0,
//       automaticallyImplyLeading: false,
//       leading: leadingIcon != null
//           ? IconButton(
//               icon: Icon(
//                 leadingIcon,
//                 color: Colors.black,
//                 size: 24,
//               ),
//               onPressed: onLeadingPressed,
//             )
//           : null,
//       title: Text(
//         title,
//         style: GoogleFonts.poppins(
//           fontWeight: FontWeight.bold,
//           fontSize: 20,
//           color: Colors.black,
//         ),
//       ),
//       centerTitle: true,
//       bottom: hasTabs
//           ? TabBar(
//               indicatorColor: Colors.black,
//               indicatorWeight: 1,
//               labelColor: Colors.black,
//               isScrollable: false,
//               indicatorSize: TabBarIndicatorSize.tab,
//               tabs: [
//                 Tab(
//                   child: Text(
//                     tab1Title!,
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//                 Tab(
//                   child: Text(
//                     tab2Title!,
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//                 Tab(
//                   child: Text(
//                     tab3Title!,
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           : TabBar(
//               indicatorColor: Colors.black,
//               indicatorWeight: 1,
//               labelColor: Colors.black,
//               isScrollable: false,
//               indicatorSize: TabBarIndicatorSize.tab,
//               tabs: [
//                 Tab(
//                   child: Text(
//                     tab1Title!,
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//                 Tab(
//                   child: Text(
//                     tab2Title!,
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//       toolbarHeight: hasTabs
//           ? kToolbarHeight + kBottomNavigationBarHeight
//           : kToolbarHeight,
//     );
//   }

//   @override
//   Size get preferredSize {
//     final bool hasTabs = tab1Title != null && tab2Title != null;
//     return Size.fromHeight(
//         kToolbarHeight + (hasTabs ? kBottomNavigationBarHeight : 0));
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    return AppBar(
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: leadingIcon != null
          ? IconButton(
              icon: Icon(
                leadingIcon,
                color: Colors.black,
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
          color: Colors.black,
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
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    tab2Title!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    tab3Title!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black,
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
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        tab2Title!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                )
              : null,
      toolbarHeight: hasTabs
          ? kToolbarHeight + kBottomNavigationBarHeight
          : kToolbarHeight,
    );
  }

  @override
  Size get preferredSize {
    final bool hasTabs = tab1Title != null && tab2Title != null;
    return Size.fromHeight(
        kToolbarHeight + (hasTabs ? kBottomNavigationBarHeight : 0));
  }
}
