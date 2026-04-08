RivalsSwitch — CS 371L Spring 2026 — Beta Release
Team Number: 4
Team Members: Carlos Olvera, Danny Tran, Joseph Turcios, Steven Nguyen


Contributions

Carlos Olvera (Beta release 25%, Overall 25%)
• Initial project setup and application framework (alpha)
• Core navigation and wiring between screens (alpha)
• Camera scan integration with the match and recommendation pipeline (alpha)
• Recommendation engine: scoring logic, hero matchup analysis, and end-to-end integration with saved matches (beta)
• Code cleanup, documentation-style comments, and consistency pass across controllers and styling helpers (beta)

Danny Tran (Beta release 25%, Overall 25%)
• Programmatic UI foundation, shared colors/fonts/styling, and app icon and launch assets (alpha)
• Home screen structure and navigation patterns (alpha)
• OCR and scan pipeline improvements: camera scan flow, confirm-stats and confirm-enemy screens, and session/auth fixes including stale login handling (beta)
• User preferences: UserDefaults-backed messaging tone and recommendation aggressiveness (AppPreferenceStore) wired into the app (beta)
• Hero portrait matching (HeroPortraitMatcher), expanded hero registry and icon assets for recognition and UI (beta)
• Broad UI polish across login, account creation, history, landing, and tab bar (beta)

Joseph Turcios (Beta release 25%, Overall 25%)
• Login and signup, profile storage, match history, and settings (alpha)
• Home screen redesign and improved entry points into key flows (beta)
• Profile and history enhancements, including messaging and presentation updates (beta)
• Party feature: party creation UI, party member cards and SwiftUI party views, and local party state (beta; see Differences)

Steven Nguyen (Beta release 25%, Overall 25%)
• Recommendation-oriented analysis and early camera-side logic (alpha)
• OCR for scoreboard screenshots: hero detection and KDA-style stat lines from leaderboard regions (beta)
• Scoreboard-oriented avatar assets and integration to support scan and confirmation (beta)
• Enemy team selection UX: picker / dropdown-style selection on the confirm-enemy flow (beta)
• Ongoing work on harder cases such as usernames and highlighted scoreboard text (beta; see Differences)


Differences

OCR and computer vision accuracy
The proposal assumed reliable extraction from screenshots. In practice, recognition depends on lighting, UI scale, and scoreboard layout. Hero and stat-line detection work in many cases, but accuracy is not perfect; we are still tuning thresholds, expanding reference imagery, and refining the portrait-matching path. Users can always correct detections on the confirmation screens.

Party feature scope
The party tab lets users create a party and choose heroes for slots, but selections are primarily a local, visual representation and do not yet reflect live in-game picks or full multiplayer coordination. Completing real party sync and game-accurate roles remains stretch work beyond this beta.

Text and edge cases on scoreboards
Some scoreboard elements (for example certain usernames or nonstandard text styling) are still being improved in the OCR pipeline, as noted during implementation.

Expanded preferences
Beyond the tone and recommendation-style settings described in the proposal, we implemented concrete preference storage (messaging tone and recommendation aggressiveness) so recommendations and copy can respect user choices in one place.

Navigation and polish earlier than a “minimal” beta
We continued the alpha-era direction of a cohesive, programmatic UI (shared styling, tab layout including Party and Match) so the beta reads as one product rather than disconnected prototypes.

