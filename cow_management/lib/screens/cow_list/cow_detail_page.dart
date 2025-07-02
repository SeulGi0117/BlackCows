import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:cow_management/utils/api_config.dart';
import 'package:logging/logging.dart';
import 'package:cow_management/models/cow.dart';
import 'package:cow_management/screens/cow_list/cow_edit_page.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/utils/error_utils.dart';
import 'package:cow_management/screens/cow_list/cow_detailed_records_page.dart';
import 'package:cow_management/providers/cow_provider.dart';

class CowDetailPage extends StatefulWidget {
  final Cow cow;
  static final _logger = Logger('CowDetailPage');

  const CowDetailPage({super.key, required this.cow});

  @override
  State<CowDetailPage> createState() => _CowDetailPageState();
}

class _CowDetailPageState extends State<CowDetailPage> {
  late Cow currentCow;

  @override
  void initState() {
    super.initState();
    currentCow = widget.cow;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${currentCow.name} 상세 정보'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          TextButton.icon(
            onPressed: () async {
              await showDeleteCowDialog(context, currentCow.name, () async {
                final success = await deleteCow(context, currentCow.id);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("젖소가 삭제되었습니다"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, true);
                }
                // 실패 시에는 deleteCow 함수에서 이미 ErrorUtils로 처리됨
              });
            },
            icon: const Icon(Icons.delete, color: Colors.white),
            label: const Text(
              '삭제하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoCard(),
            const SizedBox(height: 20),
            if (currentCow.hasLivestockTraceData)
              _buildLivestockTraceInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    const infoStyle = TextStyle(fontWeight: FontWeight.w500);
    const valueStyle = TextStyle(color: Colors.black87);

    Widget buildInfoRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90,
              child: Text(label, style: infoStyle),
            ),
            Expanded(
              child: Text(value.isNotEmpty ? value : '미등록', style: valueStyle),
            ),
          ],
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.grey.shade50,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🐾 기본 정보',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            buildInfoRow('이름', currentCow.name),
            buildInfoRow('이표번호', currentCow.earTagNumber),
            buildInfoRow(
                '출생일',
                currentCow.birthdate != null
                    ? '${currentCow.birthdate!.year}년 ${currentCow.birthdate!.month}월 ${currentCow.birthdate!.day}일'
                    : '미등록'),
            buildInfoRow('품종', currentCow.breed ?? '미등록'),
            if (currentCow.sensorNumber != null &&
                currentCow.sensorNumber!.isNotEmpty)
              buildInfoRow('센서번호', currentCow.sensorNumber!),
            buildInfoRow('건강상태', _getHealthStatusText(currentCow.healthStatus)),
            buildInfoRow(
                '번식상태', _getBreedingStatusText(currentCow.breedingStatus)),
            if (currentCow.notes != null && currentCow.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('📝 메모',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(currentCow.notes!,
                    style: const TextStyle(fontSize: 14)),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CowEditPage(cow: currentCow),
                        ),
                      ).then((updatedCow) {
                        if (updatedCow != null) {
                          setState(() => currentCow = updatedCow);
                        }
                      });
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('정보 수정'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CowDetailedRecordsPage(cow: currentCow),
                        ),
                      );
                    },
                    icon: const Icon(Icons.assignment, size: 18),
                    label: const Text('상세 기록'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF81C784),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            final confirmed = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("삭제 확인"),
                content: const Text("정말 이 젖소를 삭제하시겠습니까?"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("취소")),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("삭제")),
                ],
              ),
            );

            if (confirmed == true) {
              final success = await deleteCow(context, currentCow.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("젖소가 삭제되었습니다"),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context, true);
              }
              // 실패 시에는 deleteCow 함수에서 이미 ErrorUtils로 처리됨
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("❌ 삭제하기   "),
        ),
      ],
    );
  }

  Future<bool> deleteCow(BuildContext context, String cowId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final cowProvider = Provider.of<CowProvider>(context, listen: false);
    final token = userProvider.accessToken;

    if (token == null) {
      CowDetailPage._logger.severe("토큰 없음");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정 오류: 인증 토큰이 없습니다')),
        );
      }
      return false;
    }

    try {
      await cowProvider.deleteCow(cowId, token);
      return true;
    } catch (e) {
      CowDetailPage._logger.severe("삭제 중 오류 발생: $e");

      if (context.mounted) {
        ErrorUtils.handleError(
          context,
          e,
          customMessage: '젖소 삭제 중 오류가 발생했습니다',
          defaultMessage: '삭제에 실패했습니다',
        );
      }
      return false;
    }
  }

  Future<void> showDeleteCowDialog(
      BuildContext context, String cowName, VoidCallback onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('정말로 삭제하시겠습니까?',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('젖소 "$cowName"을(를) 삭제하면,'),
              const SizedBox(height: 8),
              const Text(
                '• 이 젖소와 관련된 모든 데이터(기록 등)가 데이터베이스에서 완전히 삭제됩니다.',
                style: TextStyle(color: Colors.redAccent),
              ),
              const SizedBox(height: 4),
              const Text(
                '• 삭제된 데이터는 복구할 수 없습니다.',
                style: TextStyle(color: Colors.redAccent),
              ),
              const SizedBox(height: 16),
              const Text('정말로 삭제하시겠습니까?'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('영구 삭제', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  // 축산물이력제 상세 정보 카드 추가
  Widget _buildLivestockTraceInfoCard() {
    final data = currentCow.livestockTraceData ?? {};
    // 데이터 파싱 (API 구조에 맞게 key 수정 필요)
    final earTag = data['earTag'] ?? currentCow.earTagNumber;
    final birthDate = data['birthDate'] ??
        currentCow.birthdate?.toString().split(' ')[0] ??
        '-';
    final ageMonth = data['ageMonth'] ?? '-';
    final ownerMasked = data['ownerMasked'] ?? '-';
    final farmId = data['farmId'] ?? '-';
    final farmAddress = data['farmAddress'] ?? '-';
    final birthReportDate = data['birthReportDate'] ?? '-';
    final birthRegistrar = data['birthRegistrar'] ?? '-';
    final birthReportAddress = data['birthReportAddress'] ?? '-';
    final vaccineInfo = data['vaccineInfo'] ?? {};
    final fmd = vaccineInfo['fmd'] ?? '-';
    final brucellaMove = vaccineInfo['brucellaMove'] ?? '-';
    final brucellaSlaughter = vaccineInfo['brucellaSlaughter'] ?? '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔍 축산물이력제 정보',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(children: [
              const Text('이표번호: ',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text(earTag)
            ]),
            Row(children: [
              const Text('개월령: ',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text(ageMonth)
            ]),
            Row(children: [
              const Text('출생일: ',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text(birthDate)
            ]),
            Row(children: [
              const Text('농가정보: ',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text('$ownerMasked ($farmId)')
            ]),
            Row(children: [
              const Text('목장주소: ',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text(farmAddress)
            ]),
            const SizedBox(height: 10),
            const Text('출생신고 정보',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: [
              const Text('등록자: ',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text(birthRegistrar)
            ]),
            Row(children: [
              const Text('등록일: ',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text(birthReportDate)
            ]),
            Row(children: [
              const Text('등록지: ',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text(birthReportAddress)
            ]),
            const SizedBox(height: 10),
            const Text('백신/질병검사 정보',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: [
              const Text('구제역: ',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text(fmd)
            ]),
            Row(children: [
              const Text('브루셀라 이동: ',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text(brucellaMove)
            ]),
            Row(children: [
              const Text('브루셀라 도축: ',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text(brucellaSlaughter)
            ]),
          ],
        ),
      ),
    );
  }

  String _getHealthStatusText(dynamic healthStatus) {
    if (healthStatus == null) return '미등록';

    // healthStatus가 HealthStatus enum인 경우
    if (healthStatus.toString().contains('HealthStatus.')) {
      switch (healthStatus.toString()) {
        case 'HealthStatus.normal':
          return '정상';
        case 'HealthStatus.warning':
          return '주의';
        case 'HealthStatus.danger':
          return '이상';
        default:
          return healthStatus.toString().split('.').last;
      }
    }

    // healthStatus가 문자열인 경우
    return healthStatus.toString();
  }

  String _getBreedingStatusText(dynamic breedingStatus) {
    if (breedingStatus == null) return '미등록';

    final statusStr = breedingStatus.toString();

    // enum 형식일 경우 (예: BreedingStatus.pregnant)
    if (statusStr.contains('BreedingStatus.')) {
      final key = statusStr.split('.').last;
      return _translatedBreedingStatus(key);
    }

    // 문자열일 경우 (예: 'pregnant')
    return _translatedBreedingStatus(statusStr);
  }

  String _translatedBreedingStatus(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return '미임신';
      case 'bred':
      case 'breeding':
        return '교배';
      case 'pregnant':
        return '임신';
      case 'calved':
        return '분만';
      case 'dry':
        return '건유';
      case 'calf':
        return '송아지';
      case 'heifer':
        return '미경산우';
      case 'lactating':
        return '착유 중';
      default:
        return '미확인';
    }
  }
}
