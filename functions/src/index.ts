import {initializeApp} from "firebase-admin/app";
import {FieldValue, getFirestore} from "firebase-admin/firestore";
import {getAuth} from "firebase-admin/auth";
import {HttpsError, onCall} from "firebase-functions/v2/https";

initializeApp();

const db = getFirestore();

type CleanupEventData = {
  dirtyAreaId?: unknown;
  status?: unknown;
  approvalStatus?: unknown;
  pointsAwarded?: unknown;
  participantIds?: unknown;
  pointsPerParticipant?: unknown;
};

function assertAdmin(request: {auth?: {uid: string; token: Record<string, unknown>}}): string {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Giris yapman gerekiyor.");
  }
  if (request.auth.token.admin !== true) {
    throw new HttpsError("permission-denied", "Bu islem icin admin yetkisi gerekiyor.");
  }
  return request.auth.uid;
}

function requiredString(value: unknown, fieldName: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", `${fieldName} eksik.`);
  }
  return value.trim();
}

function normalizedPoints(value: unknown): number {
  if (typeof value !== "number" || !Number.isFinite(value)) return 50;
  return Math.min(200, Math.max(10, Math.round(value)));
}

function participantIdsFrom(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return Array.from(
    new Set(value.filter((item): item is string => typeof item === "string" && item.trim().length > 0)),
  ).sort();
}

function assertPendingApproval(event: CleanupEventData): void {
  if (event.status !== "pendingApproval") {
    throw new HttpsError("failed-precondition", "Bu etkinlik admin onayi beklemiyor.");
  }
  if (event.approvalStatus !== "pending") {
    throw new HttpsError("failed-precondition", "Bu etkinligin onay durumu uygun degil.");
  }
  if (event.pointsAwarded === true) {
    throw new HttpsError("failed-precondition", "Bu etkinlik icin puanlar daha once verilmis.");
  }
}

export const approveCleanupEvent = onCall(async (request) => {
  const adminUid = assertAdmin(request);
  const cleanupEventId = requiredString(request.data?.cleanupEventId, "cleanupEventId");
  const eventRef = db.collection("cleanup_events").doc(cleanupEventId);
  const proofRef = db.collection("cleanup_proofs").doc(cleanupEventId);

  await db.runTransaction(async (transaction) => {
    const eventSnapshot = await transaction.get(eventRef);
    if (!eventSnapshot.exists) {
      throw new HttpsError("not-found", "Temizlik etkinligi bulunamadi.");
    }

    const event = eventSnapshot.data() as CleanupEventData;
    assertPendingApproval(event);

    const dirtyAreaId = requiredString(event.dirtyAreaId, "dirtyAreaId");
    const participantIds = participantIdsFrom(event.participantIds);
    if (participantIds.length === 0) {
      throw new HttpsError("failed-precondition", "Katılımcı olmayan etkinlik onaylanamaz.");
    }

    const pointsPerParticipant = normalizedPoints(event.pointsPerParticipant);
    const now = FieldValue.serverTimestamp();

    transaction.update(eventRef, {
      status: "completed",
      approvalStatus: "approved",
      approvedByUserId: adminUid,
      approvedAt: now,
      pointsAwarded: true,
      pointsPerParticipant,
      updatedAt: now,
    });
    transaction.update(db.collection("dirty_areas").doc(dirtyAreaId), {
      status: "cleaned",
      updatedAt: now,
    });
    transaction.set(proofRef, {
      status: "approved",
      reviewedByUserId: adminUid,
      reviewedAt: now,
      rejectionReason: null,
    }, {merge: true});

    for (const participantId of participantIds) {
      transaction.set(db.collection("users").doc(participantId), {
        totalPoints: FieldValue.increment(pointsPerParticipant),
        weeklyPoints: FieldValue.increment(pointsPerParticipant),
        updatedAt: now,
      }, {merge: true});
    }
  });

  return {ok: true};
});

export const rejectCleanupEvent = onCall(async (request) => {
  const adminUid = assertAdmin(request);
  const cleanupEventId = requiredString(request.data?.cleanupEventId, "cleanupEventId");
  const reasonInput = typeof request.data?.reason === "string" ? request.data.reason.trim() : "";
  const reason = (reasonInput.length === 0 ? "Kanit yetersiz veya dogrulanamadi." : reasonInput).slice(0, 500);
  const eventRef = db.collection("cleanup_events").doc(cleanupEventId);
  const proofRef = db.collection("cleanup_proofs").doc(cleanupEventId);

  await db.runTransaction(async (transaction) => {
    const eventSnapshot = await transaction.get(eventRef);
    if (!eventSnapshot.exists) {
      throw new HttpsError("not-found", "Temizlik etkinligi bulunamadi.");
    }

    const event = eventSnapshot.data() as CleanupEventData;
    assertPendingApproval(event);
    const now = FieldValue.serverTimestamp();

    transaction.update(eventRef, {
      status: "planned",
      approvalStatus: "rejected",
      rejectedByUserId: adminUid,
      rejectedAt: now,
      rejectionReason: reason,
      updatedAt: now,
    });
    transaction.set(proofRef, {
      status: "rejected",
      reviewedByUserId: adminUid,
      reviewedAt: now,
      rejectionReason: reason,
    }, {merge: true});
  });

  return {ok: true};
});

export const setAdminClaim = onCall(async (request) => {
  const adminUid = assertAdmin(request);
  const targetUid = requiredString(request.data?.targetUid, "targetUid");
  const admin = request.data?.admin === true;

  await getAuth().setCustomUserClaims(targetUid, {admin});
  await db.collection("users").doc(targetUid).set({
    role: admin ? "admin" : "user",
    updatedAt: FieldValue.serverTimestamp(),
    updatedByAdminUserId: adminUid,
  }, {merge: true});

  return {ok: true};
});
