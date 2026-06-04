import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/chat.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/remote/chat_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';

class ChatPage extends StatefulWidget {
  final String chatType;
  final Pesanan pesanan;
  const ChatPage({super.key, required this.chatType, required this.pesanan});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();
  final scrollController = ScrollController(); // <- tambah controller
  List<Chat> listChat = [];
  late StreamSubscription<RemoteMessage> _onMessageSubscription;
  bool isLoading = true;
  bool isSending = false;
  bool isThereText = false;

  @override
  @override
  void initState() {
    super.initState();

    _onMessageSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.data['title']?.toString().toLowerCase();
      if (title != null && title.contains('chat baru')) {
        getChat();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getChat();
    });
  }

  Future<void> getChat() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);
    final token = user.token;
    final destination =
        widget.chatType == "tenant" ? "tenant-buyer" : "driver-buyer";

    final chats = await ChatRemoteDataSource()
        .getChat(token, widget.pesanan.id.toString(), destination);

    setState(() {
      listChat = chats;
      isLoading = false;
    });
    historyProvider.removeUnreadMessages(widget.pesanan.id);
    historyProvider.loadUnreadMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose(); // <- jangan lupa dispose
    _onMessageSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final token = user.token;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.whiteColor100,
        surfaceTintColor: AppColors.backgroundColor,
        title: const Text("Chat",
            style: TextStyle(
                color: AppColors.textColorBlack,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              isLoading
                  ? Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) => Skeletonizer(
                            child: messageBubble(
                                Chat(
                                    transaksiId: 1,
                                    message: "Hanya Dummy Saja",
                                    senderId: 1,
                                    chatType: "tenant",
                                    senderName:
                                        index % 2 == 0 ? "Tenant" : user.nama,
                                    createdAt: DateTime.now()),
                                user,
                                true)),
                        itemCount: 5,
                      ),
                    )
                  : Expanded(
                      child: ListView.separated(
                          controller: scrollController, // <- pakai controller
                          itemCount: listChat.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            if (index == 0)
                              return messageBubble(
                                  listChat[index], user, false);
                            ;
                            return messageBubble(
                                listChat[index],
                                user,
                                listChat[index - 1].senderName ==
                                    listChat[index].senderName);
                          }),
                    ),

              // input bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                color: AppColors.whiteColor100,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          if (value.isNotEmpty)
                            setState(() => isThereText = true);
                        },
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: "Ketik pesan...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                              width: 1,
                            ),
                          ),
                          fillColor: AppColors.whiteColor,
                          filled: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Iconsax.send_1_copy,
                          size: 32,
                          color: controller.text.isEmpty
                              ? Colors.grey
                              : AppColors.primaryColor),
                      onPressed: () async {
                        print("token: $token, message: ${controller.text}");
                        if (isSending) return;
                        setState(() {
                          isSending = true;
                        });
                        final prefs = await SharedPreferences.getInstance();
                        print('unread message: ${prefs.getString('unread')}');
                        if (controller.text.trim().isEmpty) {
                          CustomSnackbar.warning("Tidak boleh kosong");
                          return;
                        }

                        try {
                          await ChatRemoteDataSource()
                              .sendMessage(token, controller.text,
                                  widget.chatType, widget.pesanan.id.toString())
                              .then((value) {
                            setState(() {
                              listChat.add(value);
                            });
                            controller.clear();
                          });

                          // Scroll ke bawah setelah frame dirender
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            scrollController.animateTo(
                              scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          });
                        } catch (e) {
                          CustomSnackbar.error(e.toString());
                          print(e);
                        } finally {
                          setState(() {
                            isSending = false;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget messageBubble(Chat chat, UserModel user, bool prevMessageIsYours) {
    final isSender = chat.senderName == user.nama;

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isSender)
            chat.senderImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(80),
                    child: ImageByUrl(
                      key: ValueKey(chat.senderImage),
                      url: chat.senderImage!,
                      height: 48,
                      width: 48,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.person,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                  ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width * 0.7, // batas maksimal
            ),
            child: Column(
              crossAxisAlignment:
                  isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  chat.senderName,
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSender
                        ? AppColors.primaryColor
                        : AppColors.whiteColor100,
                    borderRadius: isSender
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          )
                        : const BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                  ),
                  child: IntrinsicWidth(
                    // ⬅️ kuncinya di sini
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // selebar konten aja
                      crossAxisAlignment: isSender
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat.message,
                          softWrap: true,
                          style: GoogleFonts.poppins(
                            color: isSender
                                ? Colors.white
                                : AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: isSender
                              ? Alignment.bottomLeft
                              : Alignment.bottomRight,
                          child: Text(
                            FormatDate.dateTimeToStringTime(
                                chat.createdAt.toLocal()),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color:
                                  isSender ? AppColors.whiteColor : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isSender)
            chat.senderImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(80),
                    child: ImageByUrl(
                      key: ValueKey(chat.senderImage),
                      url: chat.senderImage!,
                      height: 48,
                      width: 48,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(80),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        size: 36,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
        ],
      ),
    );
  }
}
