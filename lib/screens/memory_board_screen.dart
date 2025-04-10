import 'package:flutter/material.dart';
import 'package:memory_board/screens/month_detail_screen.dart';
import 'package:provider/provider.dart';
import '../models/memory_provider.dart';
import '../models/memory_model.dart';
import '../widgets/fairy_light.dart';
import '../widgets/memory_detail_dialog.dart';

class MemoryBoardScreen extends StatefulWidget {
  const MemoryBoardScreen({super.key});

  @override
  _MemoryBoardScreenState createState() => _MemoryBoardScreenState();
}

class _MemoryBoardScreenState extends State<MemoryBoardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _timeViews = ['Days', 'Months', 'Years'];
  int _selectedTabIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _timeViews.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memoryProvider = Provider.of<MemoryProvider>(context);
    final memories = memoryProvider.memories;
    final memoriesByMonth = memoryProvider.getMemoriesByMonth();
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[600],
        elevation: 0,
        title: const Text(
          'Memory Mood Board',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _timeViews.map((view) => Tab(text: view)).toList(),
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
          child: TabBarView(
            controller: _tabController,
            children: [
              // Days View - Horizontal scrolling timeline
              _buildDaysView(memories),
              
              // Months View - Grid of months
              _buildMonthsView(memoriesByMonth),
              
              // Years View - Vertical list of years
              _buildYearsView(memories),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaysView(List<Memory> memories) {
    if (memories.isEmpty) {
      return _buildEmptyState();
    }
    
    return Column(
      children: [
        // Fairy Lights Animation at the top
        Container(
          height: 60,
          child: const FairyLights(),
        ),
        
        // Horizontal Timeline
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: memories.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemBuilder: (context, index) {
              final memory = memories[index];
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => MemoryDetailDialog(memory: memory),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 20),
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          memory.photoPath,
                          fit: BoxFit.cover,
                        ),
                      ),
                      
                      // Gradient overlay for date visibility
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      
                      // Date display
                      Positioned(
                        bottom: 15,
                        left: 15,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${memory.date.day}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_getMonthName(memory.date.month)} ${memory.date.year}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthsView(Map<String, List<Memory>> memoriesByMonth) {
    if (memoriesByMonth.isEmpty) {
      return _buildEmptyState();
    }

    final sortedMonths = memoriesByMonth.keys.toList()
      ..sort((a, b) {
        final aDate = memoriesByMonth[a]!.first.date;
        final bDate = memoriesByMonth[b]!.first.date;
        return bDate.compareTo(aDate); // Sort descending
      });
    
    return Column(
      children: [
        // Fairy Lights Animation at the top
        Container(
          height: 60,
          child: const FairyLights(),
        ),
        // Grid of Months
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: sortedMonths.length,
            itemBuilder: (context, index) {
              final monthKey = sortedMonths[index];
              final monthMemories = memoriesByMonth[monthKey]!;
              
              // Use the first memory as the cover image
              final coverMemory = monthMemories.first;
              
              return GestureDetector(
                onTap: () {
                  // Show month detail view
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MonthDetailScreen(
                        monthName: monthKey,
                        memories: monthMemories,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Cover Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          coverMemory.photoPath,
                          fit: BoxFit.cover,
                        ),
                      ),
                      
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      
                      // Month name and count
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              monthKey,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${monthMemories.length} memories',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYearsView(List<Memory> memories) {
    if (memories.isEmpty) {
      return _buildEmptyState();
    }
    
    // Group memories by year
    Map<int, List<Memory>> memoriesByYear = {};
    for (var memory in memories) {
      final year = memory.date.year;
      if (!memoriesByYear.containsKey(year)) {
        memoriesByYear[year] = [];
      }
      memoriesByYear[year]!.add(memory);
    }
    
    // Sort years descending
    final sortedYears = memoriesByYear.keys.toList()..sort((a, b) => b.compareTo(a));
    
    return Column(
      children: [
        // Fairy Lights Animation at the top
        Container(
          height: 60,
          child: const FairyLights(),
        ),
        
        // List of Years
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedYears.length,
            itemBuilder: (context, index) {
              final year = sortedYears[index];
              final yearMemories = memoriesByYear[year]!;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Year Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber[800],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            year.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${yearMemories.length} memories',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Preview Grid
                    Container(
                      height: 120,
                      padding: const EdgeInsets.all(12),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: yearMemories.length,
                        itemBuilder: (context, memoryIndex) {
                          final memory = yearMemories[memoryIndex];
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => MemoryDetailDialog(memory: memory),
                              );
                            },
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  memory.photoPath,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_album_outlined,
            size: 80,
            color: Colors.amber[800]!.withOpacity(0.7),
          ),
          const SizedBox(height: 20),
          Text(
            'No memories yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.amber[800],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Start swiping to add memories',
            style: TextStyle(
              fontSize: 16,
              color: Colors.amber[900],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/swipe');
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.amber[800],
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Go to Swipe Screen',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return monthNames[month - 1];
  }
}