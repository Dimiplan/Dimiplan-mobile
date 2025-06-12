import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dimiplan/providers/planner_provider.dart';
import 'package:dimiplan/providers/auth_provider.dart';
import 'package:dimiplan/models/planner_models.dart';
import 'package:dimiplan/views/add_task.dart';
import 'package:dimiplan/widgets/state_widgets.dart';
import 'package:dimiplan/widgets/list_widgets.dart';
import 'package:dimiplan/widgets/navigation_widgets.dart';
import 'package:dimiplan/utils/dialog_utils.dart';
import 'package:dimiplan/utils/snackbar_util.dart';
import 'package:dimiplan/widgets/loading_indicator.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key, this.onTabChange});
  final void Function(int)? onTabChange;

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
    _initializeTabController();
  }

  @override
  void didUpdateWidget(covariant PlannerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTabController();
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _tabController.dispose();
    }
    super.dispose();
  }

  void _initializeTabController() {
    final plannerProvider = Provider.of<PlannerProvider>(context);
    final planners = plannerProvider.planners;

    if (planners.isNotEmpty && !_isInitialized) {
      _tabController = TabController(length: planners.length, vsync: this);
      _tabController.addListener(_onTabChanged);
      plannerProvider.selectPlanner(planners[0]);
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _updateTabController() {
    final plannerProvider = Provider.of<PlannerProvider>(context);
    final planners = plannerProvider.planners;

    if (planners.isNotEmpty && _isInitialized) {
      _tabController.dispose();
      _tabController = TabController(length: planners.length, vsync: this);
      _tabController.addListener(_onTabChanged);
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final plannerProvider = Provider.of<PlannerProvider>(context, listen: false);
      final planners = plannerProvider.planners;
      plannerProvider.selectPlanner(planners[_tabController.index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AuthProvider, bool>(
      selector: (context, auth) => auth.isAuthenticated,
      builder: (context, isAuthenticated, child) {
        if (!isAuthenticated) {
          return UnauthenticatedState(
            title: '플래너 사용을 위해\n로그인이 필요합니다',
            subtitle: '로그인하고 나만의 플래너를 관리해보세요.',
            actionText: '로그인하기',
            onAction: () => widget.onTabChange!(3),
          );
        }

        return Selector<PlannerProvider, ({bool isLoading, List<Planner> planners})>(
          selector: (context, planner) => (
            isLoading: planner.isLoading,
            planners: planner.planners,
          ),
          builder: (context, plannerData, child) {
            if (plannerData.isLoading) {
              return const TaskListSkeleton();
            }

            if (plannerData.planners.isEmpty) {
              return Consumer<PlannerProvider>(
                builder: (context, plannerProvider, _) => EmptyState(
                  title: '플래너가 없습니다',
                  subtitle: '새 플래너를 추가하고 일정 관리를 시작하세요.',
                  actionText: '새 플래너 만들기',
                  onAction: () => _showCreatePlannerDialog(plannerProvider),
                  icon: Icons.folder_open,
                  secondaryActionText: '새로고침',
                  onSecondaryAction: () => plannerProvider.loadPlanners(),
                ),
              );
            }

            return Consumer<PlannerProvider>(
              builder: (context, plannerProvider, _) => _buildPlannerContent(plannerProvider),
            );
          },
        );
      },
    );
  }

  Widget _buildPlannerContent(PlannerProvider plannerProvider) {
    final planners = plannerProvider.planners;
    final selectedPlanner = plannerProvider.selectedPlanner;
    final tasks = plannerProvider.tasks;

    return Column(
      children: [
        AppTabBar(
          controller: _tabController,
          tabNames: planners.map((p) => p.name).toList(),
          isScrollable: planners.length > 3,
        ),

        if (selectedPlanner != null)
          Selector<PlannerProvider, List<Task>>(
            selector: (context, planner) => planner.tasks,
            builder: (context, tasks, child) => SectionHeader(
              title: selectedPlanner.name,
              subtitle: '${tasks.where((task) => task.isCompleted == 1).length}/${tasks.length} 완료됨',
              action: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showPlannerOptions(selectedPlanner, plannerProvider),
              ),
            ),
          ),

        // 작업 목록
        Expanded(
          child: tasks.isEmpty
              ? EmptyState(
                  title: '아직 작업이 없습니다',
                  subtitle: '새 작업을 추가하고 일정을 관리하세요.',
                  actionText: '새 작업 추가',
                  onAction: () => _navigateToAddTask(selectedPlanner),
                  icon: Icons.task_alt,
                )
              : _buildTaskList(tasks, plannerProvider),
        ),
      ],
    );
  }

  Widget _buildTaskList(List<Task> tasks, PlannerProvider plannerProvider) {
    return RefreshIndicator(
      onRefresh: () => plannerProvider.loadTasks(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80.0),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskListItem(
            task: task,
            onToggleComplete: (task) => _toggleTaskCompletion(task, plannerProvider),
            onEdit: (task) => _navigateToEditTask(task, plannerProvider),
            onDelete: (task) => _deleteTask(task, plannerProvider),
          );
        },
      ),
    );
  }

  void _showPlannerOptions(Planner planner, PlannerProvider plannerProvider) {
    OptionsBottomSheet.show(
      context: context,
      options: [
        OptionItem(
          title: '새 작업 추가',
          icon: Icons.playlist_add,
          onTap: () => _navigateToAddTask(planner),
        ),
        OptionItem(
          title: '새로고침',
          icon: Icons.refresh,
          onTap: () => plannerProvider.loadTasks(),
        ),
        OptionItem(
          title: '플래너 이름 변경',
          icon: Icons.edit,
          onTap: () => _showRenamePlannerDialog(planner, plannerProvider),
        ),
        OptionItem(
          title: '플래너 삭제',
          icon: Icons.delete,
          onTap: () => _showDeletePlannerDialog(planner, plannerProvider),
          isDestructive: true,
        ),
      ],
    );
  }

  Future<void> _navigateToAddTask(Planner? planner) async {
    if (planner == null) return;

    final plannerProvider = Provider.of<PlannerProvider>(context, listen: false);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(
          updateTaskList: plannerProvider.loadTasks,
          selectedPlannerId: planner.id,
        ),
      ),
    );

    if (result == true) {
      plannerProvider.loadTasks();
    }
  }

  Future<void> _navigateToEditTask(Task task, PlannerProvider plannerProvider) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(
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

  Future<void> _toggleTaskCompletion(Task task, PlannerProvider plannerProvider) async {
    try {
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

  Future<void> _deleteTask(Task task, PlannerProvider plannerProvider) async {
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

  Future<void> _showCreatePlannerDialog(PlannerProvider plannerProvider) async {
    final result = await DialogUtils.showInputDialog(
      context: context,
      title: '새 플래너 추가',
      hintText: '플래너 이름',
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

  Future<void> _showRenamePlannerDialog(Planner planner, PlannerProvider plannerProvider) async {
    final result = await DialogUtils.showInputDialog(
      context: context,
      title: '플래너 이름 변경',
      initialValue: planner.name,
      hintText: '새 플래너 이름',
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

  Future<void> _showDeletePlannerDialog(Planner planner, PlannerProvider plannerProvider) async {
    final confirm = await DialogUtils.showConfirmDialog(
      context: context,
      title: '플래너 삭제',
      content: '정말 "${planner.name}" 플래너를 삭제하시겠습니까?\n이 플래너의 모든 작업도 함께 삭제됩니다.',
      confirmText: '삭제',
      confirmColor: Theme.of(context).colorScheme.error,
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