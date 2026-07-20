import 'package:equatable/equatable.dart';

/// A single tool ("strumento") shown as a red card on the Strumenti tab.
///
/// The catalogue is static (client-side): titles are localized at build time
/// and illustrations ship as bundled assets. See [StrumentoId] for the fixed
/// set of tools.
class Strumento extends Equatable {
  const Strumento({
    required this.id,
    required this.title,
    required this.assetName,
  });

  final StrumentoId id;

  /// Localized display title (resolved from l10n at build time).
  final String title;

  /// Bundled illustration asset path (e.g. `assets/strumenti/timer.png`).
  final String assetName;

  @override
  List<Object?> get props => [id, title, assetName];
}

/// The fixed set of tools. Used as the route discriminator when launching a
/// tool so each one can grow its own destination later.
enum StrumentoId { promemoria, timer, glossario, gallery }
