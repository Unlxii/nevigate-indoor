import 'package:flutter/material.dart';

void main() {
  runApp(const SimpleIndoorNavApp());
}

class SimpleIndoorNavApp extends StatelessWidget {
  const SimpleIndoorNavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indoor Navigation Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SimpleSplashScreen(),
    );
  }
}

class SimpleSplashScreen extends StatefulWidget {
  const SimpleSplashScreen({super.key});

  @override
  State<SimpleSplashScreen> createState() => _SimpleSplashScreenState();
}

class _SimpleSplashScreenState extends State<SimpleSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SimpleLoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade700, Colors.blue.shade900],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 80, color: Colors.white),
              SizedBox(height: 24),
              Text(
                'Indoor Navigation',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'UWB Positioning System',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class SimpleLoginScreen extends StatelessWidget {
  const SimpleLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline, size: 64, color: Colors.blue),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const SimpleMapScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Sign In', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleMapScreen extends StatefulWidget {
  const SimpleMapScreen({super.key});

  @override
  State<SimpleMapScreen> createState() => _SimpleMapScreenState();
}

class _SimpleMapScreenState extends State<SimpleMapScreen> {
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset _startFocalPoint = Offset.zero;
  Offset _lastOffset = Offset.zero;

  final List<Room> _rooms = [
    Room('Room 101', const Offset(50, 50), const Size(150, 100), Colors.blue.shade100),
    Room('Room 102', const Offset(220, 50), const Size(150, 100), Colors.green.shade100),
    Room('Room 201', const Offset(50, 180), const Size(150, 100), Colors.orange.shade100),
    Room('Room 202', const Offset(220, 180), const Size(150, 100), Colors.purple.shade100),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indoor Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: RoomSearchDelegate(_rooms));
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              setState(() {
                _scale = 1.0;
                _offset = Offset.zero;
                _lastOffset = Offset.zero;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onScaleStart: (details) {
              _startFocalPoint = details.focalPoint;
              _lastOffset = _offset;
            },
            onScaleUpdate: (details) {
              setState(() {
                _scale = (_scale * details.scale).clamp(0.5, 3.0);
                _offset = _lastOffset + (details.focalPoint - _startFocalPoint);
              });
            },
            child: CustomPaint(
              size: Size.infinite,
              painter: SimpleMapPainter(
                rooms: _rooms,
                scale: _scale,
                offset: _offset,
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 80,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  onPressed: () {
                    setState(() {
                      _scale = (_scale * 1.2).clamp(0.5, 3.0);
                    });
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  onPressed: () {
                    setState(() {
                      _scale = (_scale / 1.2).clamp(0.5, 3.0);
                    });
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.bluetooth),
        label: const Text('Connect UWB'),
      ),
    );
  }
}

class Room {
  final String name;
  final Offset position;
  final Size size;
  final Color color;

  Room(this.name, this.position, this.size, this.color);
}

class SimpleMapPainter extends CustomPainter {
  final List<Room> rooms;
  final double scale;
  final Offset offset;

  SimpleMapPainter({
    required this.rooms,
    required this.scale,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Apply transformations
    canvas.save();
    canvas.translate(offset.dx + size.width / 2, offset.dy + size.height / 2);
    canvas.scale(scale);
    canvas.translate(-size.width / 2, -size.height / 2);

    // Draw rooms
    for (final room in rooms) {
      final rect = Rect.fromLTWH(
        room.position.dx,
        room.position.dy,
        room.size.width,
        room.size.height,
      );

      // Fill
      canvas.drawRect(
        rect,
        Paint()..color = room.color,
      );

      // Border
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Label
      final textPainter = TextPainter(
        text: TextSpan(
          text: room.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          room.position.dx + (room.size.width - textPainter.width) / 2,
          room.position.dy + (room.size.height - textPainter.height) / 2,
        ),
      );
    }

    // Draw current position marker
    final positionPaint = Paint()..color = Colors.red;
    canvas.drawCircle(
      const Offset(200, 150),
      8,
      positionPaint,
    );
    canvas.drawCircle(
      const Offset(200, 150),
      12,
      Paint()
        ..color = Colors.red.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(SimpleMapPainter oldDelegate) {
    return oldDelegate.scale != scale || oldDelegate.offset != offset;
  }
}

class RoomSearchDelegate extends SearchDelegate<Room?> {
  final List<Room> rooms;

  RoomSearchDelegate(this.rooms);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = rooms
        .where((room) => room.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final room = results[index];
        return ListTile(
          leading: Icon(Icons.meeting_room, color: room.color),
          title: Text(room.name),
          subtitle: Text('Position: (${room.position.dx}, ${room.position.dy})'),
          onTap: () {
            close(context, room);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
