import 'package:flutter/material.dart';
import 'package:dimiplan/internal/model.dart';
import 'package:dimiplan/internal/database.dart';
import 'package:dimiplan/views/add_task.dart';
import 'package:intl/intl.dart';

class Planner extends StatefulWidget {
  const Planner({super.key});
  @override
  State<Planner> createState() => _PlannerState();
}

class _PlannerState extends State<Planner> {
  late Future<List<Task>> _taskList;
  final DateFormat _dateFormatter = DateFormat.yMd('ko_KR');

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = db.getTaskList(DateTime.now());
    });
  }

  Widget _buildTask(Task task) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: <Widget>[
          if (task.status == true)
            ListTile(
              title: Text(
                task.content,
                style: TextStyle(
                  fontSize: 18.0,
                  decoration:
                      task.status == true
                          ? TextDecoration.none
                          : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Text(
                '${_dateFormatter.format(task.date)} • ${task.priority}',
                style: TextStyle(
                  fontSize: 15.0,
                  decoration:
                      task.status == true
                          ? TextDecoration.none
                          : TextDecoration.lineThrough,
                ),
              ),
              trailing: Checkbox(
                onChanged: (value) {
                  task.status = (value! ? 1 : 0) as bool;
                  db.updateTask(task);
                  _updateTaskList();
                },
                activeColor: Theme.of(context).primaryColor,
                value: task.status == 1 ? true : false,
              ),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => AddTaskScreen(
                            updateTaskList: _updateTaskList,
                            task: task,
                          ),
                    ),
                  ),
            ),
          //Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_outlined),
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddTaskScreen(updateTaskList: _updateTaskList),
              ),
            ),
      ),
      body: FutureBuilder(
        future: _taskList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final int completedTaskCount =
              snapshot.data!
                  .where((Task task) => task.status == false)
                  .toList()
                  .length;

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 0.0),
            itemCount: 1 + snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Color.fromRGBO(240, 240, 240, 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Center(
                          child: Text(
                            'You have [ $completedTaskCount ] pending task out of [ ${snapshot.data?.length} ]',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 15.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return _buildTask(snapshot.data![index - 1]);
            },
          );
        },
      ),
    );
  }
}
