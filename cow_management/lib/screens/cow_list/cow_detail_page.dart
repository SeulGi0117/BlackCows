import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:cow_management/models/cow.dart';
import 'package:cow_management/screens/cow_list/cow_edit_page.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/utils/error_utils.dart';
import 'package:cow_management/screens/cow_list/cow_list_page.dart';

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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text(
              '삭제하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
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
            if (currentCow.hasLivestockTraceData) _buildLivestockTraceInfoCard(),
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
            const Text('🐾 기본 정보', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('이름: ', style: TextStyle(fontWeight: FontWeight.w500)),
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
                const Text('품종: ', style: TextStyle(fontWeight: FontWeight.w500)),
                Text((currentCow.breed != null && currentCow.breed!.isNotEmpty) ? currentCow.breed! : '미등록'),
              ],
            ),
            Row(
              children: [
                const Text('센서 번호: ', style: TextStyle(fontWeight: FontWeight.w500)),
                Text((currentCow.sensorNumber != null && currentCow.sensorNumber!.isNotEmpty) ? currentCow.sensorNumber! : '미등록'),
              ],
            ),
            Row(
              children: [
                const Text('상태: ', style: TextStyle(fontWeight: FontWeight.w500)),
                Text((currentCow.status.isNotEmpty && currentCow.status != '알 수 없음') ? currentCow.status : '미등록'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 160,
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
                label: const Text('정보 수정하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCardBase({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildHealthInfoCard(
      BuildContext context, String cowId, String cowName) {
    return _infoCardBase(
      icon: Icons.healing,
      title: '건강 정보',
      children: [
        _healthRecordButton(
          context: context,
          title: '건강검진 기록',
          icon: Icons.monitor_heart,
          listRoute: '/health-check/list',
          addRoute: '/health-check/add',
          cowId: cowId,
          cowName: cowName,
          recordType: 'health_check',
        ),
        const SizedBox(height: 8),
        _healthRecordButton(
          context: context,
          title: '백신접종 기록',
          icon: Icons.vaccines,
          listRoute: '/vaccination/list',
          addRoute: '/vaccination/add',
          cowId: cowId,
          cowName: cowName,
          recordType: 'vaccination',
        ),
        const SizedBox(height: 8),
        _healthRecordButton(
          context: context,
          title: '체중 측정 기록',
          icon: Icons.monitor_weight,
          listRoute: '/weight/list',
          addRoute: '/weight/add',
          cowId: cowId,
          cowName: cowName,
          recordType: 'weight',
        ),
        const SizedBox(height: 8),
        _healthRecordButton(
          context: context,
          title: '치료 기록',
          icon: Icons.medical_services,
          listRoute: '/treatment/list',
          addRoute: '/treatment/add',
          cowId: cowId,
          cowName: cowName,
          recordType: 'treatment',
        ),
      ],
    );
  }

  Widget _healthRecordButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String listRoute,
    required String addRoute,
    required String cowId,
    required String cowName,
    required String recordType,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          icon: Icon(icon),
          label: Text('$title 보기'),
          onPressed: () {
            Navigator.pushNamed(
              context,
              listRoute,
              arguments: {
                'cowId': cowId,
                'cowName': cowName,
                'recordType': recordType,
              },
            );
          },
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('추가'),
          onPressed: () {
            Navigator.pushNamed(
              context,
              addRoute,
              arguments: {
                'cowId': cowId,
                'cowName': cowName,
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBreedingInfoCard() {
    return _infoCardBase(
      icon: Icons.pregnant_woman,
      title: '번식 정보',
      children: [
        _breedingRecordButton(
          title: '발정 기록',
          icon: Icons.waves,
          route: '/estrus-record/detail',
          addRoute: '/estrus-record/add',
        ),
        const SizedBox(height: 8),
        _breedingRecordButton(
          title: '인공수정 기록',
          icon: Icons.medical_services_outlined,
          route: '/insemination-record/detail',
          addRoute: '/insemination-record/add',
        ),
        const SizedBox(height: 8),
        _breedingRecordButton(
          title: '임신감정 기록',
          icon: Icons.search,
          route: '/pregnancy-check-record/detail',
          addRoute: '/pregnancy-check-record/add',
        ),
        const SizedBox(height: 8),
        _breedingRecordButton(
          title: '분만 기록',
          icon: Icons.child_care,
          route: '/calving-record/detail',
          addRoute: '/calving-record/add',
        ),
      ],
    );
  }

  Widget _breedingRecordButton({
    required String title,
    required IconData icon,
    required String route,
    required String addRoute,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                route,
                arguments: {
                  'cowId': currentCow.id,
                  'cowName': currentCow.name,
                },
              );
            },
            icon: Icon(icon),
            label: Text(title),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              addRoute,
              arguments: {
                'cowId': currentCow.id,
                'cowName': currentCow.name,
              },
            );
          },
          child: const Text('기록 추가'),
        ),
      ],
    );
  }

  Widget _buildFeedingInfoCard() {
    final feedingRecords = currentCow.feedingRecords;
    final hasRecords = feedingRecords.isNotEmpty;

    return _infoCardBase(
      icon: Icons.rice_bowl,
      title: '사료 정보',
      children: [
        if (hasRecords)
          ...feedingRecords.map((record) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                    '📅 ${record.feedingDate} - ${record.feedType} ${record.amount}kg'),
              ))
        else
          const Text('사료 섭취 기록이 없습니다.'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/feeding-record/list',
                    arguments: {
                      'cowId': currentCow.id,
                      'cowName': currentCow.name,
                    },
                  );
                },
                icon: const Icon(Icons.list),
                label: const Text('기록 보기'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/feeding-record/add',
                    arguments: {
                      'cowId': currentCow.id,
                      'cowName': currentCow.name,
                    },
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('기록 추가'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMilkingInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_drink, size: 20),
              SizedBox(width: 6),
              Text('우유 착유 정보',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
              '최근 착유량: ${currentCow.milk.isNotEmpty ? currentCow.milk : '정보 없음'}'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/milking-records',
                      arguments: {
                        'cowId': currentCow.id,
                        'cowName': currentCow.name,
                      },
                    );
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('착유 기록 보기'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/milking-record',
                      arguments: {
                        'cowId': currentCow.id,
                        'cowName': currentCow.name,
                      },
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('착유 기록 추가'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 80,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
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

  Future<void> showDeleteCowDialog(BuildContext context, String cowName, VoidCallback onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('정말로 삭제하시겠습니까?', style: TextStyle(fontWeight: FontWeight.bold)),
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
    final birthDate = data['birthDate'] ?? currentCow.birthdate?.toString().split(' ')[0] ?? '-';
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
            const Text('🔍 축산물이력제 정보', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(children: [const Text('이표번호: ', style: TextStyle(fontWeight: FontWeight.w500)), Text(earTag)]),
            Row(children: [const Text('개월령: ', style: TextStyle(fontWeight: FontWeight.w500)), Text(ageMonth)]),
            Row(children: [const Text('출생일: ', style: TextStyle(fontWeight: FontWeight.w500)), Text(birthDate)]),
            Row(children: [const Text('농가정보: ', style: TextStyle(fontWeight: FontWeight.w500)), Text('$ownerMasked ($farmId)')]),
            Row(children: [const Text('목장주소: ', style: TextStyle(fontWeight: FontWeight.w500)), Text(farmAddress)]),
            const SizedBox(height: 10),
            const Text('출생신고 정보', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: [const Text('등록자: ', style: TextStyle(fontWeight: FontWeight.w500)), Text(birthRegistrar)]),
            Row(children: [const Text('등록일: ', style: TextStyle(fontWeight: FontWeight.w500)), Text(birthReportDate)]),
            Row(children: [const Text('등록지: ', style: TextStyle(fontWeight: FontWeight.w500)), Text(birthReportAddress)]),
            const SizedBox(height: 10),
            const Text('백신/질병검사 정보', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: [const Text('구제역: ', style: TextStyle(fontWeight: FontWeight.w500)), Text(fmd)]),
            Row(children: [const Text('브루셀라 이동: ', style: TextStyle(fontWeight: FontWeight.w500)), Text(brucellaMove)]),
            Row(children: [const Text('브루셀라 도축: ', style: TextStyle(fontWeight: FontWeight.w500)), Text(brucellaSlaughter)]),
          ],
        ),
      ),
    );
  }
}
