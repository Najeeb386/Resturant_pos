import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class ThreeDStudioView extends StatefulWidget {
  const ThreeDStudioView({super.key});

  @override
  State<ThreeDStudioView> createState() => _ThreeDStudioViewState();
}

class _ThreeDStudioViewState extends State<ThreeDStudioView> {
  bool _is3DView = true;
  int? _selectedTableId;
  String _selectedShape = 'Round';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final tables = provider.tables;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate theme for 3D Studio
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Row(
          children: [
            Icon(Icons.view_in_ar, color: Colors.deepOrange),
            SizedBox(width: 8),
            Text('3D Floor Plan Studio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_is3DView ? Icons.grid_on : Icons.threed_rotation, color: Colors.deepOrange),
            tooltip: _is3DView ? 'Switch to 2D Grid' : 'Switch to 3D View',
            onPressed: () {
              setState(() {
                _is3DView = !_is3DView;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Sidebar Tools
          Container(
            width: 260,
            color: const Color(0xFF1E293B),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('STUDIO CONTROL', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 16),
                
                // View Switcher
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _is3DView = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _is3DView ? Colors.deepOrange : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('3D View', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _is3DView = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !_is3DView ? Colors.deepOrange : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('2D Grid', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text('TABLE PROPERTIES', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                
                DropdownButtonFormField<String>(
                  value: _selectedShape,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Table Shape',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: ['Round', 'Square', 'Rectangle'].map((shape) {
                    return DropdownMenuItem(value: shape, child: Text(shape));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedShape = val);
                  },
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dining Tables', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('${tables.length} Total Tables Placed', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main 3D / 2D Canvas
          Expanded(
            child: Container(
              color: const Color(0xFF020617),
              child: Stack(
                children: [
                  // Canvas Floor Grid
                  CustomPaint(
                    size: Size.infinite,
                    painter: GridPainter(is3D: _is3DView),
                  ),

                  // Table Render List
                  Center(
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: tables.map((t) => _buildTableWidget(t)).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableWidget(TableModel table) {
    bool isSelected = _selectedTableId == table.id;
    bool isOccupied = table.status == 'occupied';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTableId = table.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: isOccupied 
              ? Colors.red.withOpacity(0.2) 
              : isSelected 
                  ? Colors.deepOrange.withOpacity(0.3) 
                  : const Color(0xFF1E293B),
          shape: _selectedShape == 'Round' ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: _selectedShape == 'Round' ? null : BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.deepOrange : isOccupied ? Colors.red : Colors.blueGrey.shade700,
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? Colors.deepOrange.withOpacity(0.3) : Colors.black48,
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _is3DView ? Icons.view_in_ar : Icons.table_restaurant,
              color: isOccupied ? Colors.red : Colors.deepOrange,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              'Table ${table.tableNumber}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              '${table.capacity} Seats',
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final bool is3D;
  GridPainter({required this.is3D});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;

    double step = 40;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
