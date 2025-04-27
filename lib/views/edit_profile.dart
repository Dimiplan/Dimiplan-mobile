import 'package:flutter/material.dart';
import 'package:dimiplan/internal/database.dart';
import 'package:dimiplan/internal/model.dart';

class EditProfileScreen extends StatefulWidget {
  final Function updateUserInfo;
  final User? user;

  const EditProfileScreen({super.key, required this.updateUserInfo, this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String? _name;
  late String? _email;
  late int? _grade;
  late int? _classnum;
  late String? _profileImage;

  final List<int> _grades = [1, 2, 3];
  final List<int> _classnums = List.generate(6, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    _name = widget.user?.name;
    _email = widget.user?.email;
    _grade = widget.user?.grade;
    _classnum = widget.user?.classnum;
    _profileImage = widget.user?.profile_image;
  }

  _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      User updatedUser = User(
        id: widget.user!.id,
        email: _email!,
        name: _name!,
        grade: _grade,
        classnum: _classnum,
        profile_image: _profileImage!,
      );

      // Update the user in database
      db.updateUser(updatedUser);

      widget.updateUserInfo();
      Navigator.pop(context);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요.';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '유효한 이메일 주소를 입력해주세요.';
    }

    return null;
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
              '회원정보 수정',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [IconButton(icon: Icon(Icons.info_outline), onPressed: () {})],
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
                          onSaved: (input) => _name = input!,
                          initialValue: _name,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: '이메일',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: _validateEmail,
                          onSaved: (input) => _email = input!,
                          initialValue: _email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal: 5.0,
                              ),
                              child: DropdownButtonFormField<int>(
                                isDense: true,
                                icon: Icon(Icons.arrow_drop_down_circle),
                                iconSize: 22.0,
                                items:
                                    _grades.map((int grade) {
                                      return DropdownMenuItem(
                                        value: grade,
                                        child: Text(
                                          '$grade학년',
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                style: TextStyle(fontSize: 18.0),
                                decoration: InputDecoration(
                                  labelText: '학년',
                                  labelStyle: TextStyle(fontSize: 18.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _grade = value;
                                  });
                                },
                                value: _grade,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal: 5.0,
                              ),
                              child: DropdownButtonFormField<int>(
                                isDense: true,
                                icon: Icon(Icons.arrow_drop_down_circle),
                                iconSize: 22.0,
                                items:
                                    _classnums.map((int classnum) {
                                      return DropdownMenuItem(
                                        value: classnum,
                                        child: Text(
                                          '$classnum반',
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                style: TextStyle(fontSize: 18.0),
                                decoration: InputDecoration(
                                  labelText: '반',
                                  labelStyle: TextStyle(fontSize: 18.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _classnum = value;
                                  });
                                },
                                value: _classnum,
                              ),
                            ),
                          ),
                        ],
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
                            '수정 완료',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
