import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/theme/app_theme.dart';

/// 앱 전체에서 사용하는 입력 필드 컴포넌트
/// 라벨, 오류 메시지, 부동 라벨 등을 지원
class AppTextField extends StatefulWidget {
  final String label;
  final String? placeholder;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool autofocus;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool readOnly;

  const AppTextField({
    Key? key,
    required this.label,
    this.placeholder,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.contentPadding,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
    this.readOnly = false,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _hasText = widget.controller.text.isNotEmpty;

    // 포커스 상태 리스너
    _focusNode.addListener(_handleFocusChange);

    // 텍스트 변경 리스너
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode.dispose();
    }
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleTextChange() {
    final hasText = widget.controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFloating = _isFocused || _hasText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 라벨 텍스트
        if (widget.label.isNotEmpty && !isFloating)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
            child: Text(widget.label, style: theme.textTheme.labelMedium),
          ),

        // 입력 필드
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: _isFocused ? AppTheme.lightShadow : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            autofocus: widget.autofocus,
            enabled: widget.enabled,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            style: theme.textTheme.bodyLarge,
            inputFormatters: widget.inputFormatters,
            textInputAction: widget.textInputAction,
            readOnly: widget.readOnly,
            decoration: InputDecoration(
              labelText: isFloating ? widget.label : null,
              hintText: widget.placeholder,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.hintColor,
              ),
              contentPadding:
                  widget.contentPadding ??
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline,
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.shade800,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: theme.primaryColor, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 2.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 2.0,
                ),
              ),
              errorText: widget.errorText,
              errorStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor:
                  widget.enabled
                      ? theme.colorScheme.surface
                      : theme.disabledColor.shade100,
            ),
          ),
        ),
      ],
    );
  }
}

/// 드롭다운 필드 (학년/반 선택 등에 사용)
class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final String? errorText;
  final bool enabled;
  final String? hint;

  const AppDropdownField({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 라벨 텍스트
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
            child: Text(label, style: theme.textTheme.labelMedium),
          ),

        // 드롭다운 필드
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: AppTheme.lightShadow,
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: enabled ? onChanged : null,
            decoration: InputDecoration(
              hintText: hint,
              errorText: errorText,
              errorStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              filled: true,
              fillColor:
                  enabled
                      ? theme.colorScheme.surface
                      : theme.disabledColor.shade100,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 12.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline,
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.shade800,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: theme.primaryColor, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 2.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 2.0,
                ),
              ),
            ),
            style: theme.textTheme.bodyLarge,
            icon: Icon(
              Icons.arrow_drop_down_circle,
              color: enabled ? theme.colorScheme.primary : theme.disabledColor,
            ),
            isDense: true,
            isExpanded: true,
            dropdownColor: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10.0),
            menuMaxHeight: 300,
          ),
        ),
      ],
    );
  }
}

/// 학년/반 드롭다운 컨테이너
/// 웹 버전의 GradeClassDropdown 컴포넌트와 동일한 기능
class GradeClassDropdown extends StatelessWidget {
  final String? grade;
  final String? classValue;
  final Function(String?) onGradeChanged;
  final Function(String?) onClassChanged;
  final String? gradeError;
  final String? classError;
  final bool enabled;

  const GradeClassDropdown({
    Key? key,
    this.grade,
    this.classValue,
    required this.onGradeChanged,
    required this.onClassChanged,
    this.gradeError,
    this.classError,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 학년 드롭다운
        Expanded(
          child: AppDropdownField<String>(
            label: '학년',
            value: grade,
            items: const [
              DropdownMenuItem<String>(value: '1', child: Text('1학년')),
              DropdownMenuItem<String>(value: '2', child: Text('2학년')),
              DropdownMenuItem<String>(value: '3', child: Text('3학년')),
            ],
            onChanged: onGradeChanged,
            errorText: gradeError,
            enabled: enabled,
            hint: '학년 선택',
          ),
        ),
        const SizedBox(width: 16.0),
        // 반 드롭다운
        Expanded(
          child: AppDropdownField<String>(
            label: '반',
            value: classValue,
            items: const [
              DropdownMenuItem<String>(value: '1', child: Text('1반')),
              DropdownMenuItem<String>(value: '2', child: Text('2반')),
              DropdownMenuItem<String>(value: '3', child: Text('3반')),
              DropdownMenuItem<String>(value: '4', child: Text('4반')),
              DropdownMenuItem<String>(value: '5', child: Text('5반')),
              DropdownMenuItem<String>(value: '6', child: Text('6반')),
            ],
            onChanged: onClassChanged,
            errorText: classError,
            enabled: enabled,
            hint: '반 선택',
          ),
        ),
      ],
    );
  }
}
