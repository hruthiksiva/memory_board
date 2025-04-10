import 'package:flutter/material.dart';
import '../models/memory_model.dart';
import '../widgets/fairy_light.dart';
import '../widgets/memory_detail_dialog.dart';

class MonthDetailScreen extends StatelessWidget {
  final String monthName;
  final List<Memory> memories;
  
  const MonthDetailScreen({
    Key? key,
    required this.monthName,
    required this.memories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sort memories by day
    final sortedMemories = List<Memory>.from(memories)
      ..sort((a, b) => a.date.day.compareTo(b.date.day));
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[600],
        elevation: 0,
        title: Text(
          monthName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              // Fairy Lights Animation at the top
              Container(
                height: 60,
                child: const FairyLights(),
              ),
              
              // Memory Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: sortedMemories.length,
                  itemBuilder: (context, index) {
                    final memory = sortedMemories[index];
                    
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => MemoryDetailDialog(memory: memory),
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
                            // Memory Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                memory.photoPath,
                                fit: BoxFit.cover,
                              ),
                            ),
                            
                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
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
                              bottom: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.amber[700]!.withOpacity(0.8),
                                ),
                                child: Text(
                                  '${memory.date.day}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
          ),
        ),
      ),
    );
  }
}