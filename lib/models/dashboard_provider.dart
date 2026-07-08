import 'package:flutter_bottom_nav/core/repository/dashboard_repository.dart';
import 'package:flutter_bottom_nav/models/Dashboard/dashboard_detail_model.dart';
import 'package:flutter_bottom_nav/models/Dashboard/dashboard_summary_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';

final dashboardRepositoryProvider = Provider(
  (ref) => DashboardRepository(DatabaseHelper.instance),
);

/// 1 = All, 2 = Contact, 3 = Lead
final dashboardLeadTypeProvider = StateProvider<int>((ref) => 1);

/// Real recycler/detail list provider
final dashboardDetailsProvider = StateProvider<List<DashboardDetailModel>>(
  (ref) => [],
);

/// Detail list loading provider
final dashboardDetailsLoadingProvider = StateProvider<bool>((ref) => false);

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, AsyncValue<DashboardSummary>>(
      (ref) => DashboardNotifier(
        repository: ref.read(dashboardRepositoryProvider),
        ref: ref,
      ),
    );

class DashboardNotifier extends StateNotifier<AsyncValue<DashboardSummary>> {
  final DashboardRepository repository;
  final Ref ref;

  DashboardNotifier({required this.repository, required this.ref})
    : super(const AsyncValue.loading());

  /// Use this only for:
  /// 1. First dashboard load
  /// 2. Refresh button
  Future<void> loadDashboard({
    required String rmCode,
    required String month,
    bool forceRefresh = false,
    int leadType = 1,
  }) async {
    try {
      state = const AsyncValue.loading();

      ref.read(dashboardDetailsProvider.notifier).state = [];

      await repository.loadDashboard(
        rmCode: rmCode,
        month: month,
        forceRefresh: forceRefresh,
      );

      final summary = await repository.calculateSummary(
        rmCode,
        month,
        leadType: leadType,
      );

      state = AsyncValue.data(summary);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Use this only for:
  /// All / Contact / Lead radio change
  ///
  /// Important:
  /// Do not set loading here.
  Future<void> changeLeadType({
    required String rmCode,
    required String month,
    required int leadType,
  }) async {
    try {
      ref.read(dashboardDetailsProvider.notifier).state = [];

      final summary = await repository.calculateSummary(
        rmCode,
        month,
        leadType: leadType,
      );

      state = AsyncValue.data(summary);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Use this when user clicks Converted / Lost / Open / Sale Closed card
  Future<void> loadDashboardDetails({
    required String rmCode,
    required String month,
    required String status,
    required int leadType,
  }) async {
    try {
      ref.read(dashboardDetailsLoadingProvider.notifier).state = true;

      final details = await repository.getDashboardDetailsFromDb(
        rmCode: rmCode,
        month: month,
        status: status,
        leadType: leadType,
      );

      ref.read(dashboardDetailsProvider.notifier).state = details;
    } catch (_) {
      ref.read(dashboardDetailsProvider.notifier).state = [];
    } finally {
      ref.read(dashboardDetailsLoadingProvider.notifier).state = false;
    }
  }

  Future<void> loadDashboardActivityDetails({
    required String rmCode,
    required String month,
    required String activityCode,
    required String subActivityCode,
    required String statusFlag,
    required int leadType,
  }) async {
    try {
      ref.read(dashboardDetailsLoadingProvider.notifier).state = true;
      ref.read(dashboardDetailsProvider.notifier).state = [];

      await repository.savegriddashboarddata(
        rmCode: rmCode,
        month: month,
        activityCode: activityCode,
        subActivityCode: subActivityCode,
        statusFlag: statusFlag,
      );

      final statusForQuery = statusFlag == "Close" ? "Sale Closed" : statusFlag;

      final details = await repository.getDashboardDetailsFromDb(
        rmCode: rmCode,
        month: month,
        status: statusForQuery,
        leadType: leadType,
      );

      print("DETAILS AFTER SAVE GRID DATA = ${details.length}");

      ref.read(dashboardDetailsProvider.notifier).state = details;
    } catch (e, st) {
      print("loadDashboardActivityDetails error: $e");
      print(st);
      ref.read(dashboardDetailsProvider.notifier).state = [];
    } finally {
      ref.read(dashboardDetailsLoadingProvider.notifier).state = false;
    }
  }
}
