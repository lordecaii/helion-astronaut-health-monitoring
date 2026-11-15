# HELION

**Active readiness self-test battery for astronauts, laptop camera only, no sensors.**

**Test. Know. Be Ready.**

NASA Space Apps Challenge 2026 · Challenge: *Create Health Monitoring Software for Astronauts
on Space Missions*
Team HELION: Arel Zafer Okuklu · Kerem Çanta · Ali Yiğit Ok (Ankara, in-person)

## What is HELION?

HELION is a readiness test an astronaut on a long-duration mission runs on themselves every
day in about five minutes. No extra sensors, no wearables, no laboratory, the only hardware
is a laptop camera.

- **4 tests:** Physical Health, Memory, Social, Reaction (Sensitivity), each scored 0–100
- **1 report:** total score, the weakest area (marked red) with a personal recommendation,
  plus a day-by-day trend chart
- **2 score-free extras:** Daily Tracking (water, meals, sleep, mood, mission note to Earth)
  and a Breathing Exercise
- **Works fully offline** (one exception: the signalling step of the live video call, below)

The scientific frame is NASA's **RIDGE** model (Human Research Program): **R**adiation,
**I**solation & Confinement, **D**istance from Earth, **G**ravity, hostile/closed
**E**nvironments. HELION answers **I** and **D** directly, monitors the effects of **G** and
**E**, and does not measure radiation, it cannot be measured with a camera, and we say so
openly.

## The story: Day 112

On day 112 of a Mars transit, a solar storm cuts all communication with Earth for three days.
During those days, engineer Arel's reaction score silently falls, **82, 74, 58**, while he
still feels "fine", and Commander Kerem flags strain in the knee-raise movement for the second
day in a row. HELION's report marks the weakest area and recommends rest before the critical
course correction; the crew swaps roles, the correction goes smoothly, Arel recovers to **79**
after rest, and the knee strain never grows into an injury, because the load was reduced in
time. When the link returns, three days of queued results go to Houston as a single report
file.

*We did not rescue anyone at the last second. We caught the error and the injury before they
grew.*

## Quick start

> ⚠️ Do **not** open the files by double-clicking (file://). Browsers block the camera models
> from loading from local files; the apps must run from a local server.

**Easiest: the launcher files** (each launcher first frees its own port, then starts the
server and opens the browser):

| App | Ubuntu/Linux | Windows | Address |
|---|---|---|---|
| Astronaut | `bash Baslat-Ubuntu.sh` | `Baslat-Windows.bat` | http://localhost:8020 |
| Rater | `bash Baslat-Ubuntu.sh` | `Baslat-Windows.bat` | http://localhost:8016 |

**Manually:**

```bash
# Ubuntu / Linux
cd helion-astronot && python3 -m http.server 8020

# Windows
cd helion-astronot && py -m http.server 8020
```

Then open the address in Chrome/Chromium. Closing the terminal stops the server.

## The sections

| Section | What it measures | How |
|---|---|---|
| **Physical Health** | Mobility, strain | 9 movements (5 hand + 4 full-body); reps/angles/durations verified by the camera (MediaPipe Pose + Hand Landmarker). Strained movements are flagged. Score = completion − 5 per strained movement |
| **Memory** | Cognitive freshness | Sentence learn-and-recall test + a colour/shape sequence repeated in the same order. Model: NASA Cognition battery |
| **Social** | Communication state | Video call with a partner; the partner rates 5 criteria (eye contact, fluency, comprehension, engagement, overall communication). Score = average × 20 |
| **Reaction (Sensitivity)** | Attention / fatigue | Click a randomly appearing dot; median of 5 trials. Calibration: 350 ms → 100, 1200 ms → 0. Model: PVT / Reaction Self-Test |
| **Report** | Overall readiness | 4 scores + total (average), recommendation for the weakest area, daily indicators and the trend chart |
| **Daily Tracking** (extra) | The day's indicators | Water counter (glasses/ml), meal check-offs, sleep hours, mood (1–5), mission note to Earth |
| **Breathing Exercise** (extra) | Calming down | Box breathing 4-4-4-4 with a ring animation; 1/2/3 minutes |

## Two apps, on purpose

- **`helion-astronot/`**: the astronaut app: all tests, the report, the extras. In the Social
  section the astronaut **cannot rate themselves**, there are no rating controls; after the
  call the app simply waits for the score.
- **`helion-puanlayici/`**: the rater app: it only joins the call and rates.

Self-rating would corrupt the measurement, so the score always comes from a second pair of
eyes. The transfer is automatic and code-free: when the rater saves, the score travels over
the call's data channel, which stays open after the call ends until the delivery completes.
If the astronaut's page is closed, the score waits on the server as a retained message and
drops in by itself when the page opens.

The astronaut app also has the **"📬 Send to Earth"** panel, which works without any call:
*About Myself*, the astronaut writes a message to base; *About Someone Else*, rate a
crewmate with the same 5-criteria key plus a note. Both go into the queue, not into anyone's
own score.

## Offline design and the queue system

HELION is designed assuming the link will break (the solar-storm scenario):

- The camera models and all code live inside the app folders (`vendor/`, `models/`), nothing
  is downloaded at runtime.
- Every completed record is written to the **queue** (`helionQueue`): test scores, daily
  records, breathing sessions, mission notes, messages and ratings. The queue is **not**
  affected by session resets.
- The **⬇ Download Report** button on the home screen exports everything as a single JSON
  file, this is the file that "goes to Earth" when the link returns. **👁 Show Queue** lists
  every queued record with its time.
- The report's **trend chart** is drawn from the queue: one record per section per day, the
  last 5 days; a falling score (e.g. 82 → 74 → 58) is marked red with a ↓.
- **The one exception:** the signalling step that introduces the two devices for the live
  video call uses a public MQTT broker and needs a connection. On a local network (e.g. the
  station's own) the same step runs through a local signalling server with no internet; the
  call itself is device-to-device (WebRTC) either way.

## Data model (all on-device, localStorage)

| Key | Content |
|---|---|
| `helionResults` | Section scores and details (physical / memory / social / reaction) |
| `helionDaily` | The day's daily-tracking record (water, meals, sleep, mood, note) |
| `helionQueue` | The queue: all timestamped records (test, daily, breathing, note, social-rating, message-self, rating-about-other) |

Data leaves the device only in the JSON file the user downloads.

## Repository structure

```
helion-astronaut-health-monitoring/
├── README.md                  This file
├── helion-astronot/           The astronaut app (port 8020)
│   ├── index.html             Home screen (test cards, extras, queue, export)
│   ├── helion-fiziksel-bolum.html    Section 1, Physical (camera-verified)
│   ├── helion-hatirlama-bolum.html   Section 2, Memory
│   ├── helion-sosyallik-bolum.html   Section 3, Social (call + Send to Earth)
│   ├── helion-hassasiyet-bolum.html  Section 4, Reaction
│   ├── helion-rapor-bolum.html       Report (scores, recommendation, trend)
│   ├── helion-gunluk-takip.html      Extra, Daily Tracking + Mission Note
│   ├── helion-nefes.html             Extra, Breathing Exercise
│   ├── vendor/                MediaPipe library (local) + wasm/
│   ├── models/                pose_landmarker_lite.task, hand_landmarker.task (local)
│   ├── Baslat-Ubuntu.sh       Launcher (Linux)
│   ├── Baslat-Windows.bat     Launcher (Windows)
│   └── README.md              App notes (Turkish)
└── helion-puanlayici/         The rater app (port 8016)
    ├── index.html             Join call + rate (single page)
    ├── Baslat-Ubuntu.sh
    ├── Baslat-Windows.bat
    └── README.md
```

## Technology

Plain HTML/CSS/JavaScript, no framework, no build step. MediaPipe Tasks Vision (Pose
Landmarker Lite + Hand Landmarker) runs from local files. The Social call is WebRTC,
device-to-device; a small hand-written MQTT client handles signalling
(`wss://broker.emqx.io:8084/mqtt`) and the automatic, code-free score transfer described above.

## NASA resources

1. NASA Human Research Program, **"5 Hazards of Human Spaceflight" / "The Human Body in
   Space"** (RIDGE framework), https://www.nasa.gov/humans-in-space/the-human-body-in-space
2. NASA **Cognition** Test Battery (Basner et al., NASA HRP Task Book), the Memory model
   https://taskbook.nasaprs.com/tbp/tbpdf.cfm?id=356559081DB676F5B2C6B9D01BB07BBB
3. **Psychomotor Vigilance Test / Reaction Self-Test** on ISS (Dinges, NASA HRP Task Book)
   the Reaction model, https://taskbook.nasaprs.com/tbp/tbpdf.cfm?id=1EC326EA683537F6CA5DCAA4F042DE02

## Troubleshooting

- **"Camera models could not be loaded" banner:** you opened the page via file://. Open it
  through the launcher / localhost instead.
- **Camera does not open:** check the browser's camera permission; make sure the page is
  served from localhost.
- **Stuck on "Preparing…":** reload the page; once the models load once, it gets faster.
- **Results look old:** the app resets test results automatically at every new browser
  session (queue records are kept). The "Reset Results" button on the home screen does the
  same.
- **The score did not reach the report:** the score is sent automatically when the rater
  saves; the astronaut only needs to open the Social page (a waiting score drops in when the
  page opens). Make sure both devices are online and the rating was made in the same room.

## Important notes

- HELION is a self-test and readiness-indicator tool; **it does not make medical diagnoses.**
  A low score does not mean a health problem; regular repetition and trend tracking are the
  point.
- **Use of Super Intelligence (SI) declaration:** the team used AI assistance (Muse and Claude Code) during
  the event for software development, design and draft texts. All design decisions, tests
  and final content belong to the team, and every member can explain every part of the system.
- Final version, Ankara, November 2026.
