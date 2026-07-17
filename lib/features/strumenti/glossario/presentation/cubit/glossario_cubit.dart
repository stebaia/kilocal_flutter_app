import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/glossary_entry.dart';
import '../../domain/glossario_repository.dart';

part 'glossario_state.dart';

/// Drives the Glossario: the term list, the A-Z filter, the search box, and
/// which accordion is open.
class GlossarioCubit extends Cubit<GlossarioState> {
  GlossarioCubit({required GlossarioRepository repository})
    : _repository = repository,
      super(const GlossarioState());

  final GlossarioRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: GlossarioStatus.loading));
    try {
      final results = await Future.wait([
        _repository.getContent(),
        _repository.getEntries(),
      ]);
      final entries = results[1] as List<GlossaryEntry>;

      emit(
        state.copyWith(
          status: GlossarioStatus.loaded,
          content: results[0] as GlossaryContent,
          entries: entries,
          // Open on the first letter that actually has terms, so the list is
          // never empty on arrival.
          letter: _firstPopulatedLetter(entries),
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: GlossarioStatus.error));
    }
  }

  /// Selects a letter, clearing any active search.
  void selectLetter(String letter) => emit(
    state.copyWith(letter: letter, query: '', clearExpanded: true),
  );

  /// Runs a keyword search. An empty keyword falls back to the letter filter.
  void search(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(
        state.copyWith(
          query: '',
          letter: state.letter ?? _firstPopulatedLetter(state.entries),
          clearExpanded: true,
        ),
      );
      return;
    }
    emit(state.copyWith(query: trimmed, clearExpanded: true));
  }

  /// Opens [id], or closes it if already open.
  void toggleExpanded(String id) {
    if (state.expandedId == id) {
      emit(state.copyWith(clearExpanded: true));
    } else {
      emit(state.copyWith(expandedId: id));
    }
  }

  String? _firstPopulatedLetter(List<GlossaryEntry> entries) =>
      entries.isEmpty ? null : entries.first.initial;
}
