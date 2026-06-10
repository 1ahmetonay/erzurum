#!/usr/bin/env node

const admin = requireAdminSdk();

function requireAdminSdk() {
  try {
    return require("firebase-admin");
  } catch (_) {
    return require("../../functions/node_modules/firebase-admin");
  }
}

async function main() {
  const uid = process.argv[2]?.trim();

  if (!uid) {
    console.error("Kullanım: node set_first_admin.js USER_UID");
    process.exitCode = 1;
    return;
  }

  if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    console.error(
      "GOOGLE_APPLICATION_CREDENTIALS ortam değişkeni service account JSON yolunu göstermeli.",
    );
    process.exitCode = 1;
    return;
  }

  try {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
    });

    await admin.auth().setCustomUserClaims(uid, {admin: true});
    await admin.firestore().collection("users").doc(uid).set(
      {
        role: "admin",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedByAdminScript: true,
      },
      {merge: true},
    );

    console.log(`Admin custom claim ve Firestore role güncellendi: ${uid}`);
    console.log("Kullanıcının token yenilemesi için çıkış/giriş yapması gerekir.");
  } catch (error) {
    console.error("İlk admin atanamadı:", error.message ?? error);
    process.exitCode = 1;
  }
}

main();
