import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/remote/transaction_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/riwayat_empty_view.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/riwayat_error_view.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/riwayat_list_view/riwayat_list_view.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/riwayat_loading_view.dart';

class RiwayatPage extends StatefulWidget {
  final String role;
  final String tabLabel;

  const RiwayatPage({super.key, required this.role, required this.tabLabel});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  bool _hasInitialized = false;
  DateTime? _lastFetchTime;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final historyProvider =
          Provider.of<HistoryProvider>(context, listen: false);
      if (_onMessageSubscription == null) {
        _onMessageSubscription =
            FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          final title = message.data['title']?.toString().toLowerCase();
          final body = message.data['body']?.toString().toLowerCase();
          final transaksiId = body?.split(' ')[1].trim();

          final isPureNumber = RegExp(r'^\d+$').hasMatch(transaksiId ?? '');

          if (title != null &&
              transaksiId != 'pesanan' &&
              title.contains('pesanan') &&
              !title.contains('pesanan masuk') &&
              transaksiId != null &&
              isPureNumber) {
            TransactionRemoteDataSource()
                .getOrderById(authProvider.user.token, transaksiId)
                .then((pesanan) {
              historyProvider.updatedPesanan(pesanan, widget.role);
            });
          }
        });
      }
    });

    // Pastikan ini jalan sebelum UI render list
    _fetchDataIfNeeded();
  }

  @override
  void dispose() {
    _onMessageSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh data ketika app kembali dari background
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (state == AppLifecycleState.resumed) {
      historyProvider.loadUnreadMessages().then((_) {
        historyProvider.fetchHistory(
            context, authProvider.user, widget.role, false,
            forceRefresh: true);
        if (historyProvider.selectedPesanan != null) {
          final pesanan = historyProvider.selectedPesanan!;
          TransactionRemoteDataSource()
              .getOrderById(authProvider.user.token, pesanan.id.toString())
              .then((pesanan) {
            historyProvider.updatedPesanan(pesanan, widget.role);
          });
        }
      });
    }
  }

  // Method untuk mengecek apakah perlu fetch data
  Future<void> _fetchDataIfNeeded({bool forceRefresh = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);

    final now = DateTime.now();
    final shouldRefresh = forceRefresh ||
        !_hasInitialized ||
        historyProvider.getListPesanan(widget.role).isEmpty ||
        (_lastFetchTime != null &&
            now.difference(_lastFetchTime!).inMinutes > 5);

    if (shouldRefresh && !historyProvider.getIsLoading(widget.role)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        historyProvider.fetchHistory(
            context, authProvider.user, widget.role, true);
        _lastFetchTime = now;
        _hasInitialized = true;
      });
    }
  }

  // Method yang dipanggil saat tab menjadi visible

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    return Scaffold(
      body: RefreshIndicator(
        backgroundColor: AppColors.backgroundColor,
        color: AppColors.primaryColor,
        onRefresh: () async {
          final historyProvider =
              Provider.of<HistoryProvider>(context, listen: false);
          await historyProvider.refreshHistory(context, user, widget.role);
          _lastFetchTime = DateTime.now();
        },
        child: Container(
          color: AppColors.backgroundColor,
          child: Consumer<HistoryProvider>(
            builder: (context, historyProvider, _) {
              final isLoading = historyProvider.getIsLoading(widget.role);
              final errorMessage = historyProvider.getErrorMessage(widget.role);
              final allPesanan = historyProvider.getListPesanan(widget.role);

              if (isLoading) {
                return RiwayatLoadingView(
                    isLoading: isLoading,
                    tabLabel: widget.tabLabel,
                    role: widget.role);
              }

              if (errorMessage != null) {
                return RiwayatErrorView(
                    errorMessage: errorMessage,
                    onRetry: () => _fetchDataIfNeeded(forceRefresh: true));
              }
              if (allPesanan.isEmpty) {
                return RiwayatEmptyView();
              }
              return RiwayatListView(
                isLoading: isLoading,
                tabLabel: widget.tabLabel,
                role: widget.role,
              );
            },
          ),
        ),
      ),
    );
  }
}
