import 'package:equatable/equatable.dart';

import 'cms_form.dart';

/// A CMS-driven profile page (`private_pages`, queried by `internal_name`).
///
/// Its [sections] are a polymorphic (M2A) list of builder blocks; each concrete
/// block is a subtype of [ProfilePageSection]. See [[profile-cms-pages-schema]].
class ProfilePage extends Equatable {
  const ProfilePage({
    required this.internalName,
    this.isBlocked = false,
    this.sections = const [],
  });

  final String internalName;
  final bool isBlocked;
  final List<ProfilePageSection> sections;

  @override
  List<Object?> get props => [internalName, isBlocked, sections];
}

/// Base type for a profile page builder block.
sealed class ProfilePageSection extends Equatable {
  const ProfilePageSection();

  @override
  List<Object?> get props => [];
}

/// A plain section header block (`private_page_type`) — just a title.
class ProfilePageTitleSection extends ProfilePageSection {
  const ProfilePageTitleSection({required this.title});

  final String title;

  @override
  List<Object?> get props => [title];
}

/// The "percorsi" section (`private_sec_percorsi`) — an intro line plus a set of
/// path-category shortcuts rendered per [layout] (e.g. "icons").
class ProfilePagePercorsiSection extends ProfilePageSection {
  const ProfilePagePercorsiSection({this.intro, this.layout});

  final String? intro;
  final String? layout;

  @override
  List<Object?> get props => [intro, layout];
}

/// The account block (`private_sec_profile`) — a set of [ProfileFormTab]s, each
/// wrapping a CMS [CmsForm] (personal data, food preferences, account settings).
class ProfilePageFormTabsSection extends ProfilePageSection {
  const ProfilePageFormTabsSection({required this.tabs});

  final List<ProfileFormTab> tabs;

  @override
  List<Object?> get props => [tabs];
}

/// A single tab of the account block: a localized [title] and its [form].
class ProfileFormTab extends Equatable {
  const ProfileFormTab({required this.id, required this.title, this.form});

  final String id;
  final String title;
  final CmsForm? form;

  @override
  List<Object?> get props => [id, title, form];
}

/// A block the app does not (yet) render; kept so the section list stays
/// order-stable and future blocks can be added incrementally.
class ProfilePageUnknownSection extends ProfilePageSection {
  const ProfilePageUnknownSection({required this.collection});

  final String collection;

  @override
  List<Object?> get props => [collection];
}
