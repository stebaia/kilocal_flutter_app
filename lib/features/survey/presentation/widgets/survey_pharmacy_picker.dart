import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/pharmacy.dart';

/// Searchable Kilocal Point picker for `load_kilocal_points` sections.
///
/// The `pharmacies` collection has 22k+ rows, so results are fetched
/// server-side as the user types (debounced). The chosen [Pharmacy] is sent as
/// `pharmacy_data` in the submit body.
class SurveyPharmacyPicker extends StatefulWidget {
  const SurveyPharmacyPicker({
    super.key,
    required this.onSearch,
    required this.onSelected,
    this.selected,
  });

  final Future<List<Pharmacy>> Function(String query) onSearch;
  final ValueChanged<Pharmacy> onSelected;
  final Pharmacy? selected;

  @override
  State<SurveyPharmacyPicker> createState() => _SurveyPharmacyPickerState();
}

class _SurveyPharmacyPickerState extends State<SurveyPharmacyPicker> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Pharmacy> _results = const [];
  bool _loading = false;
  Object? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _results = const [];
        _loading = false;
        _error = null;
      });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 350), () => _run(query));
  }

  Future<void> _run(String query) async {
    try {
      final results = await widget.onSearch(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: 'Cerca per nome, città o provincia',
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textSecondary,
            ),
            filled: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceMd,
              vertical: AppSpacing.spaceSm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.accentSoft),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.accentSoft),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
            ),
          ),
        ),
        if (selected != null) ...[
          const SizedBox(height: AppSpacing.spaceMd),
          _SelectedPharmacyCard(pharmacy: selected),
        ],
        const SizedBox(height: AppSpacing.spaceSm),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
            child: Center(
              child: SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              ),
            ),
          )
        else if (_error != null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
            child: Text(
              'Errore nella ricerca. Riprova.',
              style: TextStyle(color: AppColors.accent, fontSize: 13),
            ),
          )
        else
          for (final p in _results)
            _PharmacyTile(
              pharmacy: p,
              selected: selected?.id == p.id,
              onTap: () => widget.onSelected(p),
            ),
      ],
    );
  }
}

class _PharmacyTile extends StatelessWidget {
  const _PharmacyTile({
    required this.pharmacy,
    required this.selected,
    required this.onTap,
  });

  final Pharmacy pharmacy;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final location = [
      pharmacy.address,
      [
        pharmacy.zip,
        pharmacy.city,
        if (pharmacy.province != null) '(${pharmacy.province})',
      ].where((e) => e != null && e.isNotEmpty).join(' '),
    ].where((e) => e != null && e.isNotEmpty).join(' · ');

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppSpacing.spaceXs),
        padding: const EdgeInsets.all(AppSpacing.spaceSm),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.divider,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pharmacy.title ?? '—',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.accent, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SelectedPharmacyCard extends StatelessWidget {
  const _SelectedPharmacyCard({required this.pharmacy});

  final Pharmacy pharmacy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_pharmacy, color: AppColors.accent, size: 20),
          const SizedBox(width: AppSpacing.spaceXs),
          Expanded(
            child: Text(
              'Selezionata: ${pharmacy.title ?? pharmacy.id}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
