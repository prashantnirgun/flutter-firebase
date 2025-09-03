# flutter-firebase

## 01 Firebase Database

- Create Account
- Go to Firebase Console

## 02 Prerequisites (Run from any folder)

npm install -g firebase-tools
firebase
firebase login
firebase projects:list
dart pub global activate flutterfire_cli

# 03 add this to ~/.zshrc (Linux User)

export PATH="$PATH":"$HOME/.pub-cache/bin"
source ~/.zshrc

# 04 Run from project root

flutterfire configure
or
flutterfire configure --project=<Project Name>

# 05 pub get

flutter pub add firebase_core cloud_firestore

## 06 Create Schema

- Create Firestore database
- Create Collection
