# HONG BINGSEN · Interactive Media Arts / Game Design Portfolio

English | [中文](README.md)

**Live site: https://duyv0826.github.io/game-portfolio/**

Personal portfolio of an M.A. candidate in Interactive Media Arts (game design focus) at Macau University of Science and Technology. The site itself is pure HTML + CSS + vanilla JavaScript — no framework, no build step; open `index.html` and it runs.

**Current research: weak-purpose design in atmospheric exploration games** — does the guidance I place actually reach the player? I compare the design side (intent recorded in the system) with the player side (actual paths and behavior data).

## About

I develop through an AI-assisted workflow, leading design, validation, and integration. My work asks how guidance reaches players under weak-purpose design: in my Degree Project *Aoli*, a Unity atmospheric exploration game, a headless simulation of 420 runs (7 conditions × 60 seeds) showed that directional-only information raised collection rates from 10% to 100% and cut median completion time from 95.3s to 9.7s; the project is backed by 204 passing automated tests. The accompanying HTML5 prototype *Glimmer Field* was validated with 5 strategy bots across 220 simulated runs. My portfolio includes 20 projects across game design, interactive media, data visualization, and systems engineering.

Education: B.Sc. in Computer Science, Macau University of Science and Technology (2022–2026) → M.A. in Interactive Media Arts, game design focus (since Sept 2026).

## Degree Projects

| Project | Description |
| --- | --- |
| *Aoli* (澳里·光景) | Unity atmospheric exploration game: an island city with no task lists, where players read light, sound, and traces to understand what happened. 79 custom scripts, 204 automated tests (all passing), headless simulation + narrative director + puzzle state machine. In development. |
| *Glimmer Field* (微光原野) | Weak-purpose HTML5 prototype, playable in browser; sits at the opposite extreme of the same design axis (purposefulness / control) as the degree project. |

> Simulation results describe bot behavior under ideal execution, not player behavior. The player-side study is still pending.

## Links

| Entry | Link |
| --- | --- |
| Portfolio (20 works, several playable online) | https://duyv0826.github.io/game-portfolio/ |
| Degree project page (*Aoli* + *Glimmer Field* playable) | https://duyv0826.github.io/game-portfolio/thesis/ |
| Dev-process & design-notes appendix (18 essays, in Chinese) | https://duyv0826.github.io/game-portfolio/%E5%BC%80%E5%8F%91%E8%BF%87%E7%A8%8B%E4%B8%8E%E8%AE%BE%E8%AE%A1%E6%80%9D%E8%B7%AF.html |
| Résumé (PDF) | https://duyv0826.github.io/game-portfolio/resume.pdf |
| GitHub | https://github.com/duyv0826 |
| Itch.io | https://duyv0826.itch.io |

Email is not listed in plain text here; use the contact section on the portfolio site.

## Works (NO.00–NO.19)

### NO.00 Glimmer Field — Weak-Purpose Prototype
*Degree Project Companion · Playable*

> Strip away task lists, arrows, and progress bars—how do you prove players know where to go? A 5-tier bot × 220-run simulation answers: flow-reading scores 3.91 anomalous lights/100s, 2.7× hard-push.

An atmospheric, weak-purpose prototype built in HTML5 Canvas, paired with Aoli as the two extremes of a single axis—purposefulness and control. A companion strategy simulation runs 5 bot tiers across 220 matches of 120 seconds each. The flow-reading strategy wins with 3.91 anomalous lights per 100 seconds, 2.7× the hard-push strategy—the winning strategy matches the design intent; the losing ones don't. Unlike eye-tracking studies, this validation path needs no participants and no lab scheduling.

Tags: HTML5 · Canvas 2D · Atmospheric Exploration · Weak-Purpose Design · Strategy Simulation
Play: https://duyv0826.github.io/game-portfolio/thesis/glimmer-field.html

### NO.01 Aoli — Degree Project
*Degree Project · Ambient Exploration · In Development*

> Simulation answers half—direction alone raises collection rate from 10% to 100%, median time from 95.3s to 9.7s; adding distance or planning changes nothing. The player half remains unanswered.

An ambient exploration game built in Unity. The core question is simple: is the guidance I placed actually received by players? Engineering: 79 custom scripts, 15,000+ lines, 204 automated tests (EditMode 201 + PlayMode 3) all passing, commit history on GitHub. A headless simulation, narrative director, and puzzle state machine treat the game as a verifiable system. The first guidance simulation ran 420 trials (7 conditions × 60 seeds × 120s, 0.2s for all results): direction-only raised full fragment collection from 10% to 100% and median time from 95.3s to 9.7s; adding distance numbers (9.59s vs 9.63s) or bot pre-planning with slowdown (9.63s vs 12.68s) showed no further improvement. Boundary: this is bot behavior, not player behavior.

Tags: Unity · C# · Ambient Exploration · Weak-purpose Design · Macau Old City Patterns · Headless Simulation
Project page: https://duyv0826.github.io/game-portfolio/thesis/

### NO.02 Chrono Loop: Time-Loop Puzzle
*Game Design · Completed*

> Rewind isn't an add-on skill—it's the foundation of every puzzle: first define 'how long' and 'what state persists' on paper, then build levels.

Solo-developed core gameplay design, interaction logic, and time-rewind feature in Unity with C#. Designed tiered level difficulty and real-time feedback based on user cognitive psychology to improve retention and play experience. Created pixel art in Aseprite. The rewind mechanic was defined on paper—duration and state persistence—before level design layered on top.

Tags: Unity · C# · Aseprite · Time Rewind · Puzzle Design

### NO.03 AI-Assisted Side-Scrolling Roguelike
*Game Design · Completed*

> Difficulty shouldn't be a hardcoded curve: enemy density and attack frequency adapt in real time to player health and mistake rate—welcoming to newcomers, engaging for veterans.

Designed an AI enemy behavior tree and implemented dynamic difficulty adjustment based on player habits. Led a 4-person team as project lead, using Trello to coordinate task assignments and deliver a complete playable version on schedule.

Tags: Python · Pygame · Behavior Tree · Project Management

### NO.04 Blender 3D Digital Content Creation
*Visual Research · Completed*

> Glass and liquid were the only real challenge in this still life: layered transmission and refraction nodes, tuned with lighting until the result read clear, not gray.

Modeled the tabletop and glassware scene in Blender, handling materials and render optimization. The main technical effort went into layered transmission and refraction nodes for glass and liquid, with lighting iterated until the surfaces looked transparent rather than gray. Scripted the repeatable parts—scene assembly, camera paths, and batch rendering—in Python to keep the workflow consistent and focused on visual debugging.

Tags: Blender · Cycles · Python · Material Rendering

### NO.05 Android Interactive Snake
*Game Design · Completed*

> Snake demands millisecond turns, but touch gestures have inherent delay—the challenge is retuning hit windows and sensitivity for true responsiveness, not porting a keyboard.

Built with Kotlin in Android Studio, covering the full Android development cycle independently: touch controls, collision detection (walls and self), pause and scoring as separate states, and scene-triggered sound effects. The central design problem was gesture latency: instead of mapping keyboard input to touch, I retuned judgment windows and sensitivity until swipes felt immediate. No frame-level input-latency measurement was done, so no millisecond figures are claimed.

Tags: Android Studio · Kotlin · Touch Interaction · Mobile Development

### NO.06 YOLOv8 Vehicle Model Recognition System
*Visual Research · Completed*

> The real challenge isn't recognizing cars—it's recognizing SU7 over similar models—using 700 positive and 400 similar negative samples. n(3M) vs s(11M), nano proves optimal cost-efficiency with small data.

Built a 1,100-image dataset with a 'positive-negative sample' strategy (700 SU7 + 400 similar models), split 90/5/5. Compared YOLOv8n (3M params) and YOLOv8s (11M params) with 640×640 input and 300 epochs. Results show nano achieves optimal cost-efficiency on small datasets. Exported to ONNX for framework independence and real-time edge deployment.

Tags: Python · YOLOv8 · OpenCV · Data Augmentation

### NO.07 RTSP Streaming Server
*Interactive Media · Completed*

> No existing libraries: first diagram the state transitions of five core commands, then code from the diagram—because "runs" and "compliant" are two different things. Tested with FFplay/VLC: <200ms, 30FPS.

Built an RTSP server from scratch supporting multiple clients, fully implementing OPTIONS, DESCRIBE, SETUP, PLAY, and TEARDOWN. Designed session management and dynamically generated standard-compliant SDP descriptions. Validated with FFplay and VLC: latency under 200ms at 30FPS — player-side observations on a local link, not a claim about public-network conditions.

Tags: Python · Socket · RTSP/RTP · Multithreading

### NO.08 Chrono Loop Web: Time Rewind Prototype
*Interactive Media · Playable*

> A 5-second ring buffer, not a save system—because the trial window is that long. Death rewinds 2.5s, R rewinds 3s, aiming for core loop comprehension within 30 seconds. Click and play.

A web playable prototype porting Chrono Loop's time rewind mechanic: frame-by-frame state recording up to 5 seconds; death triggers auto rewind 2.5s or manual 3s via R. During rewind, afterimages and flow particles appear. Includes moving platforms, spikes, and timer stats, fully demonstrating the core loop of trial, rewind, retry. Mobile touch controls and responsive canvas included.

Tags: HTML5 · Canvas · JavaScript · Time Rewind · Prototype
Play: https://duyv0826.github.io/game-portfolio/chrono-web.html

### NO.09 XV6 MLFQ Scheduler: Implementation and Visual Analysis
*Systems Engineering · Completed*

> Replacing default Round-Robin with a three-level MLFQ: CPU-bound processes demote after using their time slice, I/O-bound processes stay high-priority via waiting, timer prevents starvation; scheduling logs exported to Gantt charts show interactive response indeed better than RR.

Undergraduate capstone project. Modified the XV6 kernel (proc.h / proc.c / trap.c) to extend the process control block with three fields: queuelevel (priority 0–2), ticksinqueue, and wait_ticks; completely rewrote scheduler() to implement a 3-level priority queue. New processes enter Q0 by default; CPU-bound processes automatically demote after exhausting their time slice, while I/O-bound processes retain high priority due to frequent waiting. A timer-based anti-starvation mechanism prevents low-priority processes from starving. Built a Python visualization framework that generates Gantt charts (showing MLFQ demotion) and comparative bar charts (CPU vs I/O priority retention) from system logs. Experiments confirm that MLFQ significantly improves interactive process response speed compared to default Round-Robin.

Tags: C · XV6 · MLFQ · Kernel Development · Python Visualization

### NO.10 Monogatari Series Lore Deep Dive Panorama
*Interactive Media · Playable*

> An interactive animated lore panorama from Yotsugi Ononoki, tracing motifs across 2012–2019 via draggable relationship graphs, timelines, and multi-view navigation.

A three-view interactive piece following a long-form investigation from Yotsugi Ononoki. View 1: Yotsugi's journey, linking character appearances and key events. View 2: the maker–made motif, shown as a draggable SVG relationship network where nodes move freely, connections reveal relationships, and layout can be reset. View 3: a 2012–2019 timeline comparing series releases with plot events. Eight main character portraits provide quick navigation. All facts are verified against Japanese primary sources. A single-file HTML with embedded character art, playable offline.

Tags: HTML5 · SVG · JavaScript · Data Visualization · Interactive Narrative
Play: https://duyv0826.github.io/game-portfolio/monogatari-map.html

### NO.11 Global Game Sales Data Dashboard
*Interactive Media · Completed*

> An interactive dashboard for analyzing global game sales from 1980 to 2020, with three-dimensional filtering by year, region, and genre, 5 real-time KPIs, and 5 chart types for cross-comparison.

Built from data on 16,327 games with sales of at least 100,000 copies, this interactive dashboard links three filters—year range slider, region (North America, Europe, Japan, Other), and genre (12 categories such as Action and Adventure)—so all KPIs and charts update in real time. It includes five visualizations: a stacked area chart of yearly sales trends (switchable to line comparison), a donut chart of regional sales share, a bar chart comparing genre sales, and a platform sales ranking. Dark game-style visual design, responsive layout, and data definitions transparently noted at the bottom of the page.

Tags: Data Visualization · ECharts · Interactive Dashboard · Game Industry
Open: https://duyv0826.github.io/game-portfolio/sales-dashboard.html

### NO.12 Pulsar Field: Interactive Soundscape Generator
*Interactive Media · Playable*

> A single-file interactive soundscape generator: touch the night sky to light up stardust and synthesize notes in real time—horizontal controls pitch, vertical controls velocity.

A 'deep-space instrument' concept. Clicking or dragging on the canvas creates particle stardust and real-time synthesized notes: horizontal maps to A minor pentatonic pitch, vertical to velocity, with cyan/purple/magenta/gold cycling through notes. A built-in 92 BPM cruising composer (i–VI–III–VII progression) schedules four tracks—kick, hi-hat, bass, melody—via audio-clock lookahead for strict audio-visual sync. Native Web Audio synthesis (zero samples) and Canvas 2D particles, zero dependencies. Persistent mute, reduced-motion support, mobile touch adaptation, and a ?demo=1 silent preview mode.

Tags: Web Audio · Canvas 2D · Generative Art · Audio-Visual Interaction
Play: https://duyv0826.github.io/game-portfolio/pulse-field.html

### NO.13 Stardust Catcher: An Interactive Collection Game
*Game Design · Playable*

> One rule: catch stars, dodge meteors. Everything else rides on feedback density—absorb animation, particle bursts, screen shake, combo multiplier every 5 hits, all audio synthesized live in Web Audio with zero samples.

A casual arcade game where you catch falling stars with a bubble via mouse or touch. Golden stars build combo and score, cyan rare stars give high rewards, and red meteors cost a life. As playtime increases, star spawn rate and fall speed rise. Each catch triggers absorb animation, particle bursts, and screen shake; every 5 combo hits raises the score multiplier. All music and sound effects are synthesized in real time with Web Audio (zero samples). High score persists locally. Single-file, zero dependencies, with ?demo=1 idle preview mode.

Tags: HTML5 · Canvas 2D · Web Audio · Particle System · Procedural Audio
Play: https://duyv0826.github.io/game-portfolio/%E6%98%9F%E5%B0%98%E6%8D%95%E6%89%8B.html

### NO.14 Branch Road: An LLM-Powered Instant Branching Narrative Game
*Game Design · Prototype*

> If AI offers different choices each time, will players want to know 'the other option'? This vertical slice tests that with built-in probes.

A vertical slice (0.1) of an LLM (glm-4-flash) instant branching narrative game, focused on validating fun. Fixed framework, branches generated on the fly: four clues—last train, Lin Wan's phone, 23:47 scheduled draft, terminal station—gradually hint, never explicit. Each turn generates action options; free input allowed. After 8 turns to an ending, players can view a parallel ending for 'the other choice'; the terminal station shows the 23:47 letter card, read by an edge-tts female voice. Built-in probes test the core question: 'Will you want to know the other option?' CogView pre-generates 8 scene images that switch with the story, ensuring zero wait.

Tags: LLM · AI Narrative · Branching Narrative · TTS · CogView
Source: https://github.com/duyv0826/branch-road

### NO.15 Room of Choice
*Branching Narrative Game · Playable*

> 18 endings aren't hand-written but mapped: nodes are scenes, edges are choices, traps and true endings grow from structure. A 'Run Regression Test' button self-checks the narrative graph, no manual bug-catching.

A pure front-end branching narrative game, zero dependencies and zero build, double-click to play. 4 chapters, 18 endings, 18 clues, including a fourth-chapter source true ending (chained dual clues), true ending epilogue, trap gating (false finality), exit traps (pseudo-exits), and divergence-point × trap convergence structures. Built-in clue and ending galleries (local progress save) and divergence hints; a 'Run Regression Test' button self-checks narrative graph integrity anytime; all content config-driven, engine untouched.

Tags: JavaScript · Branching Narrative · Multiple Endings · Zero Dependency
Play: https://duyv0826.github.io/room-of-choice/ · Source: https://github.com/duyv0826/room-of-choice

### NO.16 Endless Cycle: An Interactive Media Art Game
*Interactive Media · Prototype*

> Players are not the protagonist but a force of energy in the ecosystem—they can influence the direction of evolution but not control any detail of individual life. 'Letting go of control' is the only thing this work explores.

An interactive media art game centered on automatic evolution and generative audio. On screen, a community of organisms evolves over time; players inject energy through movement and clicks to guide its growth direction. Generative audio changes in real time with the state of the organisms, providing immersive feedback. Single index.html, zero dependencies; audio starts after first interaction per browser autoplay policy (M mute, Space pause, 1–4 modes).

Tags: Generative Audio · Automatic Evolution · Interactive Media · HTML5
Source: https://github.com/duyv0826/living-media-art

### NO.17 Co-Desk: Online Co-Study Desk
*Systems Engineering · Completed*

> Loneliness in solo study is an observation, not a feature request—so we sync presence, not chat: peer seats, focus states, and pomodoro timers, validated by 10 multiplayer assertions across two clients.

A runnable MVP from a Human-Computer Interaction course. An Electron + React desktop client connects to a FastAPI backend, with SQLite storing tasks, rooms, and focus records. WebSocket synchronizes online counts, peer seats, focus states, current tasks, pomodoro time remaining, ambient sound types, and encouragement card broadcasts in real time. Features include study room lists and custom rooms, account registration/login (password hashing), pomodoro timer, task sticky notes and breakdown, ambient sound simulation with seat-direction preview, focus statistics, and a study-time leaderboard. The backend can be deployed to the cloud for true internet multiplayer; clients enter the cloud address to sync across devices in the same room.

Tags: Electron · React · FastAPI · WebSocket · SQLite
Source: https://github.com/duyv0826/co-desk

### NO.18 Conversation Archive Console · AI Chat Summary MVP
*Systems Engineering · Prototype*

> Auto-summarizing chats can alter user behavior and lose detail, so a manual-trigger lightweight version returns control to the user; Ollama emits strict JSON, with local-rule summary fallback so demos never break.

An interactive MVP that condenses long conversations into three tiers of structured points: core conclusions, detail supplements, and action items. Each point links back to and highlights its source text, with single-item deletion and regeneration. A privacy toggle keeps content on-device. The engine prefers local Ollama (qwen3:8b) for strict JSON output and falls back to browser-local rule-based summaries when unavailable. P1 adds background auto-archiving on conversation switch with localStorage caching, plus smart naming (model-generated titles of ≤12 characters) and custom conversation paste. P2 adds an archive library: cross-conversation keyword search with highlighting, per-conversation topic tags and archive stats, and click-through to source conversations. Parser unit tests, the real model pipeline, and in-page self-checks all pass.

Tags: HTML5 · Ollama · Local LLM · JSON Protocol · localStorage

### NO.19 Mometa (UE5 Card Game) · Scatter-Layout Hand Interaction
*Game Design · In Development*

> Always-on scatter demoted to hold-Tab inspect—a measured decision, not a compromise: only 3–4 of 8 scattered cards stay readable, and row order anchors blind play.

Hand-UI iteration for the UE5 card game Mometa. Eight cards in a 1180px row exposed only 147px each, hiding names and values, while position-as-index spatial memory supports blind play after round three. Validated a grid-plus-jitter scatter layout in an HTML hi-fi prototype, then implemented it in UMG: click flips, double-click plays, drag flicks. Six automated acceptance steps fed coordinates into the real drag code path, passing 6/6 and catching two real bugs (rapid-click card loss, refresh interrupting a drag). Always-on scatter was quantitatively rejected; the final design is hold-Tab inspect, release to restore the row, with out-of-bounds flicks returning cards to the deck instead of tearing them. Tab input routing and real-hand flick feel await hands-on verification.

Tags: UE5 · UMG · Interaction Design · Hi-Fi Prototyping · Automated Acceptance

## Running locally

Open `index.html` directly in a browser, or serve the folder with `python -m http.server 8000` and visit `http://localhost:8000`.

---

*Works data lives in the `WORKS` array inside `index.html`. The dev-process appendix (18 essays) is currently available in Chinese only.*