import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

class Interest {
  final int categoryId;
  final String categoryName;
  final IconData icon;

  Interest({
    required this.categoryId,
    required this.categoryName,
    required this.icon,
  });

  // JSON 데이터를 Interest 객체로 변환
  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      icon: Interest.getIconForCategory(json['categoryId']),
    );
  }

  // 카테고리 ID에 따른 아이콘 반환
  static IconData getIconForCategory(int categoryId) {
    switch (categoryId) {
      case 1:
        return Icons.how_to_vote_outlined; // 정치
      case 2:
        return Icons.trending_up_outlined; // 경제
      case 3:
        return Icons.groups_outlined; // 사회
      case 4:
        return Ionicons.earth_sharp; // 국제
      case 5:
        return Icons.sports_basketball_outlined; // 스포츠
      case 6:
        return Icons.palette_outlined; // 문화/예술
      case 7:
        return Icons.science_outlined; // 과학/기술
      case 8:
        return Ionicons.fitness_outline; // 건강/의료
      case 9:
        return Icons.mic_external_on_outlined; // 연예/오락
      case 10:
        return Typicons.leaf; // 환경
      default:
        return Icons.help_outline; // 기본 아이콘
    }
  }
}
