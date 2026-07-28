#!/usr/bin/env bash
# Builds release APKs for both flavors (staging + production).
#
# Flavor -> environment is wired via Gradle product flavors (android/app/build.gradle.kts,
# dimension "env": staging/production) plus matching --dart-define values, since
# Flutter flavors alone don't propagate build-time Dart constants.
#
# Usage:
#   scripts/build_apk.sh            # builds both staging and production APKs
#   scripts/build_apk.sh staging    # builds only the staging APK
#   scripts/build_apk.sh production # builds only the production APK
set -euo pipefail
cd "$(dirname "$0")/.."

build_staging() {
  echo "==> Building staging APK (cms-stg.kilocal.thefullproject.it)"
  flutter build apk --release --flavor staging \
    --dart-define=API_BASE_URL=https://cms-stg.kilocal.thefullproject.it \
    --dart-define=FIREBASE_ENABLED=false
}

build_production() {
  echo "==> Building production APK (cms.kilocalprogram.it)"
  flutter build apk --release --flavor production \
    --dart-define=API_BASE_URL=https://cms.kilocalprogram.it \
    --dart-define=FIREBASE_ENABLED=true
}

case "${1:-all}" in
  staging) build_staging ;;
  production) build_production ;;
  all)
    build_staging
    build_production
    ;;
  *)
    echo "Unknown target: ${1}. Use one of: staging, production, all" >&2
    exit 1
    ;;
esac

echo "==> Done. APKs are under build/app/outputs/flutter-apk/"
