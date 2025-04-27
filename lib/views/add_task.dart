import 'package:flutter/material.dart';
import 'package:dimiplan/internal/database.dart';
import 'package:dimiplan/internal/model.dart';

class AddTaskScreen extends StatefulWidget {
  final Function updateTaskList;
  final Task? task;

  const AddTaskScreen({super.key, required this.updateTaskList, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String? _priority;
  int _from = 0;

  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.contents;
      _priority = _priorities[widget.task!.priority];
      _from = widget.task!.from;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  _delete() {
    db.deleteTask(widget.task!.id!);
    Navigator.pop(context);
    widget.updateTaskList();
  }

  _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Task task = Task(
        contents: _title,
        priority: _priorities.indexOf(_priority!),
        from: _from,
      );
      if (widget.task == null) {
        db.insertTask(task);
      } else {
        // Update the task
        task.id = widget.task!.id;
        task.isCompleted = widget.task!.isCompleted;
        db.updateTask(task);
      }
      widget.updateTaskList();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              widget.task == null ? '작업 추가' : '작업 수정',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
        centerTitle: false,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: '이름',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator:
                              (input) =>
                                  input!.trim().isEmpty ? '이름을 입력해 주세요.' : null,
                          onSaved: (input) => _title = input!,
                          initialValue: _title,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: DropdownButtonFormField(
                          isDense: true,
                          icon: Icon(Icons.arrow_drop_down_circle),
                          iconSize: 22.0,
                          items:
                              _priorities.map((String priority) {
                                return DropdownMenuItem(
                                  value: priority,
                                  child: Text(priority),
                                );
                              }).toList(),
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: '중요도',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator:
                              (input) =>
                                  _priority == null ? '중요도를 선택해 주세요.' : null,
                          onChanged: (value) {
                            setState(() {
                              _priority = value!;
                            });
                          },
                          value: _priority,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                        height: 60.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(30.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(128),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          onPressed: _submit,
                          child: Text(
                            widget.task == null ? '추가' : '수정',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      widget.task != null
                          ? Container(
                            margin: EdgeInsets.symmetric(vertical: 0.0),
                            height: 60.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            // ignore: deprecated_member_use
                            child: TextButton(
                              onPressed: _delete,
                              child: Text(
                                '삭제',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          )
                          : SizedBox.shrink(),
                    ],
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
