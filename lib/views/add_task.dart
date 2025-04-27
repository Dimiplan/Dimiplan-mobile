import 'package:flutter/material.dart';
import 'package:dimiplan/internal/database.dart';
import 'package:dimiplan/internal/model.dart';

class AddTaskScreen extends StatefulWidget {
  final Function updateTaskList;
  final Task? task;
  final int? selectedPlannerId;

  const AddTaskScreen({
    super.key,
    required this.updateTaskList,
    this.task,
    this.selectedPlannerId,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String? _priority = '낮음';
  int _from = 1;
  List<Planner> _planners = [];
  bool _isLoadingPlanners = false;
  final TextEditingController _newPlannerNameController =
      TextEditingController();
  bool _isAddingPlanner = false;

  final List<String> _priorities = ['낮음', '중간', '높음'];

  @override
  void initState() {
    super.initState();
    _loadPlanners();

    if (widget.task != null) {
      _title = widget.task!.contents;
      _priority = _priorities[widget.task!.priority];
      _from = widget.task!.from;
    } else if (widget.selectedPlannerId != null) {
      _from = widget.selectedPlannerId!;
    }
  }

  Future<void> _loadPlanners() async {
    setState(() {
      _isLoadingPlanners = true;
    });

    try {
      final planners = await db.getPlanners();
      setState(() {
        _planners = planners;
      });

      // If no planner was selected and we have planners, use the first one
      if (_planners.isNotEmpty &&
          widget.task == null &&
          widget.selectedPlannerId == null) {
        setState(() {
          _from = _planners[0].id;
        });
      }
    } catch (e) {
      print('Error loading planners: $e');
    } finally {
      setState(() {
        _isLoadingPlanners = false;
      });
    }
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
  void dispose() {
    _newPlannerNameController.dispose();
    super.dispose();
  }

  Future<void> _showAddPlannerDialog() async {
    _newPlannerNameController.clear();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('새 플래너 추가'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: _newPlannerNameController,
                      decoration: InputDecoration(
                        labelText: '플래너 이름',
                        hintText: '새 플래너 이름을 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    if (_isAddingPlanner)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('추가'),
              onPressed:
                  _isAddingPlanner
                      ? null
                      : () async {
                        if (_newPlannerNameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('플래너 이름을 입력해주세요')),
                          );
                          return;
                        }

                        setState(() {
                          _isAddingPlanner = true;
                        });

                        try {
                          // Call the backend API to add a new planner
                          await _addNewPlanner(_newPlannerNameController.text);
                          // Reload planners list
                          await _loadPlanners();
                          Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('새 플래너가 추가되었습니다')),
                          );
                        } catch (e) {
                          print('Error adding planner: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('플래너 추가 중 오류가 발생했습니다')),
                          );
                        } finally {
                          setState(() {
                            _isAddingPlanner = false;
                          });
                        }
                      },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNewPlanner(String name) async {
    // Root folder (ID: 0)
    const int rootFolderId = 0;

    // Add planner to the root folder
    await db.addPlanner(name, 0, rootFolderId);
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
        actions: [IconButton(icon: Icon(Icons.info_outline), onPressed: () {})],
        centerTitle: false,
        elevation: 0,
      ),
      body:
          _isLoadingPlanners
              ? Center(child: CircularProgressIndicator())
              : GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 40.0,
                    ),
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
                                          input!.trim().isEmpty
                                              ? '이름을 입력해 주세요.'
                                              : null,
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
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      priority == '낮음'
                                                          ? Colors.blue.shade500
                                                          : priority == '중간'
                                                          ? Colors
                                                              .orange
                                                              .shade500
                                                          : Colors.red.shade500,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                priority,
                                                style: TextStyle(
                                                  color:
                                                      Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.color,
                                                ),
                                              ),
                                            ],
                                          ),
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
                                          _priority == null
                                              ? '중요도를 선택해 주세요.'
                                              : null,
                                  onChanged: (value) {
                                    setState(() {
                                      _priority = value!;
                                    });
                                  },
                                  value: _priority,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: Column(
                                  children: [
                                    DropdownButtonFormField<int>(
                                      isDense: true,
                                      icon: Icon(Icons.arrow_drop_down_circle),
                                      iconSize: 22.0,
                                      items:
                                          _planners.map((Planner planner) {
                                            return DropdownMenuItem(
                                              value: planner.id,
                                              child: Text(
                                                planner.name,
                                                style: TextStyle(
                                                  color:
                                                      Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.color,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                      style: TextStyle(fontSize: 18.0),
                                      decoration: InputDecoration(
                                        labelText: '플래너',
                                        labelStyle: TextStyle(fontSize: 18.0),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.0,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _from = value!;
                                        });
                                      },
                                      value:
                                          _planners.isNotEmpty
                                              ? (_planners.any(
                                                    (p) => p.id == _from,
                                                  )
                                                  ? _from
                                                  : _planners.first.id)
                                              : null,
                                    ),
                                    SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: () {
                                        _showAddPlannerDialog();
                                      },
                                      icon: Icon(Icons.add),
                                      label: Text('새 플래너 추가'),
                                    ),
                                  ],
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
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 15.0,
                                    ),
                                  ),
                                  onPressed: _submit,
                                  child: Text(
                                    widget.task == null ? '추가' : '수정',
                                    style: TextStyle(
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
                                      borderRadius: BorderRadius.circular(30.0),
                                      border: Border.all(
                                        color: Colors.red,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: TextButton(
                                      onPressed: _delete,
                                      child: Text(
                                        '삭제',
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.red,
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
