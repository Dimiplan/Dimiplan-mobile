import 'package:flutter/material.dart';
import 'package:dimiplan/internal/model.dart';
import 'package:dimiplan/internal/database.dart';
import 'package:dimiplan/views/add_task.dart';

class Planner extends StatefulWidget {
  const Planner({super.key});
  @override
  State<Planner> createState() => _PlannerState();
}

class _PlannerState extends State<Planner> {
  late Future<List<Task>> _taskList;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Planner oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = db.getTaskList();
    });
  }

  Widget _buildTask(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: <Widget>[
          if (task.isCompleted == 0)
            ListTile(
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
              trailing: Checkbox(
                onChanged: (value) async {
                  task.isCompleted = value! ? 1 : 0;
                  await db.updateTask(task);
                  _updateTaskList();
                },
                activeColor: Theme.of(context).primaryColor,
                value: task.isCompleted == 1 ? true : false,
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => AddTaskScreen(
                          updateTaskList: _updateTaskList,
                          task: task,
                        ),
                  ),
                );
                _updateTaskList(); // Update task list when returning from edit screen
              },
            ),
          //Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _updateTaskList();
    return FutureBuilder(
      future: _taskList,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () async {
            _updateTaskList();
          },
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 80.0),
            itemCount: snapshot.data!.length,
            itemBuilder:
                (BuildContext context, int index) =>
                    _buildTask(snapshot.data![index]),
          ),
        );
      },
    );
  }
}
