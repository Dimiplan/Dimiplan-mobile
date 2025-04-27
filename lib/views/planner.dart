import 'package:color_shade/color_shade.dart';
import 'package:flutter/material.dart';
import 'package:dimiplan/internal/model.dart';
import 'package:dimiplan/internal/database.dart';
import 'package:dimiplan/views/add_task.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});
  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Planner> _planners = [];
  Map<int, List<Task>> _tasksMap = {};
  bool _isLoading = true;
  int? _selectedPlannerId;

  @override
  void initState() {
    super.initState();
    _loadPlanners();
  }

  @override
  void dispose() {
    if (_planners.isNotEmpty) {
      _tabController.dispose();
    }
    super.dispose();
  }

  Future<void> _loadPlanners() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final planners = await db.getPlanners();

      if (planners.isEmpty) {
        setState(() {
          _planners = [];
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _planners = planners;
        _tabController = TabController(length: planners.length, vsync: this);
      });

      _tabController.addListener(() {
        if (!_tabController.indexIsChanging && _planners.isNotEmpty) {
          setState(() {
            _selectedPlannerId = _planners[_tabController.index].id;
          });
          _loadTasksForCurrentPlanner();
        }
      });

      if (planners.isNotEmpty) {
        setState(() {
          _selectedPlannerId = planners[0].id;
        });
        await _loadTasksForCurrentPlanner();
      }
    } catch (e) {
      print('Error loading planners: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTasksForCurrentPlanner() async {
    if (_planners.isEmpty || _selectedPlannerId == null) {
      return;
    }

    try {
      final tasks = await db.getTasksForPlanner(_selectedPlannerId!);
      setState(() {
        _tasksMap[_selectedPlannerId!] = tasks;
      });
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return Colors.blue.shade500; // Low priority
      case 1:
        return Colors.orange.shade500; // Medium priority
      case 2:
        return Colors.red.shade500; // High priority
      default:
        return Colors.grey; // Unknown priority
    }
  }

  Widget _buildTask(Task task) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: _getPriorityColor(task.priority), width: 2.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        title: Text(
          task.contents,
          style: TextStyle(
            fontSize: 18.0,
            decoration:
                task.isCompleted == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getPriorityColor(task.priority),
              ),
            ),
            const SizedBox(width: 8),
            Checkbox(
              onChanged: (value) async {
                task.isCompleted = value! ? 1 : 0;
                await db.updateTask(task);
                _loadTasksForCurrentPlanner();
              },
              activeColor: Colors.green,
              value: task.isCompleted == 1,
            ),
          ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => AddTaskScreen(
                    updateTaskList: _loadTasksForCurrentPlanner,
                    task: task,
                    selectedPlannerId: task.from,
                  ),
            ),
          );
          _loadTasksForCurrentPlanner();
        },
      ),
    );
  }

  Widget _buildTabContent(int plannerId) {
    final tasks = _tasksMap[plannerId] ?? [];

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '아직 작업이 없습니다.',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (_planners.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => AddTaskScreen(
                            updateTaskList: _loadTasksForCurrentPlanner,
                            selectedPlannerId: plannerId,
                          ),
                    ),
                  );
                }
              },
              child: const Text('새 작업 추가'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasksForCurrentPlanner,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 80.0),
        itemCount: tasks.length,
        itemBuilder:
            (BuildContext context, int index) => _buildTask(tasks[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_planners.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '플래너가 없습니다.',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadPlanners, child: const Text('새로고침')),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          alignment: Alignment.center,
          child: TabBar(
            controller: _tabController,
            // Removed isScrollable to make tabs use full width
            tabs:
                _planners.map((planner) {
                  return Tab(text: planner.name);
                }).toList(),
            labelColor: Theme.of(context).primaryColor.shade100,
            unselectedLabelColor: Colors.grey.shade300,
            indicatorColor: Theme.of(context).primaryColor,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children:
                _planners.map((planner) {
                  return _buildTabContent(planner.id);
                }).toList(),
          ),
        ),
      ],
    );
  }
}
