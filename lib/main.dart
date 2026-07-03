import 'app/app.dart';
import 'app/bootstrap.dart';

void main() {
  // Firebase init, crash reporting, analytics, and DI are set up in bootstrap,
  // which runs the app inside a guarded zone.
  bootstrap(() => const KilocalApp());
}
