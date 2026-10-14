# Notifications

Serverpod stores a private notification inbox for both roles. Android also
supports Firebase Cloud Messaging (FCM); other platforms use the inbox.
Email preferences are independent of inbox and device alerts.

Campaign invitations, schedule and lifecycle changes, payment/refund events,
evidence reviews, and volunteer team activity create notifications. Campaign
discussion alerts group unread messages by campaign. Opening an alert retrieves
its details through authenticated Serverpod calls before navigating to activity.
Push payloads contain a generic alert and inbox ID, without private evidence.

## Android setup

1. Register the Android application ID in Firebase. Update both
   `fieldnotes_flutter/android/app/google-services.json` and
   `fieldnotes_flutter/lib/firebase_options.dart` for that registration.
2. Enable the Firebase Cloud Messaging API and grant the server service account
   `roles/firebasecloudmessaging.admin` for the same project.
3. Supply the service account JSON through the server-only password
   `firebaseServiceAccountJson`, using
   `SERVERPOD_PASSWORD_firebaseServiceAccountJson` or the ignored
   `fieldnotes_server/config/passwords.yaml`. Never commit these credentials
   or include them in Flutter assets.
4. Start Serverpod with pending migrations applied, then rebuild the Android
   app so native Firebase configuration is included.
5. On a device with Google Play services, sign in, open Notifications, choose
   **Enable device alerts**, and grant permission.

The one-minute `fieldnote-outbox` worker delivers push with retries. The inbox
also refreshes on foreground push and polls every 60 seconds as a fallback.
Delivery timing depends on connectivity and Android background restrictions.
Sign-out unregisters the device; account deletion removes inbox and push rows.

## Verification

Trigger an invitation or campaign action from a second account. Check the
foreground inbox, background system notification, tap navigation, read state,
and grouped chat unread count. Disable email to verify that device alerts
remain independent. Keep private device screenshots and QA exports outside
the repository.
