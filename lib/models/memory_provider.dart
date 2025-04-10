import 'package:flutter/material.dart';
import 'dart:math';
import 'memory_model.dart';

class MemoryProvider extends ChangeNotifier {
  final List<Memory> _memories = [];
  final List<String> _dummyPhotoPaths = [
    'assets/images/photo1.png',
    'assets/images/photo2.png',
    'assets/images/photo3.png',
    'assets/images/photo4.png',
    'assets/images/photo5.png',
    'assets/images/photo6.png',
    'assets/images/photo7.png',
    'assets/images/photo8.png',
    'assets/images/photo9.png',
    'assets/images/photo10.png',
  ];
  
  List<Memory> get memories => _memories;
  
  // Get random photos for swiping
  List<String> getRandomPhotos(int count) {
    final random = Random();
    List<String> randomPhotos = [];
    
    for (int i = 0; i < count; i++) {
      int randomIndex = random.nextInt(_dummyPhotoPaths.length);
      randomPhotos.add(_dummyPhotoPaths[randomIndex]);
    }
    
    return randomPhotos;
  }
  
  // Add a memory to the board
  void addMemory(String photoPath) {
    // Generate a random date within the past year for demo purposes
    final random = Random();
    final today = DateTime.now();
    final daysToSubtract = random.nextInt(365);
    final randomDate = today.subtract(Duration(days: daysToSubtract));
    
    // Check if we already have a memory for this date
    final existingMemoryIndex = _memories.indexWhere(
      (memory) => 
        memory.date.year == randomDate.year && 
        memory.date.month == randomDate.month && 
        memory.date.day == randomDate.day
    );
    
    if (existingMemoryIndex >= 0) {
      // We'll replace the existing memory in the UI flow
      _memories[existingMemoryIndex] = Memory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        photoPath: photoPath,
        date: randomDate,
      );
    } else {
      _memories.add(Memory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        photoPath: photoPath,
        date: randomDate,
      ));
    }
    
    // Sort memories by date
    _memories.sort((a, b) => b.date.compareTo(a.date));
    
    notifyListeners();
  }
  
  // Decide whether to replace an existing memory
  void replaceMemory(String oldPhotoPath, String newPhotoPath, DateTime date) {
    final memoryIndex = _memories.indexWhere(
      (memory) => memory.photoPath == oldPhotoPath && memory.date == date
    );
    
    if (memoryIndex >= 0) {
      _memories[memoryIndex] = Memory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        photoPath: newPhotoPath,
        date: date,
      );
      
      notifyListeners();
    }
  }
  
  // Get memories grouped by month
  Map<String, List<Memory>> getMemoriesByMonth() {
    Map<String, List<Memory>> groupedMemories = {};
    
    for (var memory in _memories) {
      final monthYear = '${_getMonthName(memory.date.month)} ${memory.date.year}';
      
      if (!groupedMemories.containsKey(monthYear)) {
        groupedMemories[monthYear] = [];
      }
      
      groupedMemories[monthYear]!.add(memory);
    }
    
    return groupedMemories;
  }
  
  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return monthNames[month - 1];
  }
  
  // Get memories for a specific date
  Memory? getMemoryForDate(DateTime date) {
    try {
      return _memories.firstWhere(
        (memory) => 
          memory.date.year == date.year && 
          memory.date.month == date.month && 
          memory.date.day == date.day
      );
    } catch (e) {
      return null;
    }
  }
  
  // Check if there's an existing memory for the current date
  Memory? checkExistingMemoryForDate(DateTime date) {
    try {
      return _memories.firstWhere(
        (memory) => 
          memory.date.year == date.year && 
          memory.date.month == date.month && 
          memory.date.day == date.day
      );
    } catch (e) {
      return null;
    }
  }
}