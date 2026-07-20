part of 'gallery_cubit.dart';

enum GalleryStatus { initial, loading, loaded, error }

/// Whether the grid is browsing or picking the two photos to compare.
enum GalleryMode { browse, selecting }

class GalleryState extends Equatable {
  const GalleryState({
    this.status = GalleryStatus.initial,
    this.photos = const [],
    this.content = const GalleryContent(),
    this.mode = GalleryMode.browse,
    this.selected = const [],
    this.isUploading = false,
  });

  final GalleryStatus status;
  final List<GalleryPhoto> photos;
  final GalleryContent content;
  final GalleryMode mode;

  /// Photos picked for the split view, in tap order: the first is shown on the
  /// left of the cursor, the second on the right. Capped at [maxSelection].
  final List<GalleryPhoto> selected;

  final bool isUploading;

  static const maxSelection = 2;

  bool get hasBothSelected => selected.length == maxSelection;

  bool isSelected(GalleryPhoto photo) => selected.contains(photo);

  /// The selection CTA's label, which tracks how many photos are picked.
  /// Falls back to null when the CMS has no copy for the current state.
  String? selectionCta() => switch (selected.length) {
    0 => content.choose2Photos,
    1 => content.chooseOtherPhoto,
    _ => content.ctaShowSplit,
  };

  GalleryState copyWith({
    GalleryStatus? status,
    List<GalleryPhoto>? photos,
    GalleryContent? content,
    GalleryMode? mode,
    List<GalleryPhoto>? selected,
    bool? isUploading,
  }) {
    return GalleryState(
      status: status ?? this.status,
      photos: photos ?? this.photos,
      content: content ?? this.content,
      mode: mode ?? this.mode,
      selected: selected ?? this.selected,
      isUploading: isUploading ?? this.isUploading,
    );
  }

  @override
  List<Object?> get props => [
    status,
    photos,
    content,
    mode,
    selected,
    isUploading,
  ];
}
