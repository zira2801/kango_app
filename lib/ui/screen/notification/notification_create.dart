import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:scan_barcode_app/bloc/notification/notification_bloc.dart';
import 'package:scan_barcode_app/bloc/shipment/create_new_shipment/create_new_shipment_bloc.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/html/take_picker_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;

class NotificationCreate extends StatefulWidget {
  final notificationId;
  const NotificationCreate({super.key, required this.notificationId});

  @override
  State<NotificationCreate> createState() => _NotificationCreateState();
}

class _NotificationCreateState extends State<NotificationCreate> {
  final titleController = TextEditingController();
  bool isImportant = false;
  final _formKey = GlobalKey<FormState>();
  bool isLoadingButton = false;
// Thêm biến flag ở đầu state class
  bool _dataInitialized = false;
  // Quill controller
  late quill.QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();

    // Add this handler to ensure state is properly updated
    _quillController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _editorFocusNode.dispose();
    _quillController.dispose();
    titleController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    BlocProvider.of<NotificationBloc>(context)
        .add(const FetchListNotification());
  }

  String deltaToHtml(Delta delta) {
    final htmlBuffer = StringBuffer();
    final operations = delta.toList();

    // Biến để theo dõi trạng thái danh sách
    bool inOrderedList = false;
    bool inUnorderedList = false;
    StringBuffer currentParagraph =
        StringBuffer(); // Lưu nội dung của đoạn hiện tại

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
        if (attributes != null) {
          if (attributes.containsKey('header')) {
            final level = attributes['header'];
            if (currentParagraph.isNotEmpty) {
              htmlBuffer.write('<p>${currentParagraph.toString()}</p>');
              currentParagraph.clear();
            }
            htmlBuffer.write('<h$level>${text.replaceAll('\n', '')}</h$level>');
          } else if (attributes.containsKey('blockquote') &&
              attributes['blockquote'] == true) {
            if (currentParagraph.isNotEmpty) {
              htmlBuffer.write('<p>${currentParagraph.toString()}</p>');
              currentParagraph.clear();
            }
            htmlBuffer
                .write('<blockquote>${text.replaceAll('\n', '')}</blockquote>');
          } else if (attributes.containsKey('code-block') &&
              attributes['code-block'] == true) {
            if (currentParagraph.isNotEmpty) {
              htmlBuffer.write('<p>${currentParagraph.toString()}</p>');
              currentParagraph.clear();
            }
            htmlBuffer
                .write('<pre><code>${text.replaceAll('\n', '')}</code></pre>');
          } else if (attributes.containsKey('list')) {
            final listType = attributes['list'];
            if (listType == 'ordered') {
              if (!inOrderedList) {
                if (currentParagraph.isNotEmpty) {
                  htmlBuffer.write('<p>${currentParagraph.toString()}</p>');
                  currentParagraph.clear();
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
            // Nếu không có định dạng block đặc biệt, xử lý đoạn văn
            if (text.contains('\n')) {
              final lines = text.split('\n');
              for (int j = 0; j < lines.length; j++) {
                if (lines[j].isNotEmpty) {
                  currentParagraph.write(lines[j]);
                }
                if (j < lines.length - 1 ||
                    (j == lines.length - 1 && lines[j].isEmpty)) {
                  if (currentParagraph.isNotEmpty) {
                    htmlBuffer.write('<p>${currentParagraph.toString()}</p>');
                    currentParagraph.clear();
                  }
                }
              }
            } else {
              currentParagraph.write(text);
            }
          }
        } else {
          // Không có attributes, xử lý đoạn văn với xuống dòng
          if (text.contains('\n')) {
            final lines = text.split('\n');
            for (int j = 0; j < lines.length; j++) {
              if (lines[j].isNotEmpty) {
                currentParagraph.write(lines[j]);
              }
              if (j < lines.length - 1 ||
                  (j == lines.length - 1 && lines[j].isEmpty)) {
                if (currentParagraph.isNotEmpty) {
                  htmlBuffer.write('<p>${currentParagraph.toString()}</p>');
                  currentParagraph.clear();
                }
              }
            }
          } else {
            currentParagraph.write(text);
          }
        }

        // Đóng danh sách nếu cần
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
        } else {
          if (currentParagraph.isNotEmpty) {
            htmlBuffer.write('<p>${currentParagraph.toString()}</p>');
            currentParagraph.clear();
          }
          if (inOrderedList) {
            htmlBuffer.write('</ol>');
          }
          if (inUnorderedList) {
            htmlBuffer.write('</ul>');
          }
        }
      }
    }

    return htmlBuffer.toString();
  }

  void _submitNotification() {
    if (_formKey.currentState!.validate()) {
      final contentDelta = _quillController.document.toDelta();
      final contentText = _quillController.document.toPlainText();

      if (contentText.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nội dung không được để trống')),
        );
        return;
      }

      final contentHtml = deltaToHtml(contentDelta);
      log(contentHtml); // Kiểm tra đầu ra HTML

      setState(() {
        isLoadingButton = true;
      });

      if (widget.notificationId != null) {
        BlocProvider.of<UpdateNotificationBloc>(context).add(
          HandleUpdateNotification(
            notificationID: widget.notificationId,
            notificationTitle: titleController.text,
            notificationContent: contentHtml,
            notificationImportant: isImportant,
          ),
        );
      } else {
        BlocProvider.of<CreateNotificationBloc>(context).add(
          HandleCreateNotification(
            notificationTitle: titleController.text,
            notificationContent: contentHtml,
            notificationImportant: isImportant,
          ),
        );
      }
    }
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
        ..add(HandleDetailNotification(notificaionID: widget.notificationId)),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: TextApp(
            text: widget.notificationId != null
                ? 'Cập nhật thông báo'
                : 'Tạo thông báo',
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
            BlocListener<CreateNotificationBloc, CreateNotificationtState>(
              listener: (context, state) async {
                if (state is CreateNotificationStateSuccess) {
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
                } else if (state is CreateNotificationStateFailure) {
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
                if (widget.notificationId != null) {
                  titleController.text = state.data.notificationTitle;
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
                        // Title field
                        Row(
                          children: [
                            TextApp(
                              text: 'Tiêu đề',
                              fontsize: 16.w,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            SizedBox(width: 5.w),
                            TextApp(
                              text: '*',
                              fontsize: 16.w,
                              color: Colors.red,
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        CustomTextFormField(
                          controller: titleController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Không được để trống";
                            }
                            return null;
                          },
                          hintText: 'Nhập tiêu đề',
                        ),

                        SizedBox(height: 20.h),

                        // Important switch
                        Row(
                          children: [
                            TextApp(
                              text: 'Thông báo quan trọng',
                              fontsize: 16.w,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            CupertinoSwitch(
                              value: isImportant,
                              onChanged: (value) {
                                setState(() {
                                  isImportant = value;
                                });

                                int importantValue =
                                    value ? 1 : 0; // 1 nếu bật, 0 nếu tắt
                                print(
                                    "Giá trị quan trọng: $importantValue"); // In ra console để kiểm tra
                              },
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                            )
                          ],
                        ),

                        SizedBox(height: 20.h),

                        // Content field using Quill
                        Row(
                          children: [
                            Text(
                              'Nội dung',
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
                                      fontSize: 13.w, color: Colors.black),
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

                        SizedBox(height: 30.h),

                        // Submit button
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isLoadingButton
                                    ? null
                                    : _submitNotification,
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
                                        text: widget.notificationId != null
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
