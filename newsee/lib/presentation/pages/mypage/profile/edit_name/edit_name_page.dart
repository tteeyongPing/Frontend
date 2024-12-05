import 'package:flutter/material.dart';
import 'package:newsee/services/my_page/edit_name_service.dart';

class EditNamePage extends StatefulWidget {
  @override
  EditNamePageState createState() => EditNamePageState();
}

class EditNamePageState extends State<EditNamePage> {
  final TextEditingController _controller = TextEditingController();
  final double _paddingValue = 16.0;
  late double _screenWidth;

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: buildAppBar(),
      body: Padding(
        padding: EdgeInsets.all(_paddingValue),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        '닉네임 변경',
        style: TextStyle(color: Colors.black, fontSize: 20),
      ),
      centerTitle: true,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Divider(color: Colors.grey, thickness: 1.0, height: 1.0),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: const [
        Divider(color: Colors.grey, thickness: 1, height: 1),
        SizedBox(height: 24),
        Text(
          '닉네임 변경',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 8),
        Text(
          '변경할 이름을 입력해주세요.',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildTextField(),
          const SizedBox(height: 20),
          buildSaveButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget buildTextField() {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        hintText: '이름을 입력하세요',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => setState(() {}),
    );
  }

  Widget buildSaveButton() {
    return SizedBox(
      width: _screenWidth * 0.9,
      height: _screenWidth * 0.14,
      child: ElevatedButton(
        onPressed: _controller.text.isEmpty
            ? null
            : () => patchNickname(_controller.text),
        child: Text(
          '저장하기',
          style: TextStyle(color: Colors.white, fontSize: _screenWidth * 0.04),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0038FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
