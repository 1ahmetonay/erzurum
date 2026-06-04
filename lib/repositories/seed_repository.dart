import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_paths.dart';
import '../models/leaderboard_model.dart';
import '../models/recycling_point_model.dart';
import '../models/reward_model.dart';
import '../models/task_model.dart';

class SeedRepository {
  SeedRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> seedAll() async {
    await seedTasks();
    await seedRewards();
    await seedRecyclingPoints();
    await seedLeaderboard();
  }

  Future<void> seedTasks() async {
    final now = DateTime.now();
    final tasks = [
      TaskModel(
        id: 'daily_plastic_1',
        title: '5 Plastik Şişe',
        description: 'Bugün 5 plastik şişeyi doğru noktaya bırak.',
        type: TaskTypes.daily,
        pointReward: 10,
        requiredAction: TaskActions.scanPlastic,
        requiredCount: 5,
        isWinterOnly: false,
        iconEmoji: '♻️',
        sortOrder: 10,
        createdAt: now,
        updatedAt: now,
      ),
      TaskModel(
        id: 'weekly_paper_collect',
        title: 'Atık Kağıt Topla',
        description: 'Hafta içinde kağıt atığını geri dönüşüm noktasına bırak.',
        type: TaskTypes.weekly,
        pointReward: 20,
        requiredAction: TaskActions.scanPaper,
        requiredCount: 1,
        isWinterOnly: false,
        iconEmoji: '📄',
        sortOrder: 20,
        createdAt: now,
        updatedAt: now,
      ),
      TaskModel(
        id: 'weekly_three_batteries',
        title: '3 Atık Pil',
        description: '3 atık pili güvenli pil toplama kutusuna bırak.',
        type: TaskTypes.weekly,
        pointReward: 30,
        requiredAction: TaskActions.scanBattery,
        requiredCount: 3,
        isWinterOnly: false,
        iconEmoji: '🔋',
        sortOrder: 30,
        createdAt: now,
        updatedAt: now,
      ),
      TaskModel(
        id: 'social_invite_friend',
        title: 'Arkadaşını Davet Et',
        description: 'Bir arkadaşını AtıkAvı Erzurum’a davet et.',
        type: TaskTypes.social,
        pointReward: 20,
        requiredAction: TaskActions.inviteFriend,
        requiredCount: 1,
        isWinterOnly: false,
        iconEmoji: '🤝',
        sortOrder: 40,
        createdAt: now,
        updatedAt: now,
      ),
      TaskModel(
        id: 'education_zero_waste_quiz',
        title: 'Mini Sıfır Atık Testi Çöz',
        description: 'Kısa sıfır atık testini tamamla.',
        type: TaskTypes.education,
        pointReward: 15,
        requiredAction: TaskActions.solveQuiz,
        requiredCount: 1,
        isWinterOnly: false,
        iconEmoji: '🧠',
        sortOrder: 50,
        createdAt: now,
        updatedAt: now,
      ),
      TaskModel(
        id: 'winter_cup_lid',
        title: 'Karton bardak kapağını doğru kutuya at',
        description:
            'Karton bardak kapağını plastik, gövdesini kağıt kutusuna at.',
        type: TaskTypes.winter,
        pointReward: 15,
        requiredAction: TaskActions.winterCupLid,
        requiredCount: 1,
        isWinterOnly: true,
        iconEmoji: '☕',
        sortOrder: 60,
        createdAt: now,
        updatedAt: now,
      ),
      TaskModel(
        id: 'winter_report_nearest_point',
        title: 'Karlı havada en yakın noktayı bildir',
        description:
            'Karlı havada kullanılabilir en yakın geri dönüşüm noktasını bildir.',
        type: TaskTypes.winter,
        pointReward: 20,
        requiredAction: TaskActions.reportNearbyPoint,
        requiredCount: 1,
        isWinterOnly: true,
        iconEmoji: '❄️',
        sortOrder: 70,
        createdAt: now,
        updatedAt: now,
      ),
      TaskModel(
        id: 'winter_social_ten_people',
        title: '10 kişiyle kış atığı görevi tamamla',
        description: 'Ekibinle birlikte kış atığı görevini tamamla.',
        type: TaskTypes.social,
        pointReward: 50,
        requiredAction: TaskActions.winterGroupTask,
        requiredCount: 10,
        isWinterOnly: true,
        iconEmoji: '👥',
        sortOrder: 80,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await _setAll(FirestorePaths.tasks, tasks.map((task) => task.toMap()));
  }

  Future<void> seedRewards() async {
    final now = DateTime.now();
    final rewards = [
      RewardModel(
        id: 'zero_waste_cafe_discount',
        title: 'Sıfır Atık Kafe %10 İndirim',
        description: 'Anlaşmalı Sıfır Atık Kafe alışverişlerinde indirim.',
        requiredPoints: 100,
        category: RewardCategories.discount,
        sponsor: 'Erzurum Sıfır Atık Kafe',
        iconEmoji: '☕',
        isActive: true,
        stockCount: 50,
        sortOrder: 10,
        createdAt: now,
        updatedAt: now,
      ),
      RewardModel(
        id: 'tea_coffee_coupon',
        title: 'Kahve / Çay Kuponu',
        description: 'Katılımcı işletmelerde sıcak içecek kuponu.',
        requiredPoints: 250,
        category: RewardCategories.physical,
        sponsor: 'Yakutiye Esnaf Ağı',
        iconEmoji: '🫖',
        isActive: true,
        stockCount: 30,
        sortOrder: 20,
        createdAt: now,
        updatedAt: now,
      ),
      RewardModel(
        id: 'cloth_bag',
        title: 'Bez Çanta',
        description: 'AtıkAvı Erzurum logolu tekrar kullanılabilir bez çanta.',
        requiredPoints: 500,
        category: RewardCategories.physical,
        sponsor: 'AtıkAvı Erzurum',
        iconEmoji: '🛍️',
        isActive: true,
        stockCount: 20,
        sortOrder: 30,
        createdAt: now,
        updatedAt: now,
      ),
      RewardModel(
        id: 'erzurum_card_balance',
        title: 'Erzurum Kart Bakiye',
        description: 'Toplu taşıma için dijital bakiye kuponu.',
        requiredPoints: 750,
        category: RewardCategories.transport,
        sponsor: 'Erzurum Kart',
        iconEmoji: '🚌',
        isActive: true,
        stockCount: 10,
        sortOrder: 40,
        createdAt: now,
        updatedAt: now,
      ),
      RewardModel(
        id: 'sapling_donation',
        title: 'Fidan Bağışı',
        description: 'Erzurum için senin adına bir fidan bağışı.',
        requiredPoints: 1000,
        category: RewardCategories.donation,
        sponsor: 'AtıkAvı Erzurum',
        iconEmoji: '🌲',
        isActive: true,
        stockCount: null,
        sortOrder: 50,
        createdAt: now,
        updatedAt: now,
      ),
      RewardModel(
        id: 'municipality_certificate',
        title: 'Belediye Sertifikası',
        description:
            'Geri dönüşüm katkını gösteren dijital belediye sertifikası.',
        requiredPoints: 1500,
        category: RewardCategories.certificate,
        sponsor: 'Erzurum Büyükşehir Belediyesi',
        iconEmoji: '🏅',
        isActive: true,
        stockCount: null,
        sortOrder: 60,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await _setAll(
      FirestorePaths.rewards,
      rewards.map((reward) => reward.toMap()),
    );
  }

  Future<void> seedRecyclingPoints() async {
    final now = DateTime.now();
    final points = [
      RecyclingPointModel(
        id: 'yakutiye_recycling_center',
        name: 'Yakutiye Geri Dönüşüm Merkezi',
        type: RecyclingPointTypes.plastic,
        latitude: 39.9056,
        longitude: 41.2658,
        address: 'Yakutiye, Erzurum merkez',
        qrCode: 'ATIKAVI_POINT_YAKUTIYE',
        isActive: true,
        isBroken: false,
        workingHours: const {
          'weekdays': '08:00-20:00',
          'weekend': '10:00-18:00',
        },
        createdAt: now,
        updatedAt: now,
      ),
      RecyclingPointModel(
        id: 'erzurum_zero_waste_cafe',
        name: 'Erzurum Sıfır Atık Kafe',
        type: RecyclingPointTypes.cafe,
        latitude: 39.9088,
        longitude: 41.2762,
        address: 'Cumhuriyet Caddesi, Yakutiye',
        qrCode: 'ATIKAVI_POINT_ZERO_WASTE_CAFE',
        isActive: true,
        isBroken: false,
        workingHours: const {
          'weekdays': '08:00-22:00',
          'weekend': '10:00-22:00',
        },
        createdAt: now,
        updatedAt: now,
      ),
      RecyclingPointModel(
        id: 'atauni_campus_point',
        name: 'Atatürk Üniversitesi Kampüs Toplama Noktası',
        type: RecyclingPointTypes.paper,
        latitude: 39.9069,
        longitude: 41.2372,
        address: 'Atatürk Üniversitesi Kampüsü, Erzurum',
        qrCode: 'ATIKAVI_POINT_ATAUNI',
        isActive: true,
        isBroken: false,
        workingHours: const {'weekdays': '09:00-18:00'},
        createdAt: now,
        updatedAt: now,
      ),
      RecyclingPointModel(
        id: 'etu_campus_point',
        name: 'Erzurum Teknik Üniversitesi Toplama Noktası',
        type: RecyclingPointTypes.paper,
        latitude: 39.8958,
        longitude: 41.2454,
        address: 'Erzurum Teknik Üniversitesi Kampüsü',
        qrCode: 'ATIKAVI_POINT_ETU',
        isActive: true,
        isBroken: false,
        workingHours: const {'weekdays': '09:00-18:00'},
        createdAt: now,
        updatedAt: now,
      ),
      RecyclingPointModel(
        id: 'yildizkent_neighborhood_point',
        name: 'Yıldızkent Mahalle Noktası',
        type: RecyclingPointTypes.plastic,
        latitude: 39.8845,
        longitude: 41.2291,
        address: 'Yıldızkent Mahallesi, Palandöken',
        qrCode: 'ATIKAVI_POINT_YILDIZKENT',
        isActive: true,
        isBroken: false,
        createdAt: now,
        updatedAt: now,
      ),
      RecyclingPointModel(
        id: 'sukrupasa_battery_point',
        name: 'Şükrüpaşa Pil Toplama Noktası',
        type: RecyclingPointTypes.battery,
        latitude: 39.9218,
        longitude: 41.2752,
        address: 'Şükrüpaşa Mahallesi, Erzurum',
        qrCode: 'ATIKAVI_POINT_SUKRUPASA_BATTERY',
        isActive: true,
        isBroken: false,
        createdAt: now,
        updatedAt: now,
      ),
      RecyclingPointModel(
        id: 'palandoken_glass_point',
        name: 'Palandöken Cam Atık Noktası',
        type: RecyclingPointTypes.glass,
        latitude: 39.8768,
        longitude: 41.2614,
        address: 'Palandöken, Erzurum',
        qrCode: 'ATIKAVI_POINT_PALANDOKEN_GLASS',
        isActive: true,
        isBroken: false,
        createdAt: now,
        updatedAt: now,
      ),
      RecyclingPointModel(
        id: 'aziziye_paper_point',
        name: 'Aziziye Kağıt Toplama Noktası',
        type: RecyclingPointTypes.paper,
        latitude: 39.9402,
        longitude: 41.1098,
        address: 'Aziziye, Erzurum',
        qrCode: 'ATIKAVI_POINT_AZIZIYE_PAPER',
        isActive: true,
        isBroken: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await _setAll(
      FirestorePaths.recyclingPoints,
      points.map((point) => point.toMap()),
    );
  }

  Future<void> seedLeaderboard() async {
    final now = DateTime.now();
    final data = <String, List<LeaderboardModel>>{
      LeaderboardCategories.individual: [
        _leaderboard(
          LeaderboardCategories.individual,
          'demo_ahmet_k',
          'Ahmet K.',
          3120,
          620,
          1,
          now,
          movement: 2,
        ),
        _leaderboard(
          LeaderboardCategories.individual,
          'demo_ayse_y',
          'Ayşe Y.',
          2840,
          580,
          2,
          now,
          movement: -1,
        ),
        _leaderboard(
          LeaderboardCategories.individual,
          'demo_mehmet_s',
          'Mehmet S.',
          2450,
          510,
          3,
          now,
          movement: 1,
        ),
        _leaderboard(
          LeaderboardCategories.individual,
          'demo_fatma_g',
          'Fatma G.',
          2100,
          470,
          4,
          now,
          movement: 0,
        ),
        _leaderboard(
          LeaderboardCategories.individual,
          'demo_caner_d',
          'Caner D.',
          1980,
          430,
          5,
          now,
          movement: 3,
        ),
      ],
      LeaderboardCategories.neighborhood: [
        _leaderboard(
          LeaderboardCategories.neighborhood,
          'yildizkent',
          'Yıldızkent',
          12840,
          2120,
          1,
          now,
          members: 124,
        ),
        _leaderboard(
          LeaderboardCategories.neighborhood,
          'sukrupasa',
          'Şükrüpaşa',
          11320,
          1980,
          2,
          now,
          members: 108,
        ),
        _leaderboard(
          LeaderboardCategories.neighborhood,
          'yenisehir',
          'Yenişehir',
          10210,
          1740,
          3,
          now,
          members: 96,
        ),
        _leaderboard(
          LeaderboardCategories.neighborhood,
          'yakutiye',
          'Yakutiye',
          9840,
          1660,
          4,
          now,
          members: 91,
        ),
        _leaderboard(
          LeaderboardCategories.neighborhood,
          'aziziye',
          'Aziziye',
          8620,
          1420,
          5,
          now,
          members: 74,
        ),
      ],
      LeaderboardCategories.campus: [
        _leaderboard(
          LeaderboardCategories.campus,
          'atauni',
          'Atatürk Üniversitesi',
          18420,
          3560,
          1,
          now,
          members: 420,
        ),
        _leaderboard(
          LeaderboardCategories.campus,
          'etu',
          'Erzurum Teknik Üniversitesi',
          13950,
          2840,
          2,
          now,
          members: 260,
        ),
      ],
      LeaderboardCategories.school: [
        _leaderboard(
          LeaderboardCategories.school,
          'erzurum_anadolu_lisesi',
          'Erzurum Anadolu Lisesi',
          8240,
          1340,
          1,
          now,
          members: 86,
        ),
        _leaderboard(
          LeaderboardCategories.school,
          'yakutiye_ortaokulu',
          'Yakutiye Ortaokulu',
          7160,
          1190,
          2,
          now,
          members: 73,
        ),
        _leaderboard(
          LeaderboardCategories.school,
          'palandoken_ilkokulu',
          'Palandöken İlkokulu',
          6420,
          980,
          3,
          now,
          members: 64,
        ),
      ],
    };

    for (final entry in data.entries) {
      await _firestore.doc(FirestorePaths.leaderboardCategory(entry.key)).set({
        'id': entry.key,
        'category': entry.key,
        'updatedAt': now,
      }, SetOptions(merge: true));

      await _setAll(
        FirestorePaths.leaderboardEntries(entry.key),
        entry.value.map((item) => item.toMap()),
      );
    }
  }

  LeaderboardModel _leaderboard(
    String category,
    String id,
    String name,
    int totalPoints,
    int weeklyPoints,
    int rank,
    DateTime updatedAt, {
    int? movement,
    int? members,
  }) {
    return LeaderboardModel(
      id: id,
      category: category,
      userId: id.startsWith('demo_') ? id : null,
      name: name,
      photoUrl: null,
      totalPoints: totalPoints,
      weeklyPoints: weeklyPoints,
      rank: rank,
      movement: movement ?? 0,
      memberCount: members,
      updatedAt: updatedAt,
    );
  }

  Future<void> _setAll(
    String collectionPath,
    Iterable<Map<String, dynamic>> documents,
  ) async {
    final batch = _firestore.batch();
    for (final data in documents) {
      final id = data['id'] as String;
      batch.set(
        _firestore.collection(collectionPath).doc(id),
        data,
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }
}
