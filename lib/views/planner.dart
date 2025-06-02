import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/providers/planner_provider.dart';
import 'package:dimiplan/providers/auth_provider.dart';
import 'package:dimiplan/models/planner_models.dart';
import 'package:dimiplan/widgets/button.dart';
import 'package:dimiplan/views/add_task.dart';
import 'package:dimiplan/utils/snackbar_util.dart';

class PlannerPage extends StatefulWidget {
  final void Function(int)? onTabChange;
  const PlannerPage({super.key, this.onTabChange});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final plannerProvider = Provider.of<PlannerProvider>(
        context,
        listen: false,
      );
      plannerProvider.loadPlanners();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // PlannerProvider 변경 감지 및 TabController 초기화
    final plannerProvider = Provider.of<PlannerProvider>(context);
    final planners = plannerProvider.planners;

    if (planners.isNotEmpty && !_isInitialized) {
      _tabController = TabController(length: planners.length, vsync: this);

      _tabController.addListener(() {
        if (!_tabController.indexIsChanging) {
          // 탭 변경 시 해당 플래너의 작업 로드
          plannerProvider.selectPlanner(planners[_tabController.index]);
        }
      });

      // 첫 번째 플래너 선택
      plannerProvider.selectPlanner(planners[0]);

      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void didUpdateWidget(covariant PlannerPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 플래너 목록이 변경되면 TabController 업데이트
    final plannerProvider = Provider.of<PlannerProvider>(context);
    final planners = plannerProvider.planners;

    if (planners.isNotEmpty && _isInitialized) {
      _tabController.dispose();
      _tabController = TabController(length: planners.length, vsync: this);
      _tabController.addListener(() {
        if (!_tabController.indexIsChanging) {
          plannerProvider.selectPlanner(planners[_tabController.index]);
        }
      });
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<PlannerProvider, AuthProvider>(
      builder: (context, plannerProvider, authProvider, _) {
        // 로딩 중일 때
        if (plannerProvider.isLoading) {
          return _buildLoadingState();
        }

        // 인증이 필요한 경우
        if (!authProvider.isAuthenticated) {
          return _buildUnauthenticatedState(authProvider, theme);
        }

        // 플래너가 없을 때
        if (plannerProvider.planners.isEmpty) {
          return _buildEmptyPlannerState(plannerProvider, theme);
        }

        // 플래너가 있을 때
        return _buildPlannerContent(plannerProvider, theme);
      },
    );
  }

  // 로딩 상태 UI
  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  // 인증 필요 상태 UI
  Widget _buildUnauthenticatedState(
    AuthProvider authProvider,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: theme.colorScheme.primary.shade700,
            ),
            const SizedBox(height: 24),
            Text(
              '플래너 사용을 위해\n로그인이 필요합니다',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '로그인하고 나만의 플래너를 관리해보세요.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: '로그인하기',
              icon: Icons.login,
              variant: ButtonVariant.primary,
              size: ButtonSize.large,
              rounded: true,
              onPressed: () {
                // 계정 페이지로 이동
                widget.onTabChange!(3);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 빈 플래너 상태 UI
  Widget _buildEmptyPlannerState(
    PlannerProvider plannerProvider,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 80,
              color: theme.colorScheme.primary.shade700,
            ),
            const SizedBox(height: 24),
            Text(
              '플래너가 없습니다',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '새 플래너를 추가하고 일정 관리를 시작하세요.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: '새 플래너 만들기',
              icon: Icons.add,
              variant: ButtonVariant.primary,
              size: ButtonSize.large,
              rounded: true,
              onPressed:
                  () => _showCreatePlannerDialog(context, plannerProvider),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('새로고침'),
              onPressed: () => plannerProvider.loadPlanners(),
            ),
          ],
        ),
      ),
    );
  }

  // 플래너 컨텐츠 UI
  Widget _buildPlannerContent(
    PlannerProvider plannerProvider,
    ThemeData theme,
  ) {
    final planners = plannerProvider.planners;
    final selectedPlanner = plannerProvider.selectedPlanner;
    final tasks = plannerProvider.tasks;

    return Column(
      children: [
        // 탭바
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.shade50,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            tabs:
              planners.map((planner) {
                return Tab(text: planner.name);
              }).toList(),
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 3.0,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.shade700,
            labelStyle: theme.textTheme.titleSmall,
            isScrollable: planners.length > 3, // 탭이 3개 초과일 때 스크롤 가능
          ),
        ),

        // 헤더 (선택된 플래너 정보)
        if (selectedPlanner != null)
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedPlanner.name,
                      style: theme.textTheme.titleLarge,
                    ),
                    Text(
                      '${tasks.where((task) => task.isCompleted == 1).length}/${tasks.length} 완료됨',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.shade700,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed:
                    () => _showPlannerOptions(
                      context,
                      selectedPlanner,
                      plannerProvider,
                    ),
                ),
              ],
            ),
          ),

        // 작업 목록
        Expanded(
          child:
              tasks.isEmpty
                  ? _buildEmptyTaskState(selectedPlanner, theme)
                  : _buildTaskList(tasks, plannerProvider, theme),
        ),
      ],
    );
  }

  // 빈 작업 상태 UI
  Widget _buildEmptyTaskState(Planner? planner, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: theme.colorScheme.primary.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              '아직 작업이 없습니다',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '새 작업을 추가하고 일정을 관리하세요.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: '새 작업 추가',
              icon: Icons.add,
              variant: ButtonVariant.primary,
              onPressed: () => _navigateToAddTask(planner),
            ),
          ],
        ),
      ),
    );
  }

  // 작업 목록 UI
  Widget _buildTaskList(
    List<Task> tasks,
    PlannerProvider plannerProvider,
    ThemeData theme,
  ) {
    return RefreshIndicator(
      onRefresh: () => plannerProvider.loadTasks(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80.0), // FAB 위치 고려
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _buildTaskItem(task, plannerProvider, theme);
        },
      ),
    );
  }

  // 작업 아이템 UI
  Widget _buildTaskItem(
    Task task,
    PlannerProvider plannerProvider,
    ThemeData theme,
  ) {
    final isCompleted = task.isCompleted == 1;

    return Slidable(
      key: ValueKey(task.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _deleteTask(task, plannerProvider),
            backgroundColor: theme.colorScheme.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '삭제',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        elevation: isCompleted ? 0 : 2,
        color:
          isCompleted
            ? theme.colorScheme.surface.shade700
            : theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(
            color: _getPriorityColor(isCompleted, task.priority, theme),
            width: 2.0,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          title: Text(
            task.contents,
            style: theme.textTheme.bodyLarge?.copyWith(
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              color:
                isCompleted
                  ? theme.colorScheme.onSurface.shade500
                  : theme.colorScheme.onSurface,
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
                  color: _getPriorityColor(isCompleted, task.priority, theme),
                ),
              ),
              const SizedBox(width: 8),
              Checkbox(
                value: isCompleted,
                activeColor: theme.colorScheme.primary,
                onChanged:
                    (value) => _toggleTaskCompletion(task, plannerProvider),
              ),
            ],
          ),
          onTap: () => _navigateToEditTask(task, plannerProvider),
        ),
      ),
    );
  }

  // 우선순위 색상 가져오기
  Color _getPriorityColor(bool isCompleted, int priority, ThemeData theme) {
    if (isCompleted) {
      return theme.disabledColor; // 완료된 작업은 회색
    }
    switch (priority) {
      case 0:
        return Colors.blue.shade500; // 낮음
      case 1:
        return Colors.orange.shade500; // 중간
      case 2:
        return Colors.red.shade500; // 높음
      default:
        return theme.disabledColor; // 기본값
    }
  }

  // 작업 완료 상태 토글
  Future<void> _toggleTaskCompletion(
    Task task,
    PlannerProvider plannerProvider,
  ) async {
    try {
      // 상태 반전
      final newState = task.isCompleted == 0 ? 1 : 0;
      final updatedTask = Task(
        id: task.id,
        contents: task.contents,
        priority: task.priority,
        from: task.from,
        isCompleted: newState,
      );

      await plannerProvider.updateTask(updatedTask);
    } catch (e) {
      if (mounted) {
        showSnackBar(context, '작업 상태 변경 중 오류가 발생했습니다: $e');
      }
    }
  }

  // 작업 삭제
  Future<void> _deleteTask(Task task, PlannerProvider plannerProvider) async {
    // 확인 다이얼로그
    final confirm = await showDialog<bool>(
      context: context,
      builder:
        (context) => AlertDialog(
          title: const Text('작업 삭제'),
          content: Text('정말 "${task.contents}" 작업을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제'),
            ),
          ],
        ),
    );

    if (confirm == true) {
      try {
        await plannerProvider.deleteTask(task.id!);
        if (mounted) {
          showSnackBar(context, '작업이 삭제되었습니다.');
        }
      } catch (e) {
        if (mounted) {
          showSnackBar(context, '작업 삭제 중 오류가 발생했습니다: $e');
        }
      }
    }
  }

  // 작업 추가 화면으로 이동
  Future<void> _navigateToAddTask(Planner? planner) async {
    if (planner == null) return;

    final plannerProvider = Provider.of<PlannerProvider>(
      context,
      listen: false,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddTaskScreen(
              updateTaskList: plannerProvider.loadTasks,
              selectedPlannerId: planner.id,
            ),
      ),
    );

    if (result == true) {
      plannerProvider.loadTasks();
    }
  }

  // 작업 수정 화면으로 이동
  Future<void> _navigateToEditTask(
    Task task,
    PlannerProvider plannerProvider,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddTaskScreen(
              updateTaskList: plannerProvider.loadTasks,
              task: task,
              selectedPlannerId: task.from,
            ),
      ),
    );

    if (result == true) {
      plannerProvider.loadTasks();
    }
  }

  // 플래너 옵션 팝업 메뉴
  void _showPlannerOptions(
    BuildContext context,
    Planner planner,
    PlannerProvider plannerProvider,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
        (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('새 작업 추가'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToAddTask(planner);
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('새로고침'),
                onTap: () {
                  Navigator.pop(context);
                  plannerProvider.loadTasks();
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('플래너 이름 변경'),
                onTap: () {
                  Navigator.pop(context);
                  _showRenamePlannerDialog(context, planner, plannerProvider);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: theme.colorScheme.error),
                title: Text(
                  '플래너 삭제',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeletePlannerDialog(context, planner, plannerProvider);
                },
              ),
            ],
          ),
        ),
    );
  }

  // 플래너 생성 다이얼로그
  Future<void> _showCreatePlannerDialog(
    BuildContext context,
    PlannerProvider plannerProvider,
  ) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder:
        (context) => AlertDialog(
          title: const Text('새 플래너 추가'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '플래너 이름',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: const Text('추가'),
            ),
          ],
        ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await plannerProvider.createPlanner(result);
        if (mounted) {
          showSnackBar(context, '플래너가 추가되었습니다.');
        }
      } catch (e) {
        if (mounted) {
          showSnackBar(context, '플래너 추가 중 오류가 발생했습니다: $e');
        }
      }
    }
  }

  // 플래너 이름 변경 다이얼로그
  Future<void> _showRenamePlannerDialog(
    BuildContext context,
    Planner planner,
    PlannerProvider plannerProvider,
  ) async {
    final controller = TextEditingController(text: planner.name);

    final result = await showDialog<String>(
      context: context,
      builder:
        (context) => AlertDialog(
          title: const Text('플래너 이름 변경'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '새 플래너 이름',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: const Text('변경'),
            ),
          ],
        ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await plannerProvider.renamePlanner(planner.id, result);
        if (mounted) {
          showSnackBar(context, '플래너 이름이 변경되었습니다.');
        }
      } catch (e) {
        if (mounted) {
          showSnackBar(context, '플래너 이름 변경 중 오류가 발생했습니다: $e');
        }
      }
    }
  }

  // 플래너 삭제 확인 다이얼로그
  Future<void> _showDeletePlannerDialog(
    BuildContext context,
    Planner planner,
    PlannerProvider plannerProvider,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
        (context) => AlertDialog(
          title: const Text('플래너 삭제'),
          content: Text(
            '정말 "${planner.name}" 플래너를 삭제하시겠습니까?\n'
            '이 플래너의 모든 작업도 함께 삭제됩니다.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제'),
            ),
          ],
        ),
    );

    if (confirm == true) {
      try {
        await plannerProvider.deletePlanner(planner.id);
        if (mounted) {
          showSnackBar(context, '플래너가 삭제되었습니다.');
        }
      } catch (e) {
        if (mounted) {
          showSnackBar(context, '플래너 삭제 중 오류가 발생했습니다: $e');
        }
      }
    }
  }
}
