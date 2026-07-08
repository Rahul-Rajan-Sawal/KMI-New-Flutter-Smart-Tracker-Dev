import 'package:flutter_bottom_nav/core/repository/calendar/calendar_lead_repository.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/models/Calendar/calendar_lead_args.dart';
import 'package:flutter_bottom_nav/models/Calendar/lead_card_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final calendarLeadRepositoryProvider = Provider<CalendarLeadRepository>((ref) {
  return CalendarLeadRepository();
});

final calendarLeadProvider = StateNotifierProvider.autoDispose
    .family<
      CalendarLeadNotifier,
      AsyncValue<List<LeadCardModel>>,
      CalendarLeadArgs
    >((ref, args) {
      final repository = ref.read(calendarLeadRepositoryProvider);

      return CalendarLeadNotifier(
        repository: repository,
        args: args,
        userId: StaticVariables.mSAPCode,
      );
    });

class CalendarLeadNotifier
    extends StateNotifier<AsyncValue<List<LeadCardModel>>> {
  final CalendarLeadRepository repository;
  final CalendarLeadArgs args;
  final String userId;

  CalendarLeadNotifier({
    required this.repository,
    required this.args,
    required this.userId,
  }) : super(const AsyncLoading()) {
    loadLocalLeads();
  }

  Future<void> loadLocalLeads() async {
    try {
      final sapCode = userId.trim();

      if (sapCode.isEmpty) {
        throw Exception('Logged-in SAP code is not available.');
      }

      // First, load matching cards from local LeadDetails.
      final localLeads = await repository.getLocalLeads(
        args: args,
        userId: sapCode,
      );

      // Local data is incomplete compared with calendar count.
      if (localLeads.length < args.expectedCount) {
        // Fetch missing lead details from API and save them locally.
        await repository.syncLeadsFromApi(args: args, userId: sapCode);

        // Read LeadDetails again after API records are saved.
        final refreshedLeads = await repository.getLocalLeads(
          args: args,
          userId: sapCode,
        );

        if (!mounted) return;

        // Display refreshed cards.
        state = AsyncData(refreshedLeads);
      } else {
        if (!mounted) return;

        // Local records are complete, so display them directly.
        state = AsyncData(localLeads);
      }
    } catch (e, stackTrace) {
      if (!mounted) return;

      state = AsyncError(e, stackTrace);
    }
  }

  // Future<void> loadLocalLeads() async {
  //   try {
  //     final sapCode = userId.trim();

  //     if (sapCode.isEmpty) {
  //       throw Exception('Logged-in SAP code is not available.');
  //     }

  //     final leads = await repository.getLocalLeads(args: args, userId: sapCode);

  //     if (!mounted) return;

  //     state = AsyncData(leads);
  //   } catch (e, stackTrace) {
  //     if (!mounted) return;

  //     state = AsyncError(e, stackTrace);
  //   }
  // }

  Future<void> forceRefresh() async {
    try {
      state = const AsyncLoading();

      final sapCode = userId.trim();

      if (sapCode.isEmpty) {
        throw Exception('Logged-in SAP code is not available.');
      }

      // Always call API
      await repository.syncLeadsFromApi(args: args, userId: sapCode);

      // Reload from DB after save
      final refreshedLeads = await repository.getLocalLeads(
        args: args,
        userId: sapCode,
      );

      if (!mounted) return;

      state = AsyncData(refreshedLeads);
    } catch (e, stackTrace) {
      if (!mounted) return;

      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> refreshLocal() async {
    state = const AsyncLoading();

    await loadLocalLeads();
  }
}
