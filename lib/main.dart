
import 'package:flutter/material.dart';

void main() {
  runApp(const RavandApp());
}

class RavandApp extends StatelessWidget {
  const RavandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'رواند',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7656D6),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F5FC),
      ),
      home: const HomePage(),
    );
  }
}

class Task {
  String title;
  String priority;
  bool done;

  Task(this.title, this.priority, {this.done = false});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Task> tasks = [];
  final TextEditingController search = TextEditingController();
  String filter = 'همه';

  Future<void> addTask() async {
    final titleController = TextEditingController();
    String priority = 'متوسط';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('کار جدید'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'عنوان کار را بنویس',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: priority,
                decoration: const InputDecoration(labelText: 'اولویت'),
                items: ['زیاد', 'متوسط', 'کم']
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => priority = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('لغو'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('افزودن'),
            ),
          ],
        ),
      ),
    );

    if (result == true && titleController.text.trim().isNotEmpty) {
      setState(() {
        tasks.add(Task(titleController.text.trim(), priority));
      });
    }
    titleController.dispose();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleTasks = tasks.where((task) {
      final matchesSearch = task.title
          .toLowerCase()
          .contains(search.text.trim().toLowerCase());
      final matchesFilter = filter == 'همه' ||
          (filter == 'انجام‌شده' && task.done) ||
          (filter == 'باقی‌مانده' && !task.done);
      return matchesSearch && matchesFilter;
    }).toList();

    final completed = tasks.where((task) => task.done).length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'رواند',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: addTask,
          icon: const Icon(Icons.add),
          label: const Text('کار جدید'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7656D6),
                        Color(0xFF9B7BEA),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'برنامه‌ریزی بهتر، زندگی آرام‌تر',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${tasks.length} کار  •  $completed انجام‌شده',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: tasks.isEmpty ? 0 : completed / tasks.length,
                        backgroundColor: Colors.white30,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: search,
                  decoration: InputDecoration(
                    hintText: 'جست‌وجوی کارها...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['همه', 'باقی‌مانده', 'انجام‌شده']
                      .map((item) => ChoiceChip(
                            label: Text(item),
                            selected: filter == item,
                            onSelected: (_) => setState(() => filter = item),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: visibleTasks.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 58,
                                color: Color(0xFF9B7BEA),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'هنوز کاری اینجا نیست',
                                style: TextStyle(fontSize: 17),
                              ),
                              Text('برای شروع، روی «کار جدید» بزن'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: visibleTasks.length,
                          itemBuilder: (context, index) {
                            final task = visibleTasks[index];
                            final color = task.priority == 'زیاد'
                                ? Colors.red
                                : task.priority == 'کم'
                                    ? Colors.green
                                    : Colors.orange;

                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: Checkbox(
                                  value: task.done,
                                  onChanged: (value) {
                                    setState(() => task.done = value ?? false);
                                  },
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    decoration: task.done
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: Text(
                                  'اولویت: ${task.priority}',
                                  style: TextStyle(color: color),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() => tasks.remove(task));
                                  },
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
      ),
    );
  }
}