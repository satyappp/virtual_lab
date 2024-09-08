import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'marker.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late Box<MarkerModel> _markerBox;
  List<MarkerModel> _markers = [];
  List<MarkerModel> _filteredMarkers = [];
  bool _isCheckedIn = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  MarkerModel? _selectedMarker;

  @override
  void initState() {
    super.initState();
    _markerBox = Hive.box<MarkerModel>('markers');
    _loadMarkers();
    _searchController.addListener(_filterMarkers);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadMarkers() {
    setState(() {
      _markers = _markerBox.values.toList();
      _filteredMarkers = _markers;
    });
  }

  void _filterMarkers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMarkers = _markers.where((marker) {
        final matchesQuery = marker.name.toLowerCase().contains(query) ||
            marker.year.toLowerCase().contains(query) ||
            marker.hardware.toLowerCase().contains(query);
        return matchesQuery;
      }).toList();

      // Scroll to one of the filtered markers if there are any
      if (_filteredMarkers.isNotEmpty) {
        _scrollToMarker(_filteredMarkers.first);
      }
    });
  }

  void _clearFilter() {
    setState(() {
      _searchController.clear();
      _filteredMarkers = _markers;
    });
  }

  void _addMarker(LongPressStartDetails details) {
    final Offset position = details.localPosition;
    showDialog(
      context: context,
      builder: (context) => _buildRegisterDialog(context, position, _registerMarker),
    );
  }

  Widget _buildRegisterDialog(BuildContext context, Offset position, Function(MarkerModel) onRegister) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController yearController = TextEditingController();
    final TextEditingController hardwareController = TextEditingController();
    bool isUser = false;

    final hardwareResources = _markers.map((m) => m.hardware).toSet().toList();

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5DEB3), 
          title: const Text(
            'Register Desk',
            style: TextStyle(color: Color(0xFF8B4513)), 
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  style: const TextStyle(color: Color(0xFF8B4513)), 
                ),
                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'Year'),
                  style: const TextStyle(color: Color(0xFF8B4513)), 
                ),
                DropdownButtonFormField<String>(
                  items: hardwareResources.map((String resource) {
                    return DropdownMenuItem<String>(
                      value: resource,
                      child: Text(
                        resource,
                        style: const TextStyle(color: Color(0xFF8B4513)), 
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    hardwareController.text = value ?? '';
                  },
                  hint: const Text('Select Hardware'),
                  style: const TextStyle(color: Color(0xFF8B4513)), 
                ),
                TextField(
                  controller: hardwareController,
                  decoration: const InputDecoration(labelText: 'Or enter new Hardware/OS'),
                  style: const TextStyle(color: Color(0xFF8B4513)), 
                ),
                CheckboxListTile(
                  title: const Text('Is this you?'),
                  value: isUser,
                  onChanged: (value) {
                    setState(() {
                      isUser = value!;
                    });
                  },
                  activeColor: const Color(0xFF8B4513), 
                  checkColor: Colors.white,
                  controlAffinity: ListTileControlAffinity.leading,
                  tileColor: const Color(0xFFF5DEB3), 
                  selectedTileColor: const Color(0xFFF5DEB3), 
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF8B4513), 
                      backgroundColor: Colors.white, 
                      side: const BorderSide(color: Color(0xFF8B4513)), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      final newMarker = MarkerModel(
                        dx: position.dx,
                        dy: position.dy,
                        name: nameController.text,
                        year: yearController.text,
                        hardware: hardwareController.text,
                        isUser: isUser,
                      );
                      onRegister(newMarker);
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF8B4513), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Register'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _registerMarker(MarkerModel newMarker) {
    _markerBox.add(newMarker);
    setState(() {
      _markers.add(newMarker);
      _filteredMarkers = _markers;
    });
  }

  Widget _buildMarker(MarkerModel marker) {
    return Positioned(
      left: marker.dx,
      top: marker.dy,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => _buildInfoDialog(context, marker),
          );
        },
        child: Column(
          children: [
            if (_selectedMarker == marker)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.brown.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  marker.name,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            Icon(
              Icons.circle,
              color: marker.isUser
                  ? (_isCheckedIn ? Colors.green : Colors.red)
                  : Colors.brown,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoDialog(BuildContext context, MarkerModel marker) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF5DEB3), 
      title: const Text(
        'Desk Info',
        style: TextStyle(color: Color(0xFF8B4513), fontSize: 18.0),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoRow('Name: ${marker.name}'),
          _buildInfoRow('Year: ${marker.year}'),
          _buildInfoRow('Hardware: ${marker.hardware}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _editMarkerDialog(context, marker);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF8B4513), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Chat'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8B4513), 
                    backgroundColor: Colors.white, 
                    side: const BorderSide(color: Color(0xFF8B4513)), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Column(
      children: [
        Text(
          text,
          style: const TextStyle(color: Color(0xFF8B4513), fontSize: 16), 
        ),
        const Divider(
          color: Colors.brown, 
          thickness: 1,
        ),
      ],
    );
  }

  void _editMarkerDialog(BuildContext context, MarkerModel marker) {
    final TextEditingController nameController = TextEditingController(text: marker.name);
    final TextEditingController yearController = TextEditingController(text: marker.year);
    final TextEditingController hardwareController = TextEditingController(text: marker.hardware);
    bool isUser = marker.isUser;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF5DEB3),
              title: const Text(
                'Edit Desk Info',
                style: TextStyle(color: Color(0xFF8B4513)), 
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    style: const TextStyle(color: Color(0xFF8B4513)), 
                  ),
                  TextField(
                    controller: yearController,
                    decoration: const InputDecoration(labelText: 'Year'),
                    style: const TextStyle(color: Color(0xFF8B4513)), 
                  ),
                  TextField(
                    controller: hardwareController,
                    decoration: const InputDecoration(labelText: 'Hardware/OS'),
                    style: const TextStyle(color: Color(0xFF8B4513)), 
                  ),
                  CheckboxListTile(
                    title: const Text('Is this you?'),
                    value: isUser,
                    onChanged: (value) {
                      setState(() {
                        isUser = value!;
                      });
                    },
                    activeColor: const Color(0xFF8B4513), 
                    checkColor: Colors.white, 
                    controlAffinity: ListTileControlAffinity.leading,
                    tileColor: const Color(0xFFF5DEB3),
                    selectedTileColor: const Color(0xFFF5DEB3),
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF8B4513), 
                          backgroundColor: Colors.white, 
                          side: const BorderSide(color: Color(0xFF8B4513)), 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            marker.name = nameController.text;
                            marker.year = yearController.text;
                            marker.hardware = hardwareController.text;
                            marker.isUser = isUser;
                            marker.save();
                          });
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white, 
                          backgroundColor: const Color(0xFF8B4513), 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _toggleCheckInOut() {
    setState(() {
      _isCheckedIn = !_isCheckedIn;
    });
  }

  void _toggleSearch() {
    setState(() {
      if (_isSearching) {
        _animationController.reverse();
        _clearFilter(); 
      } else {
        _animationController.forward();
      }
      _isSearching = !_isSearching;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Virtual Lab',
          style: TextStyle(color: Colors.white), 
        ),
        backgroundColor: const Color(0xFF8B4513), 
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, size: 30, color: Colors.white),
            onPressed: () {
              _showMenu(context);
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMarker = null;
          });
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: GestureDetector(
                  onLongPressStart: _addMarker,
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.white,
                        child: Image.asset(
                          'assets/lab_layout.png',
                          fit: BoxFit.fitHeight,
                          height: MediaQuery.of(context).size.height,
                        ),
                      ),
                      ..._filteredMarkers.map((marker) => _buildMarker(marker)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  backgroundColor: const Color(0xFF8B4513),
                  onPressed: _toggleCheckInOut,
                  child: Icon(
                    _isCheckedIn ? Icons.check_box : Icons.check_box_outline_blank,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                if (_isSearching)
                  SizeTransition(
                    sizeFactor: _animation,
                    axis: Axis.horizontal,
                    child: Container(
                      height: 56, 
                      width: 200, 
                      decoration: BoxDecoration(
                        color: Colors.brown.withOpacity(0.8), 
                        border: Border.all(color: const Color(0xFF8B4513)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                hintStyle: TextStyle(color: Colors.white),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: _filterMarkers,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(width: 8), 
                FloatingActionButton(
                  backgroundColor: const Color(0xFF8B4513),
                  onPressed: _toggleSearch,
                  child: Icon(
                    _isSearching ? Icons.close : Icons.search,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(bottom: 20), 
          color: const Color(0xFFF5DEB3), 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuItem(context, 'Users', _showUsers),
              _buildMenuItem(context, 'Resources', _showResources),
              _buildMenuItem(context, 'Online Users', _showOnlineUsers),
              ListTile(
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Color(0xFF8B4513)), 
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, void Function(BuildContext) onTap) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(color: Color(0xFF8B4513)), 
          ),
          onTap: () {
            Navigator.pop(context);
            onTap(context);
          },
        ),
        const Divider(
          color: Color(0xFF8B4513), 
          thickness: 1,
        ),
      ],
    );
  }

  void _showUsers(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(bottom: 20), 
          color: const Color(0xFFF5DEB3), 
          child: ListView(
            children: _markers.map((marker) {
              return Column(
                children: [
                  Dismissible(
                    key: Key(marker.name),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _confirmDelete(context, marker);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTile(
                      title: Text(
                        marker.name,
                        style: const TextStyle(color: Color(0xFF8B4513)), 
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedMarker = marker;
                        });
                        _scrollToMarker(marker);
                      },
                      onLongPress: () {
                        _confirmDelete(context, marker);
                      },
                    ),
                  ),
                  const Divider(
                    color: Color(0xFF8B4513), 
                    thickness: 1,
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showResources(BuildContext context) {
    final resourceCounts = _markers.fold<Map<String, int>>({}, (map, marker) {
      if (map.containsKey(marker.hardware)) {
        map[marker.hardware] = map[marker.hardware]! + 1;
      } else {
        map[marker.hardware] = 1;
      }
      return map;
    });

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(bottom: 20), 
          color: const Color(0xFFF5DEB3), 
          child: Column(
            children: [
              ListTile(
                title: const Text(
                  'Clear Filter',
                  style: TextStyle(color: Color(0xFF8B4513)), 
                ),
                onTap: () {
                  Navigator.pop(context);
                  _clearFilter();
                },
              ),
              const Divider(
                color: Color(0xFF8B4513),
                thickness: 1,
              ),
              Expanded(
                child: ListView(
                  children: resourceCounts.entries.map((entry) {
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            '${entry.key} (${entry.value})',
                            style: const TextStyle(color: Color(0xFF8B4513)), 
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _filteredMarkers = _markers.where((marker) => marker.hardware == entry.key).toList();
                              if (_filteredMarkers.isNotEmpty) {
                                _scrollToMarker(_filteredMarkers.first);
                              }
                            });
                          },
                        ),
                        const Divider(
                          color: Color(0xFF8B4513), 
                          thickness: 1,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOnlineUsers(BuildContext context) {
    final onlineUsers = _markers.where((marker) => marker.isUser && _isCheckedIn).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(bottom: 20),
          color: const Color(0xFFF5DEB3),
          child: ListView(
            children: onlineUsers.map((marker) {
              return Column(
                children: [
                  ListTile(
                    title: Text(
                      marker.name,
                      style: const TextStyle(color: Color(0xFF8B4513)), 
                    ),
                  ),
                  const Divider(
                    thickness: 1.0,
                    color: Color(0xFF8B4513)
                  ) 
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, MarkerModel marker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5DEB3), 
        title: const Text(
          'Confirm Delete',
          style: TextStyle(color: Color(0xFF8B4513)), 
        ),
        content: const Text(
          'Are you sure you want to delete this user?',
          style: TextStyle(color: Color(0xFF8B4513)), 
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8B4513), 
                    backgroundColor: Colors.white, 
                    side: const BorderSide(color: Color(0xFF8B4513)), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      marker.delete();
                      _markers.remove(marker);
                    });
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF8B4513),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _scrollToMarker(MarkerModel marker) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final double centerX = marker.dx - size.width / 2;
    _scrollController.animateTo(
      centerX,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }
}
