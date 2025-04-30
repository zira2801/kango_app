import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scan_barcode_app/bloc/notification/notification_bloc.dart';
import 'package:scan_barcode_app/bloc/shipment/create_new_shipment/create_new_shipment_bloc.dart';
import 'package:scan_barcode_app/bloc/transfer/transfer_bloc.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/transfer/transfer_model.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/html/take_picker_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/image/image_transfer_detail.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;

class TransferCreateScreen extends StatefulWidget {
  final Transfer? transfer;
  const TransferCreateScreen({super.key, this.transfer});

  @override
  State<TransferCreateScreen> createState() => _TransferCreateState();
}

class _TransferCreateState extends State<TransferCreateScreen> {
  final receiverController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final billController = TextEditingController();
  bool isImportant = false;
  final _formKey = GlobalKey<FormState>();
  bool isLoadingButton = false;
// Thêm biến flag ở đầu state class
  bool _dataInitialized = false;
  // Quill controller
  late quill.QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  List<File> selectedImages = [];
  List<TextEditingController> shipmentCodeControllers = [];

  @override
  void initState() {
    super.initState();

    final String defaultHtml =
        "<p><strong>Dịch vụ:</strong></p><p><strong>Tạo đơn nháp với lô hàng này(Có/Không): Không</strong></p><p>Mã tài khoản:</p><p>Tên người gửi:</p><p>Địa chỉ người gửi(Địa chỉ, Xã, Huyện, Tỉnh):</p><p>Số điện thoại người gửi:</p><p>Chi nhánh(HCM/HN/DN):</p><p><strong>Kiện hàng</strong></p><p>Số kiện:</p><p>Chiều dài:</p><p>Chiều rộng:</p><p>Chiều cao:</p><p>Số ký:</p><p><strong>Thông tin khác</strong></p><p>Tên hàng hóa:</p><p>Giá trị hàng hóa:</p><p>Thu khách:</p><p>Loại thanh toán(NỢ/SAU): SAU</p>";

    if (widget.transfer != null) {
      receiverController.text = widget.transfer!.receiverName ?? '';
      phoneController.text = widget.transfer!.receiverPhone ?? '';
      addressController.text = widget.transfer!.receiverAddress ?? '';

      _quillController = quill.QuillController(
        document: htmlToDelta(widget.transfer!.transferContent ?? defaultHtml),
        selection: const TextSelection.collapsed(offset: 0),
      );
      // Load mã shipment từ transferShipments
      shipmentCodeControllers.clear();
      if (widget.transfer!.transferShipments != null) {
        for (var shipment in widget.transfer!.transferShipments!) {
          final controller =
              TextEditingController(text: shipment.shipmentCode.toString());
          shipmentCodeControllers.add(controller);
        }
      }

      // Tải ảnh bất đồng bộ
      _loadImagesAsync();
    } else {
      _quillController = quill.QuillController(
        document: htmlToDelta(defaultHtml),
        selection: const TextSelection.collapsed(offset: 0),
      );
      shipmentCodeControllers.add(TextEditingController());
    }

    _quillController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadImagesAsync() async {
    if (widget.transfer != null &&
        widget.transfer!.transferImages != null &&
        widget.transfer!.transferImages!.isNotEmpty) {
      try {
        final decoded = jsonDecode(widget.transfer!.transferImages!);
        log("Decoded transferImages: $decoded");

        if (decoded is List<dynamic>) {
          final imageFutures = decoded.map((value) async {
            if (value is String) {
              if (value.startsWith('data:image')) {
                final base64Data = value.split(',').last;
                final bytes = base64Decode(base64Data);
                final tempFile = File(
                    '${Directory.systemTemp.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
                await tempFile.writeAsBytes(bytes);
                return tempFile;
              } else {
                final fullUrl = value.startsWith('http')
                    ? value
                    : '$httpImage$value'; // Thay bằng base URL thực tế
                return await _loadImageFromUrl(fullUrl);
              }
            }
            return null;
          }).toList();

          final loadedImages = await Future.wait(imageFutures);
          setState(() {
            selectedImages = loadedImages
                .where((file) => file != null)
                .cast<File>()
                .toList();
            log("Loaded images count: ${selectedImages.length}");
          });
        } else if (decoded is Map<String, dynamic>) {
          final imageFutures = decoded.entries.map((entry) async {
            final value = entry.value;
            if (value is String && value.startsWith('data:image')) {
              final base64Data = value.split(',').last;
              final bytes = base64Decode(base64Data);
              final tempFile = File(
                  '${Directory.systemTemp.path}/temp_image_${entry.key}.jpg');
              await tempFile.writeAsBytes(bytes);
              return tempFile;
            }
            return null;
          }).toList();

          final loadedImages = await Future.wait(imageFutures);
          setState(() {
            selectedImages = loadedImages
                .where((file) => file != null)
                .cast<File>()
                .toList();
            log("Loaded images count: ${selectedImages.length}");
          });
        }
      } catch (e) {
        log("Error loading images: $e");
      }
    }
  }

  Future<File> _loadImageFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final tempDir = Directory.systemTemp;
        final tempFile = File(
            '${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(response.bodyBytes);
        return tempFile;
      } else {
        log("Failed to load image from URL: $url, status: ${response.statusCode}");
        throw Exception("Failed to load image");
      }
    } catch (e) {
      log("Error loading image from URL: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _editorFocusNode.dispose();
    _quillController.dispose();
    receiverController.dispose();
    phoneController.dispose();
    addressController.dispose();
    billController.dispose();
    for (var controller in shipmentCodeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    BlocProvider.of<GetListTransferBloc>(context).add(const FetchListTransfer(
        startDate: null, endDate: null, keywords: null));
  }

// Hàm chọn ảnh
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source:
            ImageSource.gallery); // Hoặc ImageSource.camera nếu muốn từ camera

    if (pickedFile != null) {
      setState(() {
        selectedImages.add(File(pickedFile.path));
      });
    }
  }

// Hàm xóa ảnh
  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

// Hàm thêm ô nhập mã shipment mới
  Future<void> _addShipmentCodeField() async {
    setState(() {
      shipmentCodeControllers.add(TextEditingController());
    });
  }

// Hàm xóa ô nhập mã shipment
  void _removeShipmentCodeField(int index) {
    setState(() {
      shipmentCodeControllers.removeAt(index); // Chỉ xóa khỏi danh sách
    });
  }

  String deltaToHtml(Delta delta) {
    final htmlBuffer = StringBuffer();
    final operations = delta.toList();

    // Biến để theo dõi trạng thái danh sách và đoạn văn
    bool inOrderedList = false;
    bool inUnorderedList = false;
    StringBuffer currentParagraph = StringBuffer();
    bool paragraphStarted = false;

    for (int i = 0; i < operations.length; i++) {
      final op = operations[i];
      if (op.data is String) {
        String text = op.data as String;
        final attributes = op.attributes;

        // Xử lý các định dạng inline
        if (attributes != null) {
          if (attributes.containsKey('bold') && attributes['bold'] == true) {
            text = '<b>$text</b>';
          }
          if (attributes.containsKey('italic') &&
              attributes['italic'] == true) {
            text = '<i>$text</i>';
          }
          if (attributes.containsKey('underline') &&
              attributes['underline'] == true) {
            text = '<u>$text</u>';
          }
          if (attributes.containsKey('strike') &&
              attributes['strike'] == true) {
            text = '<s>$text</s>';
          }
          if (attributes.containsKey('link')) {
            text = '<a href="${attributes['link']}">$text</a>';
          }
          if (attributes.containsKey('code') && attributes['code'] == true) {
            text = '<code>$text</code>';
          }
        }

        // Xử lý các định dạng block
        if (attributes != null && attributes.containsKey('header')) {
          final level = attributes['header'];
          if (currentParagraph.isNotEmpty) {
            htmlBuffer.write('<p>${currentParagraph.toString()}</p>');
            currentParagraph.clear();
            paragraphStarted = false;
          }
          htmlBuffer.write('<h$level>${text.replaceAll('\n', '')}</h$level>');
        } else if (attributes != null &&
            attributes.containsKey('blockquote') &&
            attributes['blockquote'] == true) {
          if (currentParagraph.isNotEmpty) {
            htmlBuffer.write('<p>${currentParagraph.toString()}</p>');
            currentParagraph.clear();
            paragraphStarted = false;
          }
          htmlBuffer
              .write('<blockquote>${text.replaceAll('\n', '')}</blockquote>');
        } else if (attributes != null &&
            attributes.containsKey('code-block') &&
            attributes['code-block'] == true) {
          if (currentParagraph.isNotEmpty) {
            htmlBuffer.write('<p>${currentParagraph.toString()}</p>');
            currentParagraph.clear();
            paragraphStarted = false;
          }
          htmlBuffer
              .write('<pre><code>${text.replaceAll('\n', '')}</code></pre>');
        } else if (attributes != null && attributes.containsKey('list')) {
          final listType = attributes['list'];
          if (listType == 'ordered') {
            if (!inOrderedList) {
              if (currentParagraph.isNotEmpty) {
                htmlBuffer.write('<p>${currentParagraph.toString()}</p>');
                currentParagraph.clear();
                paragraphStarted = false;
              }
              htmlBuffer.write('<ol>');
              inOrderedList = true;
            }
            if (inUnorderedList) {
              htmlBuffer.write('</ul>');
              inUnorderedList = false;
            }
            htmlBuffer.write('<li>${text.replaceAll('\n', '')}</li>');
          } else if (listType == 'bullet') {
            if (!inUnorderedList) {
              if (currentParagraph.isNotEmpty) {
                htmlBuffer.write('<p>${currentParagraph.toString()}</p>');
                currentParagraph.clear();
                paragraphStarted = false;
              }
              htmlBuffer.write('<ul>');
              inUnorderedList = true;
            }
            if (inOrderedList) {
              htmlBuffer.write('</ol>');
              inOrderedList = false;
            }
            htmlBuffer.write('<li>${text.replaceAll('\n', '')}</li>');
          }
        } else {
          // Xử lý văn bản thô (có hoặc không có attributes inline)
          if (!paragraphStarted) {
            htmlBuffer.write('<p>');
            paragraphStarted = true;
          }
          if (text.contains('\n')) {
            final lines = text.split('\n');
            for (int j = 0; j < lines.length; j++) {
              if (lines[j].isNotEmpty) {
                currentParagraph.write(lines[j]);
                if (j < lines.length - 1) {
                  currentParagraph.write('<br>'); // Thêm <br> giữa các dòng
                }
              }
            }
          } else {
            currentParagraph.write(text);
          }
        }

        // Đóng danh sách hoặc đoạn văn nếu cần
        if (i < operations.length - 1) {
          final nextOp = operations[i + 1];
          final nextAttributes = nextOp.attributes;
          if (inOrderedList &&
              (nextAttributes == null ||
                  !nextAttributes.containsKey('list') ||
                  nextAttributes['list'] != 'ordered')) {
            htmlBuffer.write('</ol>');
            inOrderedList = false;
          }
          if (inUnorderedList &&
              (nextAttributes == null ||
                  !nextAttributes.containsKey('list') ||
                  nextAttributes['list'] != 'bullet')) {
            htmlBuffer.write('</ul>');
            inUnorderedList = false;
          }
          // Đóng <p> nếu gặp block tiếp theo
          if (paragraphStarted &&
              nextAttributes != null &&
              (nextAttributes.containsKey('header') ||
                  nextAttributes.containsKey('blockquote') ||
                  nextAttributes.containsKey('code-block') ||
                  nextAttributes.containsKey('list'))) {
            htmlBuffer.write('${currentParagraph.toString()}</p>');
            currentParagraph.clear();
            paragraphStarted = false;
          }
        } else {
          if (paragraphStarted && currentParagraph.isNotEmpty) {
            htmlBuffer.write(currentParagraph.toString());
            htmlBuffer.write('</p>');
            currentParagraph.clear();
            paragraphStarted = false;
          }
          if (inOrderedList) {
            htmlBuffer.write('</ol>');
            inOrderedList = false;
          }
          if (inUnorderedList) {
            htmlBuffer.write('</ul>');
            inUnorderedList = false;
          }
        }
      }
    }

    return htmlBuffer.toString();
  }

// Trong _submitNotification
  void _submitTransfer() {
    log('QuillController Delta: ${_quillController.document.toDelta().toString()}');
    final contentText = _quillController.document.toPlainText().trim();
    if (contentText.isEmpty) {
      _showCustomNotification('Nội dung không được để trống');
      return;
    }

    if (selectedImages.isEmpty) {
      _showCustomNotification('Vui lòng chọn ít nhất một ảnh');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final contentDelta = _quillController.document.toDelta();
    final contentHtml = deltaToHtml(contentDelta);

    // Tạo Map cho transferImages
    Map<String, String> transferImages = {};
    for (int i = 0; i < selectedImages.length; i++) {
      final bytes = selectedImages[i].readAsBytesSync();
      final base64String = base64Encode(bytes);
      transferImages[i.toString()] = "data:image/jpeg;base64,$base64String";
    }

    // Tạo Map cho transferShipmentCodes
    Map<String, Map<String, String>> transferShipmentCodes = {};
    for (int i = 0; i < shipmentCodeControllers.length; i++) {
      final code = shipmentCodeControllers[i].text.trim();
      if (code.isNotEmpty) {
        transferShipmentCodes[i.toString()] = {"shipment_code": code};
      }
    }

    log("Images: ${transferImages.length} items");
    log("Shipment Codes: ${transferShipmentCodes.length} items");

    setState(() {
      isLoadingButton = true;
    });

    BlocProvider.of<CreateTransferBloc>(context).add(
      HandleCreateTransfer(
        transferID: widget.transfer?.transferId,
        transferContent: contentHtml,
        transferImages: transferImages, // Map<String, String>
        receiverName: receiverController.text,
        receiverPhone: phoneController.text,
        receiverAddress: addressController.text,
        transferShipmentCodes:
            transferShipmentCodes, // Map<String, Map<String, String>>
      ),
    );
  }

  void _showCustomNotification(String message) {
    const duration = Duration(seconds: 3);
    late OverlayEntry overlayEntry;
    bool isDismissed = false;

    // Animation controller
    final animationController = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 300),
    );

    // Animation slide từ trên xuống
    final animation = Tween<Offset>(
      begin: const Offset(0, -1), // Từ trên (ngoài màn hình)
      end: const Offset(0, 0), // Đến vị trí hiển thị
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    // Overlay entry
    overlayEntry = OverlayEntry(
      builder: (context) => SlideTransition(
        position: animation,
        child: SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(top: 16.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Chèn overlay vào giao diện
    Overlay.of(context).insert(overlayEntry);

    // Bắt đầu animation
    animationController.forward();

    // Tự động đóng sau 3 giây
    Future.delayed(duration, () {
      if (!isDismissed) {
        animationController.reverse().then((_) {
          overlayEntry.remove();
          animationController.dispose();
        });
      }
    });
  }

  quill.Document htmlToDelta(String html) {
    final document = quill.Document();
    final delta = Delta();

    final parsed = html_parser.parse(html);
    final body = parsed.body;

    if (body == null) {
      print('HTML body is null');
      return document;
    }

    void processNode(html_dom.Node node, Map<String, dynamic> attributes) {
      if (node is html_dom.Element) {
        Map<String, dynamic> newAttributes = Map.from(attributes);

        switch (node.localName) {
          case 'b':
          case 'strong':
            newAttributes['bold'] = true;
            break;
          case 'i':
          case 'em':
            newAttributes['italic'] = true;
            break;
          case 'u':
            newAttributes['underline'] = true;
            break;
          case 's':
          case 'strike':
            newAttributes['strike'] = true;
            break;
          case 'font':
            if (node.attributes.containsKey('face')) {
              newAttributes['font'] = node.attributes['face'];
            }
            if (node.attributes.containsKey('size')) {
              newAttributes['size'] =
                  _convertFontSize(node.attributes['size']!);
            }
            if (node.attributes.containsKey('color')) {
              final normalizedColor =
                  _normalizeColor(node.attributes['color']!);
              if (normalizedColor != null) {
                newAttributes['color'] = normalizedColor;
              }
            }
            break;
          case 'span':
            if (node.attributes.containsKey('style')) {
              newAttributes.addAll(_parseStyle(node.attributes['style']!));
            }
            break;
          case 'img':
            final src = node.attributes['src'];
            if (src != null && src.isNotEmpty) {
              delta.insert({'image': src});
              if (delta.isNotEmpty) {
                delta.insert('\n');
              }
            }
            return;
          case 'br':
            delta.insert('\n', attributes.isNotEmpty ? attributes : null);
            return; // Thoát sau khi xử lý <br>
        }

        if (node.localName == 'p' ||
            node.localName == 'div' ||
            node.localName == 'h1' ||
            node.localName == 'h2' ||
            node.localName == 'h3' ||
            node.localName == 'h4' ||
            node.localName == 'h5' ||
            node.localName == 'h6') {
          if (node.localName!.startsWith('h')) {
            newAttributes['header'] = int.parse(node.localName!.substring(1));
          }
          for (var child in node.nodes) {
            processNode(child, newAttributes);
          }
          if (delta.isNotEmpty) {
            delta.insert('\n', newAttributes.isNotEmpty ? newAttributes : null);
          }
        } else {
          for (var child in node.nodes) {
            processNode(child, newAttributes);
          }
        }
      } else if (node is html_dom.Text) {
        final text = node.text.trim();
        if (text.isNotEmpty) {
          delta.insert(text, attributes.isNotEmpty ? attributes : null);
        }
      }
    }

    for (var node in body.nodes) {
      processNode(node, {});
    }

    print('Generated Delta: ${delta.toJson()}');
    try {
      document.compose(delta, quill.ChangeSource.local);
    } catch (e) {
      print('Error composing Delta: $e');
    }
    return document;
  }

// Chuẩn hóa mã màu cho Quill
  String? _normalizeColor(String color) {
    color = color.trim().toLowerCase();
    const supportedColors = {
      'black',
      'white',
      'red',
      'green',
      'blue',
      'yellow',
      'cyan',
      'magenta',
      'gray',
      'grey',
      'purple',
      'orange',
      'brown',
      'pink'
    };
    if (supportedColors.contains(color)) return color;
    if (color.startsWith('#')) {
      if (color.length == 4) {
        return '#${color[1]}${color[1]}${color[2]}${color[2]}${color[3]}${color[3]}';
      }
      if (color.length == 7 || color.length == 9) return color;
    }
    print('Unsupported color code: $color');
    return null;
  }

// Chuyển đổi kích thước font HTML sang Quill size
  String _convertFontSize(String htmlSize) {
    switch (htmlSize) {
      case '1':
        return 'small';
      case '2':
      case '3':
        return 'normal';
      case '4':
      case '5':
        return 'large';
      case '6':
      case '7':
        return 'huge';
      default:
        if (htmlSize.endsWith('px')) {
          final size = int.tryParse(htmlSize.replaceAll('px', ''));
          if (size != null) {
            if (size <= 12) return 'small';
            if (size <= 16) return 'normal';
            if (size <= 24) return 'large';
            return 'huge';
          }
        }
        return 'normal';
    }
  }

// Parse thuộc tính style của span
  Map<String, dynamic> _parseStyle(String style) {
    final attributes = <String, dynamic>{};
    final properties = style.split(';');
    for (var prop in properties) {
      final parts = prop.split(':');
      if (parts.length == 2) {
        final key = parts[0].trim();
        final value = parts[1].trim();
        switch (key) {
          case 'font-family':
            attributes['font'] = value;
            break;
          case 'font-size':
            attributes['size'] = _convertFontSize(value);
            break;
          case 'color':
            final normalizedColor = _normalizeColor(value);
            if (normalizedColor != null) {
              attributes['color'] = normalizedColor;
            }
            break;
          case 'background-color':
            final normalizedColor = _normalizeColor(value);
            if (normalizedColor != null) {
              attributes['background'] = normalizedColor;
            }
            break;
          case 'text-decoration':
            if (value.contains('underline')) attributes['underline'] = true;
            if (value.contains('line-through')) attributes['strike'] = true;
            break;
        }
      }
    }
    return attributes;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetailsNotificationBloc()
        ..add(HandleDetailNotification(notificaionID: 857)),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: TextApp(
            text: widget.transfer != null
                ? 'Cập nhật khai hàng'
                : 'Thêm khai hàng',
            fontsize: 20.w,
            fontWeight: FontWeight.w800,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<CreateTransferBloc, CreateTransfertState>(
              listener: (context, state) async {
                if (state is CreateTransfertStateSuccess) {
                  await _fetchInitialData();
                  if (mounted) {
                    setState(() {
                      isLoadingButton = false;
                    });
                  }
                  showCustomDialogModal(
                    context: context,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {
                      Navigator.pop(context); // Close dialog
                    },
                    isTwoButton: false,
                  );
                } else if (state is CreateTransfertStateFailure) {
                  if (mounted) {
                    setState(() {
                      isLoadingButton = false;
                    });
                  }
                  showCustomDialogModal(
                    context: context,
                    textDesc: state.message ?? "Đã có lỗi xảy ra",
                    title: "Thông báo",
                    colorButtonOk: Colors.red,
                    btnOKText: "Xác nhận",
                    typeDialog: "error",
                    eventButtonOKPress: () {},
                    isTwoButton: false,
                  );
                }
              },
            ),
            BlocListener<UpdateNotificationBloc, UpdateNotificationtState>(
              listener: (context, state) async {
                if (state is UpdateNotificationtStateSuccess) {
                  await _fetchInitialData();
                  if (mounted) {
                    setState(() {
                      isLoadingButton = false;
                    });
                  }
                  showCustomDialogModal(
                    context: context,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {
                      Navigator.pop(context); // Close dialog
                    },
                    isTwoButton: false,
                  );
                } else if (state is UpdateNotificationStateFailure) {
                  if (mounted) {
                    setState(() {
                      isLoadingButton = false;
                    });
                  }
                  showCustomDialogModal(
                    context: context,
                    textDesc: state.message ?? "Đã có lỗi xảy ra",
                    title: "Thông báo",
                    colorButtonOk: Colors.red,
                    btnOKText: "Xác nhận",
                    typeDialog: "error",
                    eventButtonOKPress: () {},
                    isTwoButton: false,
                  );
                }
              },
            ),
          ],
          child:
              BlocBuilder<DetailsNotificationBloc, GetDetailsNotificationState>(
            builder: (BuildContext context, state) {
              if (state is HandleGetDetailsNotificationSuccess &&
                  !_dataInitialized) {
                if (857 != null) {
                  // titleController.text = state.data.notificationTitle;
                  isImportant = state.data.notificationImportant == 1;
                  _quillController = quill.QuillController(
                    document: htmlToDelta(state.data.notificationContent),
                    selection: const TextSelection.collapsed(offset: 0),
                  );
                  // Set the flag to true to prevent re-initialization
                  _dataInitialized = true;
                }
              }
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            TextApp(
                              text: 'Hình ảnh',
                              fontsize: 16.w,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              '*',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: [
                            ...[
                              ...selectedImages.asMap().entries.map((entry) {
                                int index = entry.key;
                                File image = entry.value;
                                String heroTag = 'image_$index';
                                return Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ImageDetailScreen(
                                              imageFile: image,
                                              heroTag: heroTag,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Hero(
                                        tag: heroTag,
                                        child: Container(
                                          width: 150.w,
                                          height: 150.h,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                            child: Image.file(
                                              image,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                log("Error loading image at index $index: $error");
                                                return Container(
                                                  color: Colors.grey.shade200,
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      size: 40.w,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            size: 20.w,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                              if (selectedImages.isEmpty)
                                Container(
                                  width: 150.w,
                                  height: 150.h,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Không có ảnh',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 16.sp),
                                    ),
                                  ),
                                ),
                              GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 80.w,
                                  height: 80.h,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.add_photo_alternate,
                                    size: 40.w,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 20.h),
                        // Title field
                        Row(
                          children: [
                            TextApp(
                              text: 'Tên người nhận',
                              fontsize: 16.w,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        CustomTextFormField(
                          controller: receiverController,
                          hintText: '',
                        ),

                        SizedBox(height: 20.h),

                        Row(
                          children: [
                            TextApp(
                              text: 'Số điện thoại',
                              fontsize: 16.w,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        CustomTextFormField(
                          controller: phoneController,
                          hintText: '',
                        ),
                        SizedBox(height: 20.h),

                        Row(
                          children: [
                            Container(
                              height: 50,
                              width: 330,
                              child: TextApp(
                                text:
                                    'Địa chỉ (Địa chỉ 1, City name, State code, Postcode, Country code)',
                                fontsize: 16.w,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        CustomTextFormField(
                          controller: addressController,
                          hintText: '',
                        ),

                        SizedBox(height: 20.h),

                        // Content field using Quill
                        Row(
                          children: [
                            Text(
                              'Thông tin khai',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              '*',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(
                            children: [
                              // Quill Toolbar
                              quill.QuillSimpleToolbar(
                                controller: _quillController,
                                config: quill.QuillSimpleToolbarConfig(
                                  embedButtons: const [],
                                  showClipboardPaste: true,
                                  showFontSize: true,
                                  showFontFamily: true,
                                  showCodeBlock: true,
                                  showInlineCode: true,
                                  showSearchButton: true,
                                  showSubscript: true,
                                  showSuperscript: true,
                                  showListCheck: true,
                                  showQuote: true,
                                  showIndent: true,
                                  showClearFormat: true,
                                  showDividers: true,
                                  showHeaderStyle: true,
                                  showLink: true,
                                  showUndo: true,
                                  showRedo: true,
                                  showBoldButton: true,
                                  showItalicButton: true,
                                  showUnderLineButton: true,
                                  showStrikeThrough: true,
                                  showColorButton: true,
                                  showAlignmentButtons: true,
                                  showBackgroundColorButton: true,
                                  showCenterAlignment: true,
                                  showClipboardCopy: true,
                                  showClipboardCut: true,
                                  showLeftAlignment: true,
                                  showDirection: true,
                                  showJustifyAlignment: true,
                                  showLineHeightButton: true,
                                  showListBullets: true,
                                  showListNumbers: true,
                                  showRightAlignment: true,
                                  showSmallButton: true,
                                  multiRowsDisplay: true,
                                  buttonOptions:
                                      quill.QuillSimpleToolbarButtonOptions(
                                    base: quill.QuillToolbarBaseButtonOptions(
                                      afterButtonPressed: () async {
                                        _editorFocusNode.requestFocus();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Divider(height: 1, color: Colors.grey.shade300),
                              // Quill Editor
                              Container(
                                height: 500.h,
                                padding: EdgeInsets.all(12.w),
                                child: DefaultTextStyle(
                                  style: TextStyle(
                                      fontSize: 5.w, color: Colors.black),
                                  child: quill.QuillEditor(
                                    focusNode: _editorFocusNode,
                                    controller: _quillController,
                                    config: quill.QuillEditorConfig(
                                      embedBuilders: [ImageEmbedBuilder()],
                                      padding: EdgeInsets.zero,
                                    ),
                                    scrollController: ScrollController(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            TextApp(
                              text: 'Mã bill',
                              fontsize: 16.w,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        // Danh sách các ô nhập mã shipment
                        ...shipmentCodeControllers.asMap().entries.map((entry) {
                          int index = entry.key;
                          TextEditingController controller = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: Row(
                              children: [
                                Expanded(
                                  child: CustomTextFormField(
                                    controller: controller,
                                    hintText: 'Nhập shipment code',
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                GestureDetector(
                                  onTap: () => _removeShipmentCodeField(index),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 35.w,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        // Nút thêm mã shipment mới
                        GestureDetector(
                          onTap: () async {
                            await _addShipmentCodeField();
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 50.w,
                              height: 50.h,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 24.w,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),

                        // Submit button
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    isLoadingButton ? null : _submitTransfer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: isLoadingButton
                                    ? SizedBox(
                                        height: 20.h,
                                        width: 20.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : TextApp(
                                        text: widget.transfer != null
                                            ? 'Cập nhật'
                                            : 'Xác nhận',
                                        fontsize: 16.w,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ImageEmbedBuilder implements quill.EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(BuildContext context, quill.EmbedContext embedContext) {
    // Truy cập dữ liệu embed từ embedContext.node
    final embed = embedContext.node.value.data;
    final data = embed.toString();
    // Kiểm tra nếu là base64
    if (data.startsWith('data:image')) {
      final base64String = data.split(',').last;
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Text('[Image failed to load]');
        },
      );
    }

    // Nếu là URL
    return Image.network(
      data,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Text('[Image failed to load]');
      },
    );
  }

  @override
  WidgetSpan buildWidgetSpan(Widget widget) {
    return WidgetSpan(child: widget);
  }

  @override
  bool get expanded => false;

  @override
  String toPlainText(quill.Embed embed) => '[Image]';
}
