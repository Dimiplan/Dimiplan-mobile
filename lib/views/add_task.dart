import 'package:flutter/material.dart';
import 'package:dimiplan/internal/database.dart';
import 'package:dimiplan/internal/model.dart';
import 'package:color_shade/color_shade.dart';


class CreatePlannerScreen extends StatefulWidget {
  const CreatePlannerScreen({super.key});

  @override
  State<CreatePlannerScreen> createState() => _CreatePlannerScreenState();
}

class _CreatePlannerScreenState extends State<CreatePlannerScreen> {
  final TextEditingController _plannerNameController = TextEditingController();
  bool _isAddingPlanner = false;

  @override
  void dispose() {
    _plannerNameController.dispose();
    super.dispose();
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
        title: Text(
          '새 플래너 추가',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _plannerNameController,
              decoration: InputDecoration(
                labelText: '플래너 이름',
                hintText: '새 플래너 이름을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 24),
            if (_isAddingPlanner)
              Center(child: CircularProgressIndicator())
            else
              Container(
                margin: EdgeInsets.symmetric(vertical: 20.0),
                height: 60.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.5),
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
                  onPressed: () async {
                    if (_plannerNameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('플래너 이름을 입력해주세요')),
                      );
                      return;
                    }

                    setState(() {
                      _isAddingPlanner = true;
                    });

                    try {
                      await _addNewPlanner(_plannerNameController.text);
                      Navigator.pop(context, true);
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
                  child: Text(
                    '추가',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall!
                        .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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

  Future<void> _navigateToCreatePlannerScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatePlannerScreen()),
    );

    if (result == true) {
      // Reload planners if a new one was added
      await _loadPlanners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('새 플래너가 추가되었습니다')),
      );
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
              style: Theme.of(context).textTheme.titleLarge,
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
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    labelText: '이름',
                                    labelStyle: Theme.of(context).textTheme.bodyLarge,
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
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    labelText: '중요도',
                                    labelStyle: Theme.of(context).textTheme.bodyLarge,
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
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                            );
                                          }).toList(),
                                      style: Theme.of(context).textTheme.bodyLarge,
                                      decoration: InputDecoration(
                                        labelText: '플래너',
                                        labelStyle: Theme.of(context).textTheme.bodyLarge,
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
                                        _navigateToCreatePlannerScreen();
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
                                      color: Theme.of(context).shadowColor.withOpacity(0.5),
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
                                      side: BorderSide(
                                        color: Theme.of(context).primaryColor.shade100,
                                        width: 2.0,
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 15.0,
                                    ),
                                  ),
                                  onPressed: _submit,
                                  child: Text(
                                    widget.task == null ? '추가' : '수정',
                                    style: Theme.of(context).textTheme.displaySmall,
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
                                        color: Theme.of(context).colorScheme.error,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: TextButton(
                                      onPressed: _delete,
                                      child: Text(
                                        '삭제',
                                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                          color: Theme.of(context).colorScheme.error,
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
