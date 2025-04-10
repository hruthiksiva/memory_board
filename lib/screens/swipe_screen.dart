import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/memory_provider.dart';
import '../models/memory_model.dart';
import '../widgets/photo_card.dart';
import '../widgets/replacement_dialog.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({Key? key}) : super(key: key);

  @override
  _SwipeScreenState createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> with SingleTickerProviderStateMixin {
  List<String> _photos = [];
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  late Offset _dragStart;
  late Offset _dragPosition;
  bool _isDragging = false;
  DateTime? _currentPhotoDate;

  @override
  void initState() {
    super.initState();
    
    // Initialize the photos
    _loadPhotos();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_animationController);
    
    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadPhotos() {
    final memoryProvider = Provider.of<MemoryProvider>(context, listen: false);
    setState(() {
      _photos = memoryProvider.getRandomPhotos(10);
      _currentIndex = 0;
      _assignRandomDate();
    });
  }

  void _assignRandomDate() {
    final random = Random();
    final today = DateTime.now();
    final daysToSubtract = random.nextInt(365);
    setState(() {
      _currentPhotoDate = today.subtract(Duration(days: daysToSubtract));
    });
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragStart = details.globalPosition;
      _dragPosition = Offset.zero;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition = Offset(
        details.globalPosition.dx - _dragStart.dx,
        details.globalPosition.dy - _dragStart.dy,
      );
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final dragVelocity = details.velocity.pixelsPerSecond.dx;
    
    if (_dragPosition.dx.abs() > 100 || dragVelocity.abs() > 700) {
      // Swipe threshold met, decide direction
      final isSwipeRight = _dragPosition.dx > 0 || dragVelocity > 0;
      
      if (isSwipeRight) {
        _handleSwipeRight();
      } else {
        _handleSwipeLeft();
      }
      
      // Animate card off-screen
      final screenWidth = MediaQuery.of(context).size.width;
      _animation = Tween<Offset>(
        begin: _dragPosition,
        end: Offset(isSwipeRight ? screenWidth : -screenWidth, 0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ));
      
      _animationController.forward().then((_) {
        _loadNextPhoto();
      });
    } else {
      // Not enough to trigger swipe, animate back to center
      _animation = Tween<Offset>(
        begin: _dragPosition,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ));
      
      _animationController.forward().then((_) {
        setState(() {
          _isDragging = false;
        });
      });
    }
  }

  void _handleSwipeRight() {
    final memoryProvider = Provider.of<MemoryProvider>(context, listen: false);
    
    // Check if there's already a memory for this date
    if (_currentPhotoDate != null) {
      Memory? existingMemory = memoryProvider.checkExistingMemoryForDate(_currentPhotoDate!);
      
      if (existingMemory != null) {
        // Show replacement dialog
        Future.delayed(const Duration(milliseconds: 300), () {
          showDialog(
            context: context,
            builder: (context) => ReplacementDialog(
              oldPhotoPath: existingMemory.photoPath,
              newPhotoPath: _photos[_currentIndex],
              date: _currentPhotoDate!,
            ),
          );
        });
      } else {
        // Add new memory
        memoryProvider.addMemory(_photos[_currentIndex]);
      }
    }
  }

  void _handleSwipeLeft() {
    // Just skip this photo, nothing to add
  }

  void _loadNextPhoto() {
    _animationController.reset();
    
    setState(() {
      _currentIndex++;
      if (_currentIndex >= _photos.length) {
        // Reload with new photos when we run out
        _photos = Provider.of<MemoryProvider>(context, listen: false).getRandomPhotos(10);
        _currentIndex = 0;
      }
      _isDragging = false;
      _dragPosition = Offset.zero;
      _assignRandomDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final memoryProvider = Provider.of<MemoryProvider>(context);
    
    // Calculate card angle based on drag position
    final rotationAngle = _isDragging ? _dragPosition.dx / 300 : 0.0;
    
    // Calculate card scale based on drag position
    double scale = _isDragging
        ? 0.9 + (0.1 * (1 - (_dragPosition.dx.abs() / screenSize.width)))
        : 1.0;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[600],
        elevation: 0,
        title: const Text(
          'Choose Your Memories',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.amber[600]!,
              Colors.yellow[200]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Swipe instructions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Swipe right to keep, left to ignore',
                  style: TextStyle(
                    color: Colors.amber[900],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Date display
              if (_currentPhotoDate != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Photo from: ${_currentPhotoDate!.day}/${_currentPhotoDate!.month}/${_currentPhotoDate!.year}',
                    style: TextStyle(
                      color: Colors.amber[800],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // Card area
              Expanded(
                child: _photos.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          // Show next photo as background if available
                          if (_currentIndex < _photos.length - 1)
                            Transform.scale(
                              scale: 0.9,
                              child: PhotoCard(
                                photoPath: _photos[_currentIndex + 1],
                              ),
                            ),
                          
                          // Current draggable photo
                          GestureDetector(
                            onPanStart: _onDragStart,
                            onPanUpdate: _onDragUpdate,
                            onPanEnd: _onDragEnd,
                            child: Transform.translate(
                              offset: _isDragging ? _dragPosition : _animation.value,
                              child: Transform.rotate(
                                angle: rotationAngle,
                                child: Transform.scale(
                                  scale: scale,
                                  child: PhotoCard(
                                    photoPath: _photos[_currentIndex],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          // Like/Dislike indicators
                          if (_isDragging)
                            Positioned(
                              right: 20,
                              top: 40,
                              child: Opacity(
                                opacity: _dragPosition.dx > 0 ? min(1.0, _dragPosition.dx / 100) : 0.0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.green[400],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Text(
                                    'KEEP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          
                          if (_isDragging)
                            Positioned(
                              left: 20,
                              top: 40,
                              child: Opacity(
                                opacity: _dragPosition.dx < 0 ? min(1.0, -_dragPosition.dx / 100) : 0.0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.red[400],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Text(
                                    'SKIP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
              
              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      heroTag: 'btn1',
                      onPressed: () {
                        // Manual swipe left
                        _animation = Tween<Offset>(
                          begin: Offset.zero,
                          end: Offset(-MediaQuery.of(context).size.width, 0),
                        ).animate(_animationController);
                        
                        _animationController.forward().then((_) {
                          _handleSwipeLeft();
                          _loadNextPhoto();
                        });
                      },
                      backgroundColor: Colors.white,
                      child: Icon(Icons.close, color: Colors.red[400], size: 30),
                    ),
                    FloatingActionButton(
                      heroTag: 'btn2',
                      onPressed: () {
                        // Manual swipe right
                        _animation = Tween<Offset>(
                          begin: Offset.zero,
                          end: Offset(MediaQuery.of(context).size.width, 0),
                        ).animate(_animationController);
                        
                        _animationController.forward().then((_) {
                          _handleSwipeRight();
                          _loadNextPhoto();
                        });
                      },
                      backgroundColor: Colors.white,
                      child: Icon(Icons.favorite, color: Colors.green[400], size: 30),
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
}