# Release limitations

FieldNote is a hackathon submission. Automated source tests do not establish
production readiness. Rehearse the Sponsor and Volunteer flows on the target
build and deployment before a public release.

## Configuration and operations

- Use Razorpay Test Mode for the hackathon demonstration. Live payments require
  provider activation, runtime secrets, webhook setup and staging verification
  of reconciliation and refunds. Creator payouts in live mode are manual;
  RazorpayX is not integrated.
- Supply real app IDs, signing, HTTPS hosts, link domains and store URLs at build
  or deployment time. Release builds reject placeholder identities.
- Configure SMTP for signup and password-reset codes, an AI provider for campaign
  drafting, and Firebase server credentials for Android push. Evidence summaries
  have a deterministic fallback when AI is unavailable.
- Review the draft privacy policy and terms and replace their entity/contact
  placeholders. Exercise consent withdrawal, data export and account deletion
  on staging, including blocked deletion when financial obligations remain.
- Back up the database and rehearse restoration and migrations on staging before
  applying them to production. Configure monitoring and incident response;
  external crash reporting is not integrated.

## App and platform limits

- Android supports Firebase device alerts. Web, iOS and desktop retain the inbox
  without push initialization. Delivery timing depends on connectivity and OS
  restrictions.
- Hindi and Tamil translations are partial machine drafts requiring native-speaker
  review. Missing strings fall back to English; server-generated reasons and PDF
  report labels can remain English.
- Native splash screens still use the Flutter template. Desktop directories are
  platform scaffolds and need release verification.
- Maps have a coordinate fallback when client keys are missing. GPS integrity
  checks do not provide device attestation. Explicit demo GPS remains labeled.
- Offline evidence capture is outside the MVP. Photos and notes remain private;
  impact reports export approved summaries without original evidence or exact GPS.

Follow [DEPLOYMENT.md](DEPLOYMENT.md) for deployment and signing,
[SECRETS_AND_EXTERNAL_SERVICES.md](SECRETS_AND_EXTERNAL_SERVICES.md) for credentials,
and [NOTIFICATIONS.md](NOTIFICATIONS.md) for Android alerts.
