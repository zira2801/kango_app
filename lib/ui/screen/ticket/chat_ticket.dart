import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/ticket/details_ticket/details_ticket_bloc.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/ticket/details_ticket.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ChatTicketBottomSheet extends StatefulWidget {
  final int ticketID;
  const ChatTicketBottomSheet({required this.ticketID, super.key});
  @override
  _ChatTicketBottomSheetState createState() => _ChatTicketBottomSheetState();
}

class _ChatTicketBottomSheetState extends State<ChatTicketBottomSheet> {
  DetailsTicketModel? detailsTicketModel;
  List<TicketMessage> ticketMess = [];
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  FToast fToast = FToast();
  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    BlocProvider.of<DetailsTicketBloc>(context)
        .add(HandleGetDetailsTicket(ticketID: widget.ticketID));

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels == 0) {
        } else {}
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  _showToast({required String mess, required Color color, required Icon icon}) {
    Widget toast = Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.r),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(
            width: 10.w,
          ),
          TextApp(
            text: mess,
            fontsize: 14.sp,
            color: Colors.white,
          ),
        ],
      ),
    );

    // Custom Toast Position
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
      positionedToastBuilder: (context, child, gravity) {
        return Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 80.h),
                  child: child,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendMessage(
      {required int ticketID,
      required String mess,
      required String? path}) async {
    context.read<DetailsTicketBloc>().add(
          HandleSendMessTicket(ticketID: ticketID, mess: mess, path: path),
        );
    _scrollToBottom();
    _messageController.clear();
  }

  Future<void> _sendImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileName = path.basename(file.path);

        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        String tagName = path.extension(fileName);
        if (tagName.isNotEmpty && tagName.startsWith('.')) {
          tagName = tagName.substring(1);
        }
        _sendMessage(
          ticketID: widget.ticketID,
          mess: base64String,
          path: tagName,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _sendFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        final file = File(result.files.single.path!);
        final fileName = path.basename(file.path);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        String tagName = path.extension(fileName);
        if (tagName.isNotEmpty && tagName.startsWith('.')) {
          tagName = tagName.substring(1);
        }
        _sendMessage(
          ticketID: widget.ticketID,
          mess: base64String,
          path: tagName,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e')),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent + 50);
    }
  }

  Future<void> _downloadAndSaveFile(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsBytes(response.bodyBytes);

        if (fileName.endsWith('.jpg') ||
            fileName.endsWith('.jpeg') ||
            fileName.endsWith('.png')) {
          await Gal.putImage(path, album: 'MyAppImages');
          _showToast(
              mess: "Lưu ảnh thành công",
              color: Theme.of(context).colorScheme.primary,
              icon: const Icon(
                Icons.check,
                color: Colors.white,
              ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File downloaded to $path')),
          );
          _showToast(
              mess: "Lưu file thành công",
              color: Theme.of(context).colorScheme.primary,
              icon: const Icon(
                Icons.check,
                color: Colors.white,
              ));
        }
      } else {
        _showToast(
            mess: "Lưu thất bại",
            color: Colors.red,
            icon: const Icon(
              Icons.cancel,
              color: Colors.white,
            ));
      }
    } catch (e) {
      _showToast(
          mess: "Lưu thất bại: $e",
          color: Colors.red,
          icon: const Icon(
            Icons.cancel,
            color: Colors.white,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.sh * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.white,
      ),
      padding: EdgeInsets.only(top: 15.w),
      child: Column(
        children: [
          MultiBlocListener(
              listeners: [
                BlocListener<DetailsTicketBloc, DetailsTicketState>(
                  listener: (context, state) {
                    if (state is DetailsTicketStateSuccess) {
                      detailsTicketModel = state.detailsTicketModel;
                      ticketMess = detailsTicketModel!.data.ticketMessages;
                    } else if (state is DetailsTicketStateFailure) {
                      showDialog(
                        context: navigatorKey.currentContext!,
                        builder: (BuildContext context) {
                          return ErrorDialog(
                            eventConfirm: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    } else if (state is SendMessTicketStateSuccess) {
                      ticketMess.add(TicketMessage(
                        ticketMessageContent:
                            state.resMessTicketModel.ticketMessageContent,
                        createdAt: state.resMessTicketModel.createdAt,
                      ));
                      _scrollToBottom();
                    }
                  },
                )
              ],
              child: BlocBuilder<DetailsTicketBloc, DetailsTicketState>(
                builder: (context, state) {
                  if (state is DetailsTicketStateLoading) {
                    return Center(
                      child: SizedBox(
                        width: 100.w,
                        height: 100.w,
                        child: Lottie.asset('assets/lottie/loading_kango.json'),
                      ),
                    );
                  } else if (state is DetailsTicketStateSuccess ||
                      ticketMess.isNotEmpty) {
                    return Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: ticketMess.length,
                        itemBuilder: (context, index) {
                          final message = ticketMess[index];
                          final isMine =
                              message.answerId == null ? true : false;
                          final isImage = message.ticketMessageContent
                                  .contains('jpg') ||
                              message.ticketMessageContent.contains('jpeg') ||
                              message.ticketMessageContent.contains('png');
                          final isFile = message.ticketMessageContent
                                  .contains('pdf') ||
                              message.ticketMessageContent.contains('doc') ||
                              message.ticketMessageContent.contains('docx') ||
                              message.ticketMessageContent.contains('xlsx');
                          return Align(
                            alignment: isMine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              padding: EdgeInsets.all(10.0),
                              decoration: isImage
                                  ? null
                                  : BoxDecoration(
                                      color: isMine
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.black,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                              child: Column(
                                crossAxisAlignment: isMine
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (isImage)
                                    Stack(
                                      children: [
                                        SizedBox(
                                          width: 250.w,
                                          height: 250.w,
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: httpImage +
                                                message.ticketMessageContent,
                                            placeholder: (context, url) =>
                                                SizedBox(
                                              height: 20.w,
                                              width: 20.w,
                                              child: const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 5,
                                          right: 5,
                                          child: IconButton(
                                            icon: const Icon(Icons.download,
                                                color: Colors.white),
                                            onPressed: () =>
                                                _downloadAndSaveFile(
                                              httpImage +
                                                  message.ticketMessageContent,
                                              path.basename(
                                                  message.ticketMessageContent),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  else if (isFile)
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.file_download),
                                          color: Colors.white70,
                                          onPressed: () => _downloadAndSaveFile(
                                            httpImage +
                                                message.ticketMessageContent,
                                            path.basename(
                                                message.ticketMessageContent),
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        SizedBox(
                                          width: 1.sw - 150.w,
                                          child: TextApp(
                                            text: path.basename(
                                                message.ticketMessageContent),
                                            color: Colors.white70,
                                            fontsize: 16.sp,
                                            isOverFlow: false,
                                            softWrap: true,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Text(
                                      message.ticketMessageContent,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  const SizedBox(height: 5.0),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else if (state is DetailsTicketStateFailure) {
                    return ErrorDialog(
                      eventConfirm: () {
                        Navigator.pop(context);
                      },
                      errorText: 'Failed to fetch orders: ${state.message}',
                    );
                  }
                  return TextApp(text: "Đang tải");
                },
              )),
          Padding(
            padding: EdgeInsets.all(25.h),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _sendImage,
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _sendFile,
                ),
                Expanded(
                  child: TextField(
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(
                      ticketID: widget.ticketID,
                      mess: _messageController.text,
                      path: null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
