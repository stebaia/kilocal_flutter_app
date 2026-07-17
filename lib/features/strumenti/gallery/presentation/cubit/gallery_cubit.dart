import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/gallery_photo.dart';
import '../../domain/gallery_repository.dart';

part 'gallery_state.dart';

/// Drives the Foto Gallery: the photo grid, the CMS copy, and the two-photo
/// selection that feeds the split view.
class GalleryCubit extends Cubit<GalleryState> {
  GalleryCubit({required GalleryRepository repository})
    : _repository = repository,
      super(const GalleryState());

  final GalleryRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: GalleryStatus.loading));
    try {
      // The copy and the photos are independent; fetch them together so the
      // screen paints in one pass.
      final results = await Future.wait([
        _repository.getContent(),
        _repository.getPhotos(),
      ]);

      emit(
        state.copyWith(
          status: GalleryStatus.loaded,
          content: results[0] as GalleryContent,
          photos: results[1] as List<GalleryPhoto>,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: GalleryStatus.error));
    }
  }

  /// Uploads [file], then refreshes the grid. Returns false if it failed, so
  /// the caller can surface an error without reading the state back.
  Future<bool> upload(File file) async {
    emit(state.copyWith(isUploading: true));
    try {
      final photos = await _repository.upload(file);
      emit(state.copyWith(photos: photos, isUploading: false));
      return true;
    } catch (_) {
      emit(state.copyWith(isUploading: false));
      return false;
    }
  }

  Future<bool> delete(GalleryPhoto photo) async {
    try {
      await _repository.delete(photo);
      emit(
        state.copyWith(
          photos: state.photos.where((p) => p != photo).toList(),
          // Drop it from the selection too, or the split view would compare a
          // photo that no longer exists.
          selected: state.selected.where((p) => p != photo).toList(),
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  void startSelecting() =>
      emit(state.copyWith(mode: GalleryMode.selecting, selected: const []));

  void cancelSelecting() =>
      emit(state.copyWith(mode: GalleryMode.browse, selected: const []));

  /// Toggles [photo] in the selection. Tapping a selected photo removes it;
  /// once two are picked, further taps are ignored.
  void toggleSelection(GalleryPhoto photo) {
    final current = state.selected;
    if (current.contains(photo)) {
      emit(state.copyWith(selected: current.where((p) => p != photo).toList()));
      return;
    }
    if (current.length >= GalleryState.maxSelection) return;
    emit(state.copyWith(selected: [...current, photo]));
  }
}
