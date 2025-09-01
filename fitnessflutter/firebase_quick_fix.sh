#!/bin/bash

# Firebase Configuration Quick Fix Script
# For Firebase yazma testi başarısız (write test failed) issues

echo "🔥 Firebase Configuration Quick Fix"
echo "=================================="
echo ""

echo "📋 STEP 1: Firestore Database Rules Check"
echo "----------------------------------------"
echo "Go to Firebase Console:"
echo "1. https://console.firebase.google.com/"
echo "2. Select your project"
echo "3. Go to Firestore Database → Rules"
echo ""

echo "📝 STEP 2: Apply Test Rules (COPY THIS):"
echo "----------------------------------------"
cat << 'EOF'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
EOF
echo ""

echo "⚠️  WARNING: The above rules are for TESTING ONLY!"
echo "   They allow anyone to read/write your database."
echo ""

echo "🔒 STEP 3: Production Rules (For Later):"
echo "----------------------------------------"
cat << 'EOF'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
EOF
echo ""

echo "✅ STEP 4: After Applying Rules:"
echo "--------------------------------"
echo "1. Click 'Publish' in Firebase Console"
echo "2. Wait 30 seconds for propagation"
echo "3. Run Firebase Test in your app"
echo "4. Try account creation again"
echo ""

echo "🔧 STEP 5: Other Common Issues:"
echo "-------------------------------"
echo "• Authentication → Sign-in method → Enable Email/Password"
echo "• Check firebase_options.dart has correct project ID"
echo "• Verify internet connection"
echo "• Check Firebase project billing (if applicable)"
echo ""

echo "🚀 Quick Test Commands:"
echo "----------------------"
echo "• Run app: flutter run"
echo "• Click 'Firebase Test' button"
echo "• If test passes, try account creation"
echo ""

echo "Need help? Check Firebase_Configuration_Guide.md"