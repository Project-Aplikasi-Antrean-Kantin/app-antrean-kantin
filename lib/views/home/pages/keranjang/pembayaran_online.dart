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
//   late final MidtransSDK _midtrans;

//   void initSDK() async {
//     print("JALANIN SDK MIDTRANS");
//     _midtrans = await MidtransSDK.init(
//       config: MidtransConfig(
//         clientKey: 'SB-Mid-client-T9zZrTGN1ARTH8rb',
//         merchantBaseUrl:
//             'https://app.sandbox.midtrans.com/snap/v4/redirection/',
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
//     // _midtrans!.setTransactionFinishedCallback((result) {
//     //   print(result.toJson());
//     //   // Navigator.pushNamed(context, '/sukses_order');
//     // });
//     _midtrans.setTransactionFinishedCallback((result) {
//       print(result.toJson());
//       if (result.transactionStatus == TransactionResultStatus.settlement) {
//         print('Navigating to /sukses_order');
//         Navigator.pushNamed(context, '/sukses_order');
//       } else {
//         // Handle other transaction statuses if needed
//         print("Transaction failed or was canceled");
//       }
//     });
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       initSDK();
//     });
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
//             print("bisa");
//             _midtrans?.startPaymentUiFlow(
//               token: '0e7c1aa8-b60a-40dc-8ac9-c0be133ed522',
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
