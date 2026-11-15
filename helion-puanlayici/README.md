# HELION — Rater App (Puanlayıcı)

The companion app of **HELION — Astronaut Health Monitoring Software**
(NASA Space Apps Challenge 2026, Team HELION).

This app has exactly one job: **join the social video call and rate the astronaut.**
Nothing else lives here — no tests, no reports, no self-rating.

## Why a separate app?

In HELION, the Social score must come from a **second pair of eyes**. An astronaut who
rates their own conversation corrupts the measurement, so the astronaut app
(`helion-astronot/`) contains no rating controls at all. Rating exists only here,
in the rater's hands.

## How it works

1. The astronaut starts a call in the astronaut app and shares the **room code**.
2. The rater opens this app, enters the same code and joins the call (WebRTC, device to device).
3. After the conversation, the rater presses **End & Rate** and scores the astronaut on
   5 criteria (1–5 each): eye contact, fluency, comprehension, engagement, overall communication.
4. On save, the score (average × 20 → 0–100) travels to the astronaut app **automatically**:
   - the data channel stays open after the call ends until the score is delivered;
   - if the astronaut's page is closed, the score waits as a retained MQTT message and is
     applied the next time the astronaut app opens.
5. The score lands in the astronaut's report and offline queue. The rater keeps nothing.

## How to run

| OS | Launcher | Address |
|---|---|---|
| Ubuntu | `bash Baslat-Ubuntu.sh` | http://localhost:8016 |
| Windows | `Baslat-Windows.bat` | http://localhost:8016 |

The launcher frees port 8016 first (in case an older server is still running), starts a
local server and opens the browser. Use Chrome/Chromium with a camera. The app must be
served over localhost — opening the HTML file directly (file://) will not work.

## Tech

Plain HTML/CSS/JavaScript in a single page. WebRTC for the video call, MQTT (public broker)
for signalling and score delivery. No data is stored in this app.

## Related

- Astronaut app: `../helion-astronot/`
- Project overview: the README at the repository root.
