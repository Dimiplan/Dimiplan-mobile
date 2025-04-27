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

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = db.getTaskList();
    });
  }

  Widget _buildTask(Task task) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
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
                onChanged: (value) {
                  task.isCompleted = value! ? 1 : 0;
                  db.updateTask(task);
                  _updateTaskList();
                },
                activeColor: Theme.of(context).primaryColor,
                value: task.isCompleted == 1 ? true : false,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => AddTaskScreen(
                          updateTaskList: _updateTaskList,
                          task: task,
                        ),
                  ),
                ).then(
                  (_) => _updateTaskList(),
                ); // Update task list when returning from edit screen
              },
            ),
          //Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        elevation: 8.0,
        child: Icon(Icons.add, color: Colors.white, size: 32),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(updateTaskList: _updateTaskList),
            ),
          ).then(
            (_) => _updateTaskList(),
          ); // Update task list when returning from add screen
        },
      ),
      body: FutureBuilder(
        future: _taskList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 0.0),
            itemCount: snapshot.data!.length,
            itemBuilder:
                (BuildContext context, int index) =>
                    _buildTask(snapshot.data![index]),
          );
        },
      ),
    );
  }
}
