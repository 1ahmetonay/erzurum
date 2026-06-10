import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

const useFirebaseEmulators = false;

const firebaseEmulatorLocalHost = 'localhost';
const firebaseEmulatorAndroidHost = '10.0.2.2';
const firebaseAuthEmulatorPort = 9099;
const firebaseFunctionsEmulatorPort = 5001;
const firebaseFirestoreEmulatorPort = 8080;
const firebaseStorageEmulatorPort = 9199;

Future<void> configureFirebaseEmulators() async {
  if (!useFirebaseEmulators) return;

  final host = defaultTargetPlatform == TargetPlatform.android
      ? firebaseEmulatorAndroidHost
      : firebaseEmulatorLocalHost;

  await FirebaseAuth.instance.useAuthEmulator(host, firebaseAuthEmulatorPort);
  FirebaseFirestore.instance.useFirestoreEmulator(
    host,
    firebaseFirestoreEmulatorPort,
  );
  FirebaseFunctions.instance.useFunctionsEmulator(
    host,
    firebaseFunctionsEmulatorPort,
  );
  await FirebaseStorage.instance.useStorageEmulator(
    host,
    firebaseStorageEmulatorPort,
  );
}
