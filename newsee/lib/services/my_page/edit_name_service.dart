import 'package:http/http.dart' as http;
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:newsee/utils/auth_utils.dart';

// 닉네임 업데이트를 위한 API 호출
Future<String> patchNickname(String nickname) async {
  try {
    final credentials = await getTokenAndUserId();
    String? token = credentials['token'];

    var url = Uri.parse(
        '${RootUrlProvider.baseURL}/user/nickname/edit?nickname=$nickname');
    var response = await http.patch(
      url,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return '닉네임 변경 성공';
    } else if (response.statusCode == 409) {
      return '이미 존재하는 닉네임입니다. 다른 닉네임을 사용해주세요.';
    } else {
      return '닉네임 변경을 실패했습니다.';
    }
  } catch (e) {
    return '저장 중 오류가 발생했습니다: $e';
  }
}
