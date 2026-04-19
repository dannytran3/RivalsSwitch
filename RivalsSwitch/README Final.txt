
Group Number: 4
Team Members: Carlos Olvera, Danny Tran, Joseph Turcios, Steven Nguyen
Project Name: RivalsSwitch

DEPENDENCIES
- Xcode 15.0+
- Swift 5
- UIKit (main UI), SwiftUI (Party feature)
- AVFoundation and Vision (camera + OCR)

How to run:
- Open the project in Xcode
- Run on an iPhone simulator (iPhone 14 or newer recommended)
- If camera is unavailable, use screenshots to test scanning

FEATURES
• Login & Account System
Allows users to create an account, log in, and store profile data
Planned: Alpha | Actual: Alpha
Notes: Worked as expected
Who: Joseph (100%)

• Navigation & App Structure
Handles tab navigation and movement between screens
Planned: Alpha | Actual: Alpha
Notes: Clean and consistent flow
Who: Carlos (100%)

• UI & Styling
Shared colors, fonts, and consistent design across the app
Planned: Alpha | Actual: Final
Notes: Continued improving for a more polished look
Who: Danny (60%), Team (40%)

• Camera Scan Flow
Captures screenshot/photo and sends it into the pipeline
Planned: Alpha | Actual: Alpha
Notes: Core feature worked early
Who: Carlos (100%)

• OCR & Detection
Extracts heroes and stats from scoreboard images
Planned: Beta | Actual: Beta
Notes: Works well but still improving accuracy
Who: Steven (100%)

• Hero Image Matching
Matches character portraits to known heroes
Planned: Beta | Actual: Beta
Notes: Improved over time with more image data
Who: Danny (100%)

• Recommendation Engine
Suggests top 3 hero switches based on matchups and performance
Planned: Beta | Actual: Final
Notes: Expanded logic and improved reasoning
Who: Carlos (100%)

• Recommendation Messages
Explains why each recommendation is helpful
Planned: Beta | Actual: Final
Notes: Made clearer and easier to read
Who: Carlos (100%)

• Reply / Team-Up System
Suggests teammates that work well with recommendations
Planned: Beta | Actual: Final
Notes: Based on researched synergy data
Who: Carlos (100%)

• Confirm Screens
Lets users correct detected stats and enemies
Planned: Beta | Actual: Beta
Notes: Helps handle OCR mistakes
Who: Danny (50%), Steven (50%)

• Enemy Selection UI
Allows manual selection of enemy heroes
Planned: Beta | Actual: Beta
Notes: Simple and effective
Who: Steven (100%)

• Match History
Stores previous matches and recommendations
Planned: Alpha | Actual: Final
Notes: Improved layout and usability
Who: Joseph (100%)

• Profile & Settings
User profile and app settings
Planned: Alpha | Actual: Final
Notes: Expanded with more options
Who: Joseph (70%), Danny (30%)

• User Preferences
Controls tone and recommendation aggressiveness
Planned: Beta | Actual: Final
Notes: Fully integrated across the app
Who: Danny (100%)

• Party Feature
Create a party and assign heroes visually
Planned: Beta | Actual: Beta
Notes: Local only (no live syncing yet)
Who: Joseph (100%)

• Overall Polish
Final improvements across UI and flow
Planned: Beta | Actual: Final
Notes: Makes the app feel complete
Who: Entire Team

DIFFERENCES / NOTES

One of the biggest challenges was OCR accuracy.
Scanning depends heavily on screenshot quality, lighting, and UI layout, so results are not always perfect. To address this, we added confirmation screens so users can fix any incorrect detections.

The party feature is currently limited to a local experience.
Users can create and view a party, but it does not yet sync with real players or live match data.

Some scoreboard text, such as usernames or unusual fonts, is still difficult to detect consistently.
This is something we continued improving, but it is not fully solved.

We also expanded beyond the original plan by adding a full user preferences system.
This allows users to control messaging tone and recommendation aggressiveness, making the app feel more personalized.

SUMMARY

RivalsSwitch is a companion app for Marvel Rivals that helps players decide when and who to switch to during a match.
By scanning the scoreboard, the app analyzes team compositions, player performance, and matchups to recommend better hero choices, explain why they work, and suggest teammates that pair well together
