#!/bin/sh
set -e

git clone https://github.com/flutter/flutter.git -b stable --depth 1 _flutter
export PATH="$PWD/_flutter/bin:$PATH"

flutter config --enable-web
flutter pub get
flutter build web --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY="$SUPABASE_PUBLISHABLE_KEY" \
  --dart-define=POWERSYNC_URL="$POWERSYNC_URL"
