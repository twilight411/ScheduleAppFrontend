import '../services/api_service.dart';

class BackendProfile {
  final Map<String, dynamic> preferences;
  final List<String> tags;
  final bool onboardingCompleted;
  final List<SpiritIntensity> spiritIntensities;

  const BackendProfile({
    this.preferences = const {},
    this.tags = const [],
    this.onboardingCompleted = false,
    this.spiritIntensities = const [],
  });

  factory BackendProfile.fromJson(Map<String, dynamic> json) {
    final intensities = (json['spirit_intensities'] as List?)
            ?.map((e) =>
                SpiritIntensity.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return BackendProfile(
      preferences: json['preferences'] as Map<String, dynamic>? ?? {},
      tags:
          (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
      onboardingCompleted:
          json['onboarding_completed'] as bool? ?? false,
      spiritIntensities: intensities,
    );
  }
}

class SpiritIntensity {
  final String spiritCode;
  final String spiritName;
  final int baseIntensity;
  final double learnedDelta;
  final int effectiveIntensity;
  final bool isLocked;

  const SpiritIntensity({
    this.spiritCode = 'light',
    this.spiritName = '',
    this.baseIntensity = 50,
    this.learnedDelta = 0,
    this.effectiveIntensity = 50,
    this.isLocked = false,
  });

  factory SpiritIntensity.fromJson(Map<String, dynamic> json) =>
      SpiritIntensity(
        spiritCode: json['spirit_code'] as String? ?? 'light',
        spiritName: json['spirit_name'] as String? ?? '',
        baseIntensity: json['base_intensity'] as int? ?? 50,
        learnedDelta: (json['learned_delta'] as num?)?.toDouble() ?? 0,
        effectiveIntensity:
            json['effective_intensity'] as int? ?? 50,
        isLocked: json['is_locked'] as bool? ?? false,
      );
}

/// 远程用户画像数据源
class RemoteProfileRepository {
  final ApiService _api;

  RemoteProfileRepository({ApiService? apiService})
      : _api = apiService ?? ApiService.instance;

  // ========================================
  //  用户信息
  // ========================================

  Future<Map<String, dynamic>> getCurrentUser() async {
    final resp = await _api.get(endpoint: '/users/me');
    return (resp['data'] as Map<String, dynamic>?) ?? {};
  }

  Future<void> updateCurrentUser({
    String? name,
    String? timezone,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (timezone != null) body['timezone'] = timezone;
    await _api.patch(endpoint: '/users/me', body: body);
  }

  // ========================================
  //  画像
  // ========================================

  Future<BackendProfile> getProfile() async {
    final resp = await _api.get(endpoint: '/profile');
    return BackendProfile.fromJson(
        (resp['data'] as Map<String, dynamic>?) ?? {});
  }

  Future<void> updateProfile(Map<String, dynamic> preferences) async {
    await _api.patch(endpoint: '/profile', body: preferences);
  }

  // ========================================
  //  Onboarding 阶段
  // ========================================

  Future<void> submitOnboardingStage1({
    required String chronotype,
    required String taskTransition,
    required String chunkStyle,
    required String annualKeyword,
  }) async {
    await _api.post(
      endpoint: '/profile/onboarding/stage1',
      body: {
        'chronotype': chronotype,
        'task_transition': taskTransition,
        'chunk_style': chunkStyle,
        'annual_keyword': annualKeyword,
      },
    );
  }

  Future<void> submitOnboardingStage2({
    required String lightIntensity,
    required String waterIntensity,
    required String soilIntensity,
    required String airIntensity,
    required String nutritionIntensity,
  }) async {
    await _api.post(
      endpoint: '/profile/onboarding/stage2',
      body: {
        'light_intensity': lightIntensity,
        'water_intensity': waterIntensity,
        'soil_intensity': soilIntensity,
        'air_intensity': airIntensity,
        'nutrition_intensity': nutritionIntensity,
      },
    );
  }

  Future<void> submitOnboardingStage3({
    required String conflictStrategy,
  }) async {
    await _api.post(
      endpoint: '/profile/onboarding/stage3',
      body: {'conflict_strategy': conflictStrategy},
    );
  }

  Future<void> submitFullOnboarding({
    String? chronotype,
    String? taskTransition,
    String? chunkStyle,
    String? annualKeyword,
    String? lightIntensity,
    String? waterIntensity,
    String? soilIntensity,
    String? airIntensity,
    String? nutritionIntensity,
    String? conflictStrategy,
  }) async {
    final body = <String, dynamic>{};
    if (chronotype != null) body['chronotype'] = chronotype;
    if (taskTransition != null) body['task_transition'] = taskTransition;
    if (chunkStyle != null) body['chunk_style'] = chunkStyle;
    if (annualKeyword != null) body['annual_keyword'] = annualKeyword;
    if (lightIntensity != null) body['light_intensity'] = lightIntensity;
    if (waterIntensity != null) body['water_intensity'] = waterIntensity;
    if (soilIntensity != null) body['soil_intensity'] = soilIntensity;
    if (airIntensity != null) body['air_intensity'] = airIntensity;
    if (nutritionIntensity != null) {
      body['nutrition_intensity'] = nutritionIntensity;
    }
    if (conflictStrategy != null) {
      body['conflict_strategy'] = conflictStrategy;
    }
    await _api.post(endpoint: '/profile/onboarding', body: body);
  }

  // ========================================
  //  精灵强度
  // ========================================

  Future<List<SpiritIntensity>> getIntensities() async {
    final resp = await _api.get(endpoint: '/profile/intensity');
    final data = resp['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => SpiritIntensity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateIntensity({
    required String spiritCode,
    required int baseIntensity,
    bool? isLocked,
  }) async {
    final body = <String, dynamic>{
      'spirit_code': spiritCode,
      'base_intensity': baseIntensity,
    };
    if (isLocked != null) body['is_locked'] = isLocked;
    await _api.patch(endpoint: '/profile/intensity', body: body);
  }

  Future<void> batchUpdateIntensity(
      Map<String, int> intensities) async {
    await _api.patch(
      endpoint: '/profile/intensity/batch',
      body: {'intensities': intensities},
    );
  }
}
