import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/models/user_model.dart';
import 'package:dimiplan/providers/auth_provider.dart';
import 'package:dimiplan/widgets/button.dart';
import 'package:dimiplan/widgets/input_field.dart';
import 'package:dimiplan/utils/snackbar_util.dart';
import 'package:dimiplan/utils/validation_utils.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    required this.user,
    required this.updateUserInfo,
    super.key,
  });
  final User user;
  final Function updateUserInfo;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedGrade;
  String? _selectedClass;
  bool _isSubmitting = false;
  bool _isDimigoStudent = false;
  String? _nameError;
  String? _gradeError;
  String? _classError;

  @override
  void initState() {
    super.initState();

    // 현재 사용자 정보로 필드 초기화
    _nameController.text = widget.user.name;
    _selectedGrade = widget.user.grade?.toString();
    _selectedClass = widget.user.classnum?.toString();
    _isDimigoStudent = widget.user.email.endsWith('@dimigo.hs.kr');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 폼 검증
  bool _validateForm() {
    bool isValid = true;

    // 이름 검증
    final nameError = ValidationUtils.validateLength(
      _nameController.text,
      2,
      15,
      '이름',
    );
    setState(() {
      _nameError = nameError;
    });
    if (nameError != null) isValid = false;

    // 디미고 학생인 경우 학년/반 검증
    if (_isDimigoStudent) {
      if (_selectedGrade == null) {
        setState(() {
          _gradeError = '학년을 선택해 주세요.';
        });
        isValid = false;
      } else {
        setState(() {
          _gradeError = null;
        });
      }

      if (_selectedClass == null) {
        setState(() {
          _classError = '반을 선택해 주세요.';
        });
        isValid = false;
      } else {
        setState(() {
          _classError = null;
        });
      }
    }

    return isValid;
  }

  // 프로필 업데이트 제출
  Future<void> _submitUpdate() async {
    if (!_validateForm()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // 업데이트할 사용자 정보 생성
      final Map<String, dynamic> userData = {
        'name': _nameController.text.trim(),
      };

      // 디미고 학생인 경우 학년/반 추가
      if (_isDimigoStudent) {
        userData['grade'] = int.parse(_selectedGrade!);
        userData['class'] = int.parse(_selectedClass!);
      }

      // 사용자 정보 업데이트
      await authProvider.updateUser(userData);

      // 콜백 호출
      widget.updateUserInfo();

      if (mounted) {
        showSuccessSnackBar(context, '프로필이 성공적으로 업데이트되었습니다.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, '프로필 업데이트 중 오류가 발생했습니다: $e');
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('회원정보 수정', style: theme.textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 사용자 이미지 (Hero 애니메이션 적용)
                  Center(
                    child: Hero(
                      tag: 'profile_image',
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(widget.user.profileImage),
                        backgroundColor: theme.colorScheme.primaryContainer,
                        onBackgroundImageError: (_, __) {},
                        child:
                            widget.user.profileImage.isEmpty
                                ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: theme.colorScheme.onPrimaryContainer,
                                )
                                : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 이메일 표시 (변경 불가)
                  Text('이메일', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.shade500,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: theme.colorScheme.outline.shade500,
                      ),
                    ),
                    child: Text(
                      widget.user.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 이름 입력 필드
                  Text('이름', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  AppTextField(
                    label: '',
                    controller: _nameController,
                    errorText: _nameError,
                    placeholder: '이름을 입력하세요',
                    onChanged: (_) => setState(() => _nameError = null),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 24),

                  // 디미고 학생인 경우 학년/반 선택 필드
                  if (_isDimigoStudent) ...[
                    Text('학년 및 반', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    GradeClassDropdown(
                      grade: _selectedGrade,
                      classValue: _selectedClass,
                      onGradeChanged: (value) {
                        setState(() {
                          _selectedGrade = value;
                          _gradeError = null;
                        });
                      },
                      onClassChanged: (value) {
                        setState(() {
                          _selectedClass = value;
                          _classError = null;
                        });
                      },
                      gradeError: _gradeError,
                      classError: _classError,
                    ),
                  ],
                  const SizedBox(height: 40),

                  // 저장 버튼
                  Center(
                    child: AppButton(
                      text: '저장',
                      isLoading: _isSubmitting,
                      size: ButtonSize.large,
                      rounded: true,
                      onPressed: _submitUpdate,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
