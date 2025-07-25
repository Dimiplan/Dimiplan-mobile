import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dimiplan/models/planner_models.dart';
import 'package:dimiplan/providers/planner_provider.dart';
import 'package:dimiplan/widgets/button.dart';
import 'package:dimiplan/widgets/input_field.dart';
import 'package:dimiplan/utils/snackbar_util.dart';
import 'package:dimiplan/utils/dialog_utils.dart';
import 'package:dimiplan/utils/validation_utils.dart';

/// 새 플래너 생성 다이얼로그
Future<bool?> showCreatePlannerDialog(BuildContext context) async {
  final result = await DialogUtils.showInputDialog(
    context: context,
    title: '새 플래너 추가',
    hintText: '새 플래너 이름을 입력하세요',
    validator: (value) => ValidationUtils.validateRequired(value, '플래너 이름'),
  );

  if (result != null) {
    if (!context.mounted) return false;
    final plannerProvider = Provider.of<PlannerProvider>(
      context,
      listen: false,
    );
    try {
      await plannerProvider.createPlanner(result);
      return true;
    } catch (e) {
      print('플래너 추가 중 오류: $e');
      if (context.mounted) {
        showErrorSnackBar(context, '플래너 추가 중 오류가 발생했습니다.');
      }
      return false;
    }
  }
  return null;
}

/// 작업 추가/수정 화면
class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({
    required this.updateTaskList,
    super.key,
    this.task,
    this.selectedPlannerId,
  });
  final Function updateTaskList;
  final Task? task;
  final int? selectedPlannerId;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _priority;
  int _from = 1;
  List<Planner> _planners = [];
  bool _isSubmitting = false;
  String? _titleError;
  String? _priorityError;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // 우선순위 옵션
  final List<String> _priorities = ['낮음', '중간', '높음'];

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 페이드인 애니메이션
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // 플래너 목록 로드
    final plannerProvider = Provider.of<PlannerProvider>(
      context,
      listen: false,
    );
    _planners = plannerProvider.planners;

    // 기존 작업 정보 설정 (수정 모드)
    if (widget.task != null) {
      _titleController.text = widget.task!.contents;
      _priority = _priorities[widget.task!.priority];
      _from = widget.task!.from;
    }
    // 선택된 플래너 ID 설정 (새 작업 모드)
    else if (widget.selectedPlannerId != null) {
      _from = widget.selectedPlannerId!;
    } else if (_planners.isNotEmpty) {
      // 플래너가 있고 선택된 플래너가 없는 경우 첫 번째 플래너 사용
      _from = _planners[0].id;
    }

    // 애니메이션 시작
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // 작업 삭제
  Future<void> _delete() async {
    if (widget.task == null) return;

    // 확인 다이얼로그
    final confirm = await DialogUtils.showConfirmDialog(
      context: context,
      title: '작업 삭제',
      content: '정말 "${widget.task!.contents}" 작업을 삭제하시겠습니까?',
      confirmText: '삭제',
      confirmColor: Theme.of(context).colorScheme.error,
    );

    if (confirm != true) return;

    try {
      setState(() {
        _isSubmitting = true;
      });

      if (!context.mounted) return;
      final plannerProvider = Provider.of<PlannerProvider>(
        context,
        listen: false,
      );
      await plannerProvider.deleteTask(widget.task!.id!);

      // 플래너 제공자에서 전체 데이터 새로고침
      await plannerProvider.refreshAll();

      // 콜백 호출
      widget.updateTaskList();

      if (mounted) {
        showSuccessSnackBar(context, '작업이 삭제되었습니다.');
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('작업 삭제 중 오류: $e');
      if (mounted) {
        showErrorSnackBar(context, '작업 삭제 중 오류가 발생했습니다.');
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // 폼 제출 (추가 또는 수정)
  Future<void> _submit() async {
    if (!_validateForm()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final plannerProvider = Provider.of<PlannerProvider>(
        context,
        listen: false,
      );

      // 작업 객체 생성
      final task = Task(
        contents: _titleController.text.trim(),
        priority: _priorities.indexOf(_priority!),
        from: _from,
      );

      if (widget.task == null) {
        // 새 작업 추가
        await plannerProvider.addTask(task);
        if (mounted) {
          showSuccessSnackBar(context, '작업이 추가되었습니다.');
        }
      } else {
        // 기존 작업 수정
        final updatedTask = Task(
          id: widget.task!.id,
          contents: task.contents,
          priority: task.priority,
          from: task.from,
          isCompleted: widget.task!.isCompleted,
        );

        await plannerProvider.updateTask(updatedTask);
        if (mounted) {
          showSuccessSnackBar(context, '작업이 수정되었습니다.');
        }
      }

      // 플래너 제공자에서 전체 데이터 새로고침
      await plannerProvider.refreshAll();

      // 콜백 호출
      widget.updateTaskList();

      if (mounted && context.mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('작업 저장 중 오류: $e');
      if (mounted) {
        showErrorSnackBar(context, '작업 저장 중 오류가 발생했습니다.');
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // 폼 유효성 검사
  bool _validateForm() {
    bool isValid = true;

    // 제목 검증
    final titleError = ValidationUtils.validateRequired(
      _titleController.text,
      '작업 이름',
    );
    setState(() {
      _titleError = titleError;
    });
    if (titleError != null) isValid = false;

    // 우선순위 검증
    if (_priority == null) {
      setState(() {
        _priorityError = '우선순위를 선택해 주세요.';
      });
      isValid = false;
    } else {
      setState(() {
        _priorityError = null;
      });
    }

    return isValid;
  }

  // 새 플래너 생성 다이얼로그 표시
  Future<void> _navigateToCreatePlannerScreen() async {
    final result = await showCreatePlannerDialog(context);

    if (result == true) {
      // 새 플래너가 추가된 경우 목록 새로고침
      if (!context.mounted) return;
      final plannerProvider = Provider.of<PlannerProvider>(
        context,
        listen: false,
      );
      await plannerProvider.refreshAll();

      if (mounted) {
        showSuccessSnackBar(context, '새 플래너가 추가되었습니다.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plannerProvider = Provider.of<PlannerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.task == null ? '작업 추가' : '작업 수정',
          style: theme.textTheme.titleLarge,
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body:
          plannerProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 작업 이름 입력
                            Text('이름', style: theme.textTheme.titleSmall),
                            const SizedBox(height: 8),
                            AppTextField(
                              label: '',
                              controller: _titleController,
                              errorText: _titleError,
                              placeholder: '작업 이름을 입력하세요',
                              onChanged:
                                  (_) => setState(() => _titleError = null),
                            ),
                            const SizedBox(height: 24),

                            // 우선순위 선택
                            Text('중요도', style: theme.textTheme.titleSmall),
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(
                                      color:
                                          _priorityError != null
                                              ? theme.colorScheme.error
                                              : theme.colorScheme.outline,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _priority,
                                      hint: const Text('중요도 선택'),
                                      isExpanded: true,
                                      items:
                                          _priorities.map((priority) {
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
                                                              ? Colors
                                                                  .blue
                                                                  .shade500
                                                              : priority == '중간'
                                                              ? Colors
                                                                  .orange
                                                                  .shade500
                                                              : Colors
                                                                  .red
                                                                  .shade500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    priority,
                                                    style:
                                                        theme
                                                            .textTheme
                                                            .bodyMedium,
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _priority = value;
                                          _priorityError = null;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                if (_priorityError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16.0,
                                      top: 4.0,
                                    ),
                                    child: Text(
                                      _priorityError!,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.error,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // 플래너 선택
                            Text('플래너', style: theme.textTheme.titleSmall),
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_planners.isEmpty)
                                  Text(
                                    '사용 가능한 플래너가 없습니다. 먼저 플래너를 추가해주세요.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.error,
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 4.0,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: theme.colorScheme.outline,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value:
                                            _planners.any((p) => p.id == _from)
                                                ? _from
                                                : _planners.isNotEmpty
                                                ? _planners.first.id
                                                : null,
                                        hint: const Text('플래너 선택'),
                                        isExpanded: true,
                                        items:
                                            _planners.map((planner) {
                                              return DropdownMenuItem(
                                                value: planner.id,
                                                child: Text(
                                                  planner.name,
                                                  style:
                                                      theme
                                                          .textTheme
                                                          .bodyMedium,
                                                ),
                                              );
                                            }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _from = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),

                                // 새 플래너 추가 버튼
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: TextButton.icon(
                                    onPressed: _navigateToCreatePlannerScreen,
                                    icon: const Icon(Icons.add),
                                    label: const Text('새 플래너 추가'),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),

                            // 버튼 영역
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 저장 버튼
                                Expanded(
                                  child: AppButton(
                                    text: widget.task == null ? '추가' : '수정',
                                    isLoading: _isSubmitting,
                                    isFullWidth: true,
                                    rounded: true,
                                    onPressed: _submit,
                                  ),
                                ),

                                // 삭제 버튼 (수정 모드일 때만)
                                if (widget.task != null) ...[
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: AppButton(
                                      text: '삭제',
                                      variant: ButtonVariant.danger,
                                      isFullWidth: true,
                                      rounded: true,
                                      onPressed: _delete,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
