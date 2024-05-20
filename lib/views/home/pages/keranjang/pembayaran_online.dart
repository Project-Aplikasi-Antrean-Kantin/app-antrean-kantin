// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:midtrans_sdk/midtrans_sdk.dart';
// import 'package:testgetdata/constants.dart';

// class PembayaranOnline extends StatefulWidget {
//   const PembayaranOnline({super.key});

//   @override
//   State<PembayaranOnline> createState() => _PembayaranOnlineState();
// }

// class _PembayaranOnlineState extends State<PembayaranOnline> {
//   MidtransSDK? _midtrans;

//   void initSDK() async {
//     _midtrans = await MidtransSDK.init(
//       config: MidtransConfig(
//         clientKey: 'SB-Mid-client-T9zZrTGN1ARTH8rb',
//         merchantBaseUrl: MasbroConstants.baseUrl,
//         colorTheme: ColorTheme(
//           colorPrimary: Theme.of(context).colorScheme.secondary,
//           colorPrimaryDark: Theme.of(context).colorScheme.secondary,
//           colorSecondary: Theme.of(context).colorScheme.secondary,
//         ),
//       ),
//     );
//     _midtrans?.setUIKitCustomSetting(
//       skipCustomerDetailsPages: true,
//     );
//     _midtrans!.setTransactionFinishedCallback((result) {
//       print(result.toJson());
//     });
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     initSDK();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Plugin example app'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           child: Text("Pay Now"),
//           onPressed: () async {
//             _midtrans?.startPaymentUiFlow(
//               token: '5b61482a-1033-4116-b954-5e947c745bc1',
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
