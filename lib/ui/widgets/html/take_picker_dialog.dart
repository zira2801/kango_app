import 'package:flutter/material.dart';

class TablePickerDialog extends StatefulWidget {
  final Function(int rows, int cols) onTableSelected;

  const TablePickerDialog({required this.onTableSelected});

  @override
  _TablePickerDialogState createState() => _TablePickerDialogState();
}

class _TablePickerDialogState extends State<TablePickerDialog> {
  int hoveredRows = 0;
  int hoveredCols = 0;
  static const int maxRows = 10; // Số hàng tối đa trong lưới
  static const int maxCols = 10; // Số cột tối đa trong lưới

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Insert Table'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTableGrid(),
          const SizedBox(height: 10),
          Text('$hoveredRows x $hoveredCols'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: hoveredRows > 0 && hoveredCols > 0
              ? () {
                  widget.onTableSelected(hoveredRows, hoveredCols);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Insert'),
        ),
      ],
    );
  }

  Widget _buildTableGrid() {
    return Container(
      width: 200,
      height: 200,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: maxCols,
          childAspectRatio: 1,
        ),
        itemCount: maxRows * maxCols,
        itemBuilder: (context, index) {
          int row = index ~/ maxCols;
          int col = index % maxCols;
          bool isHighlighted = row < hoveredRows && col < hoveredCols;

          return MouseRegion(
            onEnter: (_) {
              setState(() {
                hoveredRows = row + 1;
                hoveredCols = col + 1;
              });
            },
            child: GestureDetector(
              onTap: () {
                setState(() {
                  hoveredRows = row + 1;
                  hoveredCols = col + 1;
                });
                widget.onTableSelected(hoveredRows, hoveredCols);
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: isHighlighted ? Colors.blue.withOpacity(0.3) : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
