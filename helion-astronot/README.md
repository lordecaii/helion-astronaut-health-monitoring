# HELION: Astronaut App

**Active readiness self-test battery, for astronauts, with only a laptop camera.**

NASA Space Apps Challenge 2026 · Challenge: *Create Health Monitoring Software for Astronauts on Space Missions*
Team HELION: Arel Zafer Okuklu · Kerem Çanta · Ali Yiğit Ok (Ankara, in-person)

**Test. Know. Be Ready.**

> This is the **astronaut app**. The separate **rater app** lives in `../helion-puanlayici/`;
> the project overview lives in the README at the repository root.

## What is it?

HELION is a readiness test that an astronaut on a long-duration mission self-administers
every day in about 5 minutes. No extra sensors, wearables or laboratory are needed; the only
hardware is a laptop camera.

- **4 tests:** Physical Health, Memory, Social, Reaction (Sensitivity), each scored 0–100
- **1 report:** total score, the weakest area (in red), a personal recommendation, and a
  day-by-day trend chart
- **2 score-free extras:** Daily Tracking (water, meals, sleep, mood, mission note to Earth)
  and a Breathing Exercise
- **Works fully offline** (one exception: the signalling step of the live video call, below)

The scientific framework is NASA's **RIDGE** model (Human Research Program): Radiation,
Isolation, Distance, Gravity, Hostile/Closed Environments. HELION answers **I** and **D**
directly, monitors the effects of **G** and **E**, and does not measure radiation (it cannot
be measured with a camera, we say this openly).

## Quick start

> ⚠️ Do **NOT** open the files by double-clicking (file://). Browsers block the camera models
> from loading from local files for security reasons; the app must run from a local server.

**Easiest: the launcher files**

- Ubuntu/Linux: open a terminal in this folder and run `bash Baslat-Ubuntu.sh`
- Windows: run `Baslat-Windows.bat`

Both first free port 8020 (in case an older server is still running), then start the server
and open the app at **http://localhost:8020**.

**Manually:**

```bash
# Ubuntu / Linux
cd helion-astronot && python3 -m http.server 8020

# Windows
cd helion-astronot && py -m http.server 8020
```

Then go to `localhost:8020` in your browser (Chrome/Chromium/Brave recommended). Closing the
terminal is enough to stop the server. If port 8020 is busy, use another port
(e.g. `python3 -m http.server 8021` → `localhost:8021`).

## Sections

| Section | What it measures | How |
|---|---|---|
| **Physical Health** | Mobility, strain | 9 movements (5 hand + 4 full-body); reps/angles/durations verified by the camera (MediaPipe Pose + Hand Landmarker). Strained movements are flagged. Score = completion − 5 per strained movement |
| **Memory** | Cognitive freshness | Sentence learn-and-recall test + a colour/shape sequence repeated in the same order. Model: NASA Cognition battery |
| **Social** | Communication state | Video call with a partner; the partner rates 5 criteria from the separate rater app (eye contact, fluency, comprehension, engagement, overall communication). Score = average × 20. **The astronaut cannot rate themselves in this app**, after the call, this app only waits for the score |
| **Reaction (Sensitivity)** | Attention / fatigue | Click a randomly appearing dot; median of 5 trials. Calibration: 350 ms → 100, 1200 ms → 0. Model: PVT / Reaction Self-Test |
| **Report** | Overall readiness | 4 scores + total (average), recommendation for the weakest area, daily indicators and the trend chart |
| **Daily Tracking** (extra) | The day's indicators | Water counter (glasses/ml), meal check-offs, sleep hours, mood (1–5), mission note to Earth |
| **Breathing Exercise** (extra) | Calming down | Box breathing 4-4-4-4 with a ring animation; 1/2/3 minutes |

## Offline operation and the queue system

HELION was designed assuming the connection will break (the solar-storm scenario):

- The camera models and all code are inside the app folder (`vendor/`, `models/`), nothing
  is downloaded from the internet at runtime.
- Every completed record is written to the **queue** (`helionQueue`): test scores, daily
  records, breathing sessions, mission notes, messages and ratings. The queue is not affected
  by session resets.
- The **⬇ Download Report** button on the home screen exports all data as a single JSON
  file, this is the file that will be "sent to Earth" when the connection returns.
- The **👁 Show Queue** button lists every queued record with its timestamp.
- The report's **trend chart** is drawn from the queue records; a score's decline over days
  (e.g. 82 → 74 → 58) is marked in red. One record is kept per section per day.
- The **"📬 Send to Earth"** panel works without any call: *About Myself*, the astronaut
  writes a message to base; *About Someone Else*, after asking who it is about, the same
  5-criteria rating key and an extra note field open. Both enter the queue and are sent to
  base on Earth when the connection is established. Ratings given here never change the
  rater's own score.
- **The one exception:** the signalling step that brings two devices together for the live
  video call uses a public MQTT server and requires a connection. On the same local network
  (e.g. the station's internal network) this step also works without the internet through a
  local signalling server; the call itself is already device-to-device (WebRTC).

## Data model (all on-device, localStorage)

| Key | Content |
|---|---|
| `helionResults` | Section scores and details (physical / memory / social / reaction) |
| `helionDaily` | The day's daily-tracking record (water, meals, sleep, mood, note) |
| `helionQueue` | The queue: all timestamped records (test, daily, breathing, note, social-rating, message-self, rating-about-other) |

Data leaves the device only in the JSON file the user downloads.

## Folder structure

```
helion-astronot/
├── index.html                        Home screen (test cards, extras, queue, export)
├── helion-fiziksel-bolum.html        Section 1, Physical (camera-verified)
├── helion-hatirlama-bolum.html       Section 2, Memory
├── helion-sosyallik-bolum.html       Section 3, Social (call + Send to Earth)
├── helion-hassasiyet-bolum.html      Section 4, Reaction
├── helion-rapor-bolum.html           Report (scores, recommendation, trend)
├── helion-gunluk-takip.html          Extra, Daily Tracking + Mission Note
├── helion-nefes.html                 Extra, Breathing Exercise
├── vendor/                           MediaPipe library (local)
│   └── wasm/                         MediaPipe WASM files (local)
├── models/                           pose_landmarker_lite.task, hand_landmarker.task (local)
├── Baslat-Ubuntu.sh                  Launcher (Linux)
├── Baslat-Windows.bat                Launcher (Windows)
└── README.md                         This file
```

## Technology

Plain HTML/CSS/JavaScript, no framework, no build step. MediaPipe Tasks Vision (Pose
Landmarker Lite + Hand Landmarker) runs from local files. The Social call is device-to-device
over WebRTC; a small hand-written MQTT client is used for signalling
(`wss://broker.emqx.io:8084/mqtt`), and the score transfer is automatic and code-free: even
if the call ends, the data channel stays open until the score has been transferred, then
closes; if the astronaut's page is closed, the score waits on the server and drops in by
itself when the page opens.

## NASA resources

1. NASA Human Research Program, **"5 Hazards of Human Spaceflight" / "The Human Body in
   Space"** (RIDGE framework)
   https://www.nasa.gov/humans-in-space/the-human-body-in-space
2. NASA **Cognition** Test Battery (Basner et al., NASA HRP Task Book), the Memory model
   https://taskbook.nasaprs.com/tbp/tbpdf.cfm?id=356559081DB676F5B2C6B9D01BB07BBB
3. **Psychomotor Vigilance Test / Reaction Self-Test** on ISS (Dinges, NASA HRP Task Book)
   the Reaction model
   https://taskbook.nasaprs.com/tbp/tbpdf.cfm?id=1EC326EA683537F6CA5DCAA4F042DE02

## Troubleshooting

- **"Camera models could not be loaded" banner:** you opened the page via file://. Open it
  through the launcher / localhost:8020.
- **Camera does not open:** check the camera permission in the browser; make sure the page
  is opened over localhost.
- **Stuck on "Preparing…":** reload the page; once the models load once, it gets faster.
- **Results look old:** the app automatically resets test results at every new browser
  session (queue records are preserved). The "Reset Results" button on the home screen does
  the same.
- **The score did not reach the report:** the score is sent automatically when the rater
  saves it; the astronaut only needs to open the Social page (a waiting score drops in when
  the page opens). Make sure both devices are online and the rating was made in the same room.

## Important notes

- HELION is a self-test and readiness-indicator tool; it does not make medical diagnoses. A
  low score does not mean there is a health problem; regular repetition and trend tracking
  are essential.
- **Super Intelligence (SI) declaration:** the team used AI assistance (Muse) during the
  event for software development, design and draft texts. All design decisions, tests and
  final content belong to the team; every team member can explain every part of the system.
- Final version, Ankara, November 2026.
