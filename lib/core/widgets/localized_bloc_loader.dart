import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Loads localized mock data into a Cubit during [didChangeDependencies].
///
/// Use this wrapper when a Cubit needs access to [AppLocalizations]
/// (which is unavailable inside a Provider `create` callback).
class LocalizedBlocLoader<C extends StateStreamable<S>, S>
    extends StatefulWidget {
  const LocalizedBlocLoader({
    super.key,
    required this.child,
    required this.load,
  });

  final Widget child;
  final void Function(BuildContext context, C cubit) load;

  @override
  State<LocalizedBlocLoader<C, S>> createState() =>
      _LocalizedBlocLoaderState<C, S>();
}

class _LocalizedBlocLoaderState<C extends StateStreamable<S>, S>
    extends State<LocalizedBlocLoader<C, S>> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      widget.load(context, context.read<C>());
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
