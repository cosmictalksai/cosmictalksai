#!/bin/bash

# 1. Install Flutter
echo "Setting up Flutter..."
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

export PATH="$PATH:`pwd`/flutter/bin"

# 2. Enable Web and verify
echo "Enabling Flutter Web..."
flutter config --enable-web
flutter doctor -v

# 3. Get dependencies
echo "Fetching dependencies..."
flutter pub get

# 4. Build Web with Environment Variables
echo "Building Flutter Web..."
flutter build web --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

echo "Build complete."
