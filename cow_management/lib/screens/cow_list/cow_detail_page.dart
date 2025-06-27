import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:cow_management/models/cow.dart';
import 'package:cow_management/screens/cow_list/cow_edit_page.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/utils/error_utils.dart';
import 'package:cow_management/screens/cow_list/cow_detailed_records_page.dart';

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
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
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
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildBasicInfoCard(),
            const SizedBox(height: 20),
            if (currentCow.hasLivestockTraceData)
              _buildLivestockTraceInfoCard(),
            const SizedBox(height: 20),
            _buildHealthInfoCard(context, currentCow.id, currentCow.name),
            const SizedBox(height: 20),
            _buildMilkingInfoCard(),
            const SizedBox(height: 20),
            _buildBreedingInfoCard(),
            const SizedBox(height: 20),
            _buildFeedingInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🐾 기본 정보',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('이름: ',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Text(currentCow.name.isNotEmpty ? currentCow.name : '미등록'),
              ],
            ),
            Row(
              children: [
                const Text('이표번호: ', style: TextStyle(fontWeight: FontWeight.w500)),
                Text(currentCow.earTagNumber.isNotEmpty ? currentCow.earTagNumber : '미등록'),
              ],
            ),
            Row(
              children: [
                const Text('품종: ',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Text((currentCow.breed != null && currentCow.breed!.isNotEmpty)
                    ? currentCow.breed!
                    : '미등록'),
              ],
            ),
            Row(
              children: [
                const Text('센서 번호: ',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Text((currentCow.sensorNumber != null &&
                        currentCow.sensorNumber!.isNotEmpty)
                    ? currentCow.sensorNumber!
                    : '미등록'),
              ],
            ),
            Row(
              children: [
                const Text('상태: ',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Text((currentCow.status.isNotEmpty &&
                        currentCow.status != '알 수 없음')
                    ? currentCow.status
                    : '미등록'),
              ],
            ),


  Widget infoTile(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ],
    );
  }

  Future<bool> deleteCow(BuildContext context, String cowId) async {
    final dio = Dio();
    final String? apiUrl = dotenv.env['API_BASE_URL'];
    final token = await Provider.of<UserProvider>(context, listen: false)
        .loadTokenFromStorage();

    if (apiUrl == null || token == null) {
      CowDetailPage._logger.severe("API 주소 또는 토큰 없음");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정 오류: API 주소 또는 인증 토큰이 없습니다')),
        );
      }
      return false;
    }

    try {
      final response = await dio.delete(
        '$apiUrl/cows/$cowId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.statusCode == 200 || response.statusCode == 204;
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

  // 축산물이력제 상세 정보 카드 추가
  Widget buildLivestockTraceInfoCard() {
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
}
