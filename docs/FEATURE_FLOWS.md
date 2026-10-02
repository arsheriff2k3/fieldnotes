# FieldNote: features, integrations and user flows

This guide covers everything integrated into FieldNote, with a separate flow for each user group and one end-to-end story. All diagrams are Mermaid; they render on GitHub, in VS Code (with a Mermaid extension) and in most Markdown viewers.

**Related docs**
- `PRODUCTION_GAPS.md`: the audit and its current status.
- `DEPLOYMENT.md`: configuration and release.
- `SECRETS_AND_EXTERNAL_SERVICES.md`: keys and external providers.

**Contents**
1. [What FieldNote is](#1-what-fieldnote-is)
2. [System and integrations](#2-system-and-integrations)
3. [Sponsor flow](#3-sponsor-flow)
4. [Volunteer flow](#4-volunteer-flow)
5. [Account, consent and trust flow](#5-account-consent-and-trust-flow)
6. [State machines](#6-state-machines)
7. [Online and offline behaviour](#7-online-and-offline-behaviour)
8. [End-to-end story: Priya and Arjun](#8-end-to-end-story-priya-and-arjun)
9. [Rules and limits](#9-rules-and-limits)

---

## 1. What FieldNote is

FieldNote turns a sponsor's intent ("clean up the lake on Sunday") into a funded, staffed, evidence-backed local campaign. There are exactly two roles, chosen at signup and locked afterwards:

| Role | Does | Never sees |
|---|---|---|
| **Sponsor** | Creates campaigns with AI, pins a location, funds campaigns through Razorpay, invites volunteers, watches live impact, reviews evidence, handles cancel/postpone/revise | Names or locations of volunteers who haven't joined (only anonymous groups of 3 or more) |
| **Volunteer** | Publishes availability, gets AI-ranked matches, joins, travels, checks in inside a 200 m geofence, submits photo + note + summary, sees their history | Other volunteers' identities; payment details |

---

## 2. System and integrations

### 2.1 Architecture

```mermaid
flowchart LR
  subgraph Device["📱 Flutter app (Android · iOS · Web)"]
    UI["Views<br/>sponsor / volunteer / trust / shell"]
    VM["FieldnoteViewModel"]
    REPO["FieldnoteRepository<br/>(only layer calling the server)"]
    DEV["Device services<br/>GPS · camera · mic · timezone<br/>Razorpay checkout · deep links"]
    UI --> VM --> REPO
    UI --> DEV
  end

  subgraph Server["🖥️ Serverpod server"]
    EP["FieldnoteEndpoint (RPC)<br/>LegalEndpoint (public)<br/>Auth endpoints"]
    WEB["Web routes<br/>/webhooks/razorpay · /c/&lt;slug&gt;<br/>/legal/* · /.well-known/*"]
    SVC["Services<br/>lifecycle · payments · refunds<br/>notifications · deletion · rate limits<br/>matching · AI router · maps"]
    JOBS["Future calls<br/>readiness sweep (5 min)<br/>outbox (1 min)"]
    EP --> SVC
    WEB --> SVC
    JOBS --> SVC
  end

  DB[("PostgreSQL")]
  REDIS[("Redis<br/>live streams across instances")]
  STORE[("Private file storage<br/>evidence photos")]

  REPO <-- "RPC + live stream" --> EP
  SVC <--> DB
  SVC <--> REDIS
  SVC <--> STORE
  DEV -- "signed upload URL" --> STORE
```

### 2.2 External integrations

```mermaid
flowchart TB
  APP["Flutter app"]
  SRV["Serverpod server"]

  RZP["💳 Razorpay<br/>Checkout · Orders · Payments<br/>Refunds · Webhooks"]
  AI["🤖 Gemini / Groq<br/>campaign drafting · dictation<br/>evidence summaries"]
  GMAPS["🗺️ Google Maps<br/>tiles (client keys)<br/>Places · Geocoding · Routes (server key)"]
  SMTP["✉️ SMTP<br/>verification codes<br/>transactional email"]
  STORES["🏪 App Store / Play<br/>App Links · Universal Links"]

  APP -- "checkout modal" --> RZP
  SRV -- "create order · fetch payments · refund" --> RZP
  RZP -- "webhook (HMAC-signed)" --> SRV
  SRV --> AI
  APP -- "map tiles" --> GMAPS
  SRV -- "search · geocode · routes" --> GMAPS
  SRV --> SMTP
  STORES -. "/.well-known/* verification" .-> SRV
```

| Integration | Used for | If it is missing or down |
|---|---|---|
| **Razorpay** | Sponsor payments, refunds, webhook settlement | Checkout can't open. Funding never changes without server-side HMAC verification. Stuck orders are reconciled by the sweep. |
| **Gemini / Groq** (via `ai_provider_router`) | Campaign drafts from a brief, voice dictation, evidence summaries | Sponsors use the manual form. Volunteers write the summary themselves (`manualSummary`). Completion is never blocked. |
| **Google Maps** | Map tiles, place search, geocoding, travel time | Maps show a coordinate fallback panel. The geofence uses the server's own maths and never needs Google. |
| **SMTP** | Signup/reset codes, notifications | Business actions still succeed. Emails wait in the outbox and are retried. |
| **Redis** | Live campaign streams across server instances | Streams only reach clients on the same instance. |
| **Private storage** | Evidence photos (unique path per upload) | Upload fails with a clear error; it is safe to retry. |
| **Store link verification** | Opening `https://<host>/c/<slug>` in the app | Links open the web share page instead. |

### 2.3 Background jobs (they run while users are offline)

```mermaid
flowchart LR
  subgraph Sweep["⏱️ campaign-readiness-sweep · every 5 min"]
    S1["Evaluate readiness 24 h before start"]
    S2["Expire short campaigns at start → queue refunds"]
    S3["Complete campaigns at end + 2 h<br/>mark noShow / incomplete"]
    S4["Reconcile Razorpay orders stuck > 5 min<br/>expire unpaid orders > 30 min"]
    S5["Refund worker<br/>retry with backoff (6 attempts)"]
  end
  subgraph Outbox["⏱️ fieldnote-outbox · every 1 min"]
    O1["Run account deletions"]
    O2["Send queued emails<br/>(one per event per user)"]
    O3["Clean up rate-limit windows"]
  end
  WH["🔔 Razorpay webhook<br/>payment.captured · order.paid<br/>payment.failed · refund.processed/failed"]
  WH --> CREDIT["Credit / fail / reverse funding<br/>(row lock, idempotent)"]
  S4 --> CREDIT
  S5 --> CREDIT
```

---

## 3. Sponsor flow

### 3.1 Overview

```mermaid
flowchart TD
  A([Open app]) --> B[Pick role: Sponsor] --> C[Sign up with email<br/>verification code by SMTP]
  C --> D[Onboarding: organisation profile]
  D --> E[Consent gate: tick each required consent<br/>links to Privacy Policy and Terms]
  E --> F{Create a campaign}
  F -- "Type or dictate a brief" --> G[AI draft<br/>title · date · capacity · goal · checklist]
  F -- "Manual form" --> H[Fill the form]
  G --> I[Edit draft<br/>validated: goal ₹100–₹10,00,000<br/>15–1440 min · 1–500 people]
  H --> I
  I --> J[Drop a map pin<br/>GPS / search / tap]
  J --> K[Publish<br/>clientRequestId stops duplicates]
  K --> L[Share the link /c/&lt;slug&gt;<br/>or invite volunteer areas]
  K --> M[Fund it: Razorpay checkout<br/>25 / 50 / 75 / 100 % of remaining]
  M --> N{Payment result}
  N -- verified --> O[Funding bar updates<br/>email receipt]
  N -- failed / closed --> P[Shown in Payment history<br/>retry any time]
  N -- app killed mid-payment --> Q[Webhook or sweep reconciles<br/>funding still credited]
  O --> R[Impact tab: live stream<br/>joins · check-ins · evidence]
  L --> R
  R --> S{24 h before start: readiness}
  S -- confirmed --> T[Volunteers emailed:<br/>event confirmed]
  S -- short --> U[Decide: revise scope · postpone · cancel<br/>or fund / invite more]
  U --> S
  T --> V[Event day: check-ins appear live]
  V --> W[Review evidence: approve / reject with note]
  W --> X[End + 2 h: campaign completed]
  X --> Y[Payouts: Test Mode simulation<br/>Live mode: settled manually by operations]
  U -- cancel --> Z[Refunds queued → Razorpay refunds<br/>volunteers emailed: do not travel]
```

### 3.2 Payment sequence (online, with failure safety)

```mermaid
sequenceDiagram
  autonumber
  actor S as Sponsor
  participant App
  participant Srv as Server
  participant RZ as Razorpay
  S->>App: Choose amount, tap Pay
  App->>Srv: createRazorpayOrder(amountPaise, clientRequestId)
  Srv->>Srv: Lock campaign, reserve remaining balance
  Srv->>RZ: Create order
  RZ-->>Srv: order_id
  Srv-->>App: order
  App->>RZ: Open checkout modal
  alt card fails, then the retry succeeds
    RZ-->>App: payment.failed (modal stays open)
    S->>RZ: Retry
  end
  RZ-->>App: payment_id + signature
  App->>Srv: verifyRazorpayPayment
  Srv->>Srv: HMAC check → credit under row lock (once)
  Srv-->>App: verified ✅
  RZ--)Srv: webhook payment.captured (deduplicated, no double credit)
  Note over App,Srv: If the app dies before verify, the webhook<br/>or the 5-min reconciliation credits it instead.
```

### 3.3 Sponsor screens

| Tab / screen | What you do there |
|---|---|
| **Discover** | Browse open campaigns, fund any of them |
| **Create** | Brief → AI draft → edit → pin → publish |
| **Impact** | Your created *and* funded campaigns (any status), live indicator, metrics, evidence tiles, payment history button |
| **Readiness** | Revise scope, postpone, cancel (only before start), open checkout, copy invite link |
| **Volunteer reach** | Joined volunteers by name; everyone else as "N volunteers in this area", with "Invite area" |
| **Payouts** | Refund list; simulate payout (Test Mode, after completion) or the manual-settlement notice |
| **Payment history** | Verified / failed / pending / refund queued / refunded |
| **Post update** | Campaign updates volunteers can read |

---

## 4. Volunteer flow

### 4.1 Overview

```mermaid
flowchart TD
  A([Open app or a shared link]) --> B[Pick role: Volunteer] --> C[Sign up, verification code]
  C --> D[Onboarding: skills · interests · days<br/>time window · radius 1–100 km · GPS area<br/>device timezone sent]
  D --> E[Consent gate]
  E --> F[Matches: List · Map · Invites<br/>score = availability 40 + distance 30<br/>+ interests 20 + capacity 10, with reasons]
  F --> G{Join?}
  G -- full --> F
  G -- join --> H[My work: joined card]
  H --> I{Before check-in}
  I -- leave --> F
  I -- sponsor revised event --> J[Reconfirm the new details]
  J --> H
  I -- campaign cancelled --> K["Cancelled: do not travel (email too)"]
  H --> L[Travel: in-app route / map]
  L --> M{Check-in window<br/>30 min before start → end}
  M -- too early --> M2["Button: Check-in opens at HH:mm"]
  M -- open --> N[Live GPS check<br/>fresh · accurate ≤ 150 m · not mocked<br/>inside 200 m geofence]
  N -- fails --> N2[Clear reason + Open settings / move outdoors]
  N -- passes --> O[Checked in ✅ sponsor sees it live]
  O --> P[Evidence sheet: photo + typed or dictated note]
  P --> Q{AI available?}
  Q -- yes --> R[AI structured summary → edit/confirm]
  Q -- no / failed --> R2[Write the summary yourself]
  R --> S[Submit: GPS reuse if fresh, upload photo, complete]
  R2 --> S
  S --> T[Completed 🎉]
  T --> U[My impact & history<br/>review state · sponsor note · own photo]
  M -- never checked in --> V[noShow after end + 2 h]
  O -- no evidence by end + 2 h --> W[incomplete]
```

### 4.2 Check-in and evidence sequence

```mermaid
sequenceDiagram
  autonumber
  actor V as Volunteer
  participant App
  participant GPS as Device GPS
  participant Srv as Server
  participant AI as Gemini/Groq
  participant St as Storage
  V->>App: Check in
  App->>GPS: Fresh fix
  GPS-->>App: lat/lng ±accuracy, mock flag
  App->>Srv: checkIn(fix)
  Srv->>Srv: Window, accuracy ≤150 m, freshness, mock,<br/>movement continuity, haversine ≤ 200 m
  Srv-->>App: checkedIn ✅ (live event to sponsor)
  V->>App: Photo + note
  App->>Srv: analyzeCompletion(photo, note)
  alt AI configured and answering
    Srv->>AI: Structured summary
    AI-->>Srv: summary + confidence
  else no key / provider error
    Srv->>Srv: Deterministic summary of the note
  end
  Srv-->>App: proposal
  V->>App: Confirm or edit summary
  App->>Srv: getEvidenceUploadDescription
  Srv-->>App: unique upload path
  App->>St: Upload photo
  App->>Srv: completeParticipation(uploadPath, summary, fix)
  Srv->>Srv: Transaction + row lock, deadline, distance, campaign open
  Srv-->>App: completed ✅ (email + live event)
```

### 4.3 Volunteer screens

| Screen | What you do there |
|---|---|
| **Matches** (List / Map / Invites) | Ranked campaigns with reasons; "Full" campaigns can't be joined |
| **My work** | Joined cards with status, check-in window chip, leave, check in, submit; "Past and closed" section |
| **Availability** | Days, time window, radius, area (live GPS, search or pin), "I can help today" (expires daily) |
| **Evidence sheet** | Photo, note (type or dictate), AI or self-written summary, upload progress |
| **My impact & history** | Every participation, review state, sponsor note, own evidence photo |
| **Shared campaign** | Opened from `/c/<slug>` links, even when logged out (it opens after sign-in) |

---

## 5. Account, consent and trust flow

```mermaid
flowchart TD
  A([Signed in]) --> B{Consent current?<br/>policy versions from server}
  B -- no / withdrawn / new version --> C[Consent gate<br/>every required box + policy links<br/>or Sign out / Delete account]
  C --> D[Accepted → append-only consent history]
  B -- yes --> E[App]
  D --> E
  E --> F[Trust & safety]
  F --> F1[Consent status · history · Withdraw consent<br/>features stop until re-accepted]
  F --> F2[Activity log with date + time]
  F --> F3[Export my data JSON / PDF<br/>10 per day]
  F --> F4[Delete account: type DELETE]
  F4 --> G{Open obligations?}
  G -- checked in / open campaign /<br/>refund or payment pending --> H[Blocked with plain reason]
  G -- none --> I[Queued → outbox job within ~1 min]
  I --> J[Personal rows + photos + login deleted<br/>shared/financial rows anonymised]
  J --> K[Signed out on all devices · confirmation email]
  E --> L[Profile: email notifications on/off<br/>sign out · sign out all devices]
  E -. token expired .-> M[Sign-in screen: Your session expired]
```

---

## 6. State machines

### 6.1 Campaign

`status` (draft · active · completed) combined with `readinessState`:

```mermaid
stateDiagram-v2
  [*] --> Open: publish (active)
  Open --> Open: funding / joins change
  Open --> Postponed: creator postpones (before start)
  Postponed --> Open: new date, volunteers reconfirm
  Open --> Evaluated: 24 h before start (sweep)
  state Evaluated {
    [*] --> confirmed
    [*] --> fundingShort
    [*] --> volunteersShort
    [*] --> bothShort
  }
  Evaluated --> Confirmed: goal met + minimum volunteers
  Evaluated --> Short: still short
  Short --> Confirmed: more funding / joins (sweep)
  Short --> Expired: start time reached → refunds queued
  Open --> Cancelled: creator cancels before start → refunds queued
  Short --> Cancelled: creator cancels before start
  Confirmed --> Completed: end + 2 h (sweep)
  Expired --> [*]
  Cancelled --> [*]
  Completed --> [*]
```

### 6.2 Participation

```mermaid
stateDiagram-v2
  [*] --> joined: join (row lock, seat check)
  joined --> left: volunteer leaves before check-in
  left --> joined: rejoin if a seat is free
  joined --> checkedIn: inside geofence, inside window
  checkedIn --> completed: evidence submitted by end + 2 h
  joined --> cancelled: campaign cancelled / expired
  checkedIn --> cancelled: campaign expired
  joined --> noShow: campaign completed, never checked in
  checkedIn --> incomplete: no evidence by end + 2 h
  completed --> [*]
```

### 6.3 Payment and refund

```mermaid
stateDiagram-v2
  [*] --> created: order created (balance reserved)
  created --> verified: client verify / webhook / reconciliation
  created --> failed: payment.failed / order error
  created --> expired: unpaid after 30 min
  created --> verified_uncredited: paid but campaign full/closed
  verified_uncredited --> refund_pending: auto-refund queued
  verified --> refund_pending: campaign cancelled / expired
  refund_pending --> processing: refund worker calls Razorpay
  processing --> processed: refund.processed → funding reduced once
  processing --> refund_failed: retries exhausted (6)
  processing --> refund_pending: retry with backoff
```

Evidence review: `pending → approved` or `pending → rejected (note required)`. Rejected evidence is excluded from impact totals.

---

## 7. Online and offline behaviour

FieldNote is **online-first**. Every action is validated by the server: payments, geofence, seats and deadlines. The app does **not** queue actions while offline. The earlier offline outbox was removed because it stored photos insecurely and could replay one user's captures for another. What keeps working while you're offline is the background work on the server (§2.3).

### 7.1 Connectivity states in the app

```mermaid
stateDiagram-v2
  [*] --> Online
  Online --> Offline: network lost
  Offline --> Online: network back → pull to refresh / retry
  Online --> SessionExpired: 401 / token expired
  SessionExpired --> SignIn: auto sign-out, banner "session expired"
  SignIn --> Online
  state Online {
    [*] --> Live
    Live --> Reconnecting: stream dropped
    Reconnecting --> Live: backoff 1 s → 60 s
  }
```

### 7.2 What happens offline, feature by feature

| Feature | Online | Offline / weak network |
|---|---|---|
| Sign in / sign up | Email code via SMTP | Can't sign in; friendly "Can't reach FieldNote" |
| Pending role choice | Saved on the device | Kept on the device; cleared on sign-out |
| Shared link `/c/<slug>` | Opens the campaign | Remembered in memory and opened after sign-in (lost if the app is killed) |
| Browse matches / campaigns | Live data | Last loaded screen stays visible; refresh fails with an "You're offline" notice |
| Create / publish campaign | AI draft, publish | Draft stays in the form; publish fails safely. Retry reuses the same `clientRequestId`, so no duplicate |
| Pay (Razorpay) | Checkout → verify | Can't open checkout. **If the connection drops after paying**, the webhook or the 5-min reconciliation credits it |
| Live impact stream | Real-time events | Shows "Reconnecting…", reconnects automatically |
| Check in | Server geofence check | Not possible offline (server must verify location) |
| Evidence submit | Upload + complete | Fails with a clear error. Retry is safe (unique path, idempotent completion) **until end + 2 h** |
| Dictation / AI summary | AI | Volunteer can type the summary themselves |
| Maps | Google tiles | Coordinate fallback panel |
| Emails | Sent by the outbox | Queued on the server and sent when SMTP is reachable |
| Refunds | Worker → Razorpay | Retried with backoff; the user needn't be online |
| Account deletion | Request → queued | Runs on the server within ~1 min; user can be offline |

### 7.3 Online vs offline, end to end

```mermaid
sequenceDiagram
  autonumber
  actor U as User
  participant App
  participant Srv as Server
  participant Ext as Razorpay / SMTP
  Note over U,Ext: ONLINE
  U->>App: Action (join, pay, check in…)
  App->>Srv: RPC
  Srv-->>App: Result + live event
  Note over U,Ext: OFFLINE (user's device)
  U->>App: Action
  App--xSrv: Network error
  App-->>U: "You're offline", nothing half-saved
  Note over Srv,Ext: Server keeps working without the user
  Ext--)Srv: Webhook: payment captured
  Srv->>Srv: Sweep: readiness / expiry / completion / refunds
  Srv->>Ext: Outbox: emails, refunds
  Note over U,Ext: BACK ONLINE
  U->>App: Pull to refresh
  App->>Srv: RPC
  Srv-->>App: Up-to-date state (funding, statuses, emails already sent)
```

---

## 8. End-to-end story: Priya and Arjun

> **Characters (made up)**
> - **Priya Nair**, *Sponsor*, coordinator at "Green Pune Trust".
> - **Arjun Kulkarni**, *Volunteer*, engineering student in Pune.
> - **Meera**, *Volunteer*, Arjun's classmate.
> - **Campaign:** "Pashan Lake shoreline clean-up", Sunday 08:00–10:00 IST. Goal ₹25,000, capacity 20, minimum 6 volunteers.

### 8.1 Timeline

```mermaid
timeline
  title Pashan Lake clean-up, from idea to impact
  section Week before
    Monday : Priya signs up as Sponsor : dictates a brief and the AI drafts the campaign : pins Pashan Lake and publishes
    Monday evening : Priya pays ₹12,500 - first card fails, the retry succeeds : shares the /c/ link with her volunteer WhatsApp group
    Tuesday : Arjun opens the link logged out and signs up as Volunteer : sets Sat-Sun 7 am to noon, 10 km : the campaign is his top match, score 92
    Tuesday evening : Arjun joins : Meera joins
    Thursday : Priya's partner pays ₹12,500 : the app closes mid-payment and the webhook credits it anyway
  section Event weekend
    Saturday 8 am : Readiness check, 24 h before : goal met and 7 of 6 volunteers - confirmed : everyone emailed
    Sunday 7.40 am : Arjun checks in at 120 m, accuracy 18 m : Priya sees it live
    Sunday 9.30 am : Arjun photographs 14 bags of waste : AI summarises his note and he confirms
    Sunday noon : Campaign completed at end + 2 h : one no-show marked
  section After
    Monday : Priya approves the evidence : Arjun sees it approved in My impact
```

### 8.2 The story, step by step

**Monday: Priya creates and funds**

1. Priya installs FieldNote, picks **Sponsor**, signs up and enters the code from her email.
2. **Consent:** she ticks location, AI processing and evidence sharing, and opens the Privacy Policy link.
3. In **Create** she taps the mic and says: *"Lake clean-up at Pashan this Sunday morning, about 20 people, we need gloves and bags."*
4. **AI draft:** Gemini drafts the title, Sunday 08:00 (in her timezone), 120 minutes, capacity 20 and a checklist. She sets the goal to "25,000", which the app parses as 2,500,000 paise.
5. **Publish:** she drops the pin on the shoreline and taps Publish. The network blips and she taps again. The second request carries the same `clientRequestId`, so the server returns the same campaign instead of a duplicate.
6. **First payment:** she funds 50% (₹12,500). Her first card is declined *inside* the Razorpay modal and she retries with UPI. The modal stays open through the failure, so the success is verified and credited. Before this fix, that payment was silently lost on web.
7. She copies the invite: the message includes `https://<host>/c/k3J9…`, an unguessable link.

**Tuesday: Arjun discovers and joins**

8. Arjun taps the link while logged out. The app remembers it, he signs up as **Volunteer**, and after onboarding and consent it opens the campaign automatically.
9. **Onboarding:**
   - **Availability:** Sat/Sun, 07:00–12:00.
   - **Travel:** 10 km.
   - **Interests:** environment.
   - **Area:** live GPS.
   - **Timezone:** the app sends `Asia/Kolkata`, so matching uses his local time.
10. **Match score 92:** availability 40 (the window holds the whole event), distance 28 (4 km), interests 20 and capacity 4 (the campaign is already well staffed), each shown as a reason.
11. **Join:** Arjun joins. Priya's Impact tab streams "A volunteer joined", with no name, because live streams never carry names. In **Volunteer reach** she sees Arjun by name, since he joined. People nearby who haven't joined only appear as "5 volunteers in this area", and she taps **Invite area**.

**Thursday: an interrupted payment**

12. **Second payment:** Priya's partner pays the remaining ₹12,500, then the phone dies before the app can call verify.
13. **Webhook:** Razorpay sends `payment.captured`. The server checks the HMAC, deduplicates the event and credits it under a row lock. The funding bar reaches 100% the next time anyone opens the app. Had the webhook been delayed, the 5-minute reconciliation would have credited it instead.

**Saturday 08:00: the readiness check**

14. **Confirmed:** 24 hours before the start, the sweep evaluates the campaign. The goal is met and 7 volunteers have joined (minimum 6), so it is **confirmed**. All 7 get an email showing the time in their own timezone (08:00 IST).
15. **A volunteer leaves:** one volunteer realises they can't come and taps **Leave campaign**. The seat is freed and readiness recounts.

**Sunday: the event**

16. **Too early:** at 07:20 Arjun's button reads "Check-in opens at 07:30".
17. **Check-in:** at 07:40 he checks in from 120 m away with ±18 m accuracy, a fresh fix and no mock flag. The server's haversine check passes and Priya sees "checked in" live.
18. **Weak GPS:** Meera is under trees with ±210 m accuracy. The app warns "GPS accuracy is ±210 m; FieldNote needs 150 m or better. Move outdoors." She steps into the open and checks in.
19. **Evidence:**
    - **Photo and note:** at 09:30 Arjun photographs the bags and dictates *"Fourteen bags, mostly plastic, two broken bottles near the boat jetty."*
    - **Summary:** the AI structures it and he edits one word and confirms.
    - **Submit:** his 60-second-old tracking fix is reused and the photo uploads to a unique private path. Completion runs in a locked transaction.
20. **AI fallback:** if the AI provider had been down, Arjun would have seen "Write the summary myself" and submitted with `manualSummary`. Nothing would have blocked him.
21. **Weak network at submit:** the upload fails at the lake and he sees a clear error. Back on 4G ten minutes later he retries, which is safe because it's well before the 12:00 deadline.

**Sunday 12:00: completion**

22. **Completed:** at end + 2 h the sweep marks the campaign **completed**. The one volunteer who joined but never checked in becomes **noShow**. Anyone who checked in without submitting would become **incomplete**.

**Monday: review and history**

23. **Review:** Priya opens Arjun's evidence tile. It shows the provenance (GPS, time, "AI-drafted summary") and she taps **Approve**. Arjun gets an email.
24. **Arjun's history:** in **My impact & history** he sees "Completed · Approved · Pashan Lake", with his photo.
25. **Payouts:** in Test Mode, Priya can simulate the payout now that the campaign is completed. With live keys she sees "Payouts are settled manually by FieldNote operations".

### 8.3 The other branch: if the campaign falls short

```mermaid
flowchart LR
  A[Saturday 08:00<br/>₹12,500 of ₹25,000<br/>4 of 6 volunteers] --> B{bothShort}
  B -- Priya revises scope<br/>goal ₹12,000 · minimum 4 --> C[Volunteers reconfirm → confirmed]
  B -- Priya postpones a week --> D[Postponed → volunteers emailed<br/>reconfirm new date]
  B -- Priya cancels before start --> E[Refunds queued → Razorpay<br/>funding reduced once per refund<br/>volunteers: do not travel]
  B -- nobody acts --> F[Sunday 08:00 start → expired<br/>refunds queued automatically]
```

### 8.4 Later: Arjun deletes his account

26. **Blocked:** Arjun requests deletion while checked in to another campaign. He sees "You're checked in to a campaign. Finish or wait for it to close first."
27. **Deleted:** after it closes he types DELETE.
    - Within about a minute the outbox job deletes his availability, consent row, invitations, evidence photos and login.
    - His past participation stays as an anonymous record, so Priya's impact totals don't change.
    - He is signed out everywhere and gets a confirmation email.

---

## 9. Rules and limits

| Rule | Value |
|---|---|
| Matching weights | availability 40 · distance 30 · interests 20 · capacity 10 |
| Geofence | 200 m (server haversine); GPS accuracy ≤ 150 m; fix freshness ≤ 2 min; mock locations rejected |
| Check-in window | 30 min before start → end |
| Evidence deadline / completion | end + 2 h |
| Readiness decision | evaluated from 24 h before start; expires at start if still short |
| Campaign limits | goal ₹100–₹10,00,000 · 15–1440 min · capacity 1–500 · title 3–120 · description 10–4000 |
| Availability | weekdays 1–7 (≥ 1) · start < end · radius 1–100 km; "I can help today" expires at local midnight |
| Text limits | display name 80 · notes/posts 2000 · interests/skills 20 × 40 chars |
| Money | stored as integer paise; ₹ shown with Indian grouping |
| Reconciliation | orders unpaid > 5 min checked with Razorpay; > 30 min expired |
| Refund retries | up to 6, exponential backoff |
| Live stream reconnect | backoff 1 s → 60 s |
| Volunteer privacy | non-joined volunteers only in anonymous groups of ≥ 3 |
| Rate limits (per user) | AI drafts 20/h · dictation 30/h · evidence analysis 20/h · maps 600/h · matches 240/h · orders 20/h · share/invite 60/h · deletion requests 5/day · data export 10/day |
| Account deletion | refused while checked in, running an open campaign, or with a pending refund/payment; otherwise done in ~1 min |
| Languages / themes | English, Hindi, Tamil (hi/ta pending native review) · light and dark (system) |
