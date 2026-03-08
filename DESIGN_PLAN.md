# RivalsSwitch Design Plan
## Comprehensive UI/UX Design System & Implementation Guide

---

## Table of Contents
1. [Design Philosophy](#design-philosophy)
2. [Color System](#color-system)
3. [Typography](#typography)
4. [Logo & Branding Assets](#logo--branding-assets)
5. [Component Library](#component-library)
6. [Screen-by-Screen Design Specifications](#screen-by-screen-design-specifications)
7. [Animation & Transitions](#animation--transitions)
8. [Asset Organization](#asset-organization)
9. [Implementation Roadmap](#implementation-roadmap)

---

## Design Philosophy

### Core Principles
- **Marvel Rivals Aesthetic**: Dark, high-energy, competitive gaming atmosphere
- **Clarity First**: Information hierarchy must be clear even in fast-paced match scenarios
- **Consistent Identity**: Every screen should feel like part of the same cohesive experience
- **Mobile-First**: Optimized for one-handed use, large tap targets, readable at a glance
- **Performance-Focused**: Visual feedback should be immediate, animations should be smooth but not distracting

### Visual Style Direction
- **Dark Theme Primary**: Deep, rich backgrounds create focus on content
- **High Contrast**: Yellow accents pop against dark backgrounds for critical actions
- **Card-Based Layout**: Content grouped in elevated cards for better organization
- **Minimal Chrome**: Navigation and UI elements don't compete with game data
- **Gaming Aesthetic**: Sharp edges, bold typography, energy without clutter

---

## Color System

### Primary Palette

#### Background Colors
```swift
// Primary Background (Main app background)
static let primaryBackground = UIColor(hex: "#1A1A2E") // Deep dark blue-black
// Alternative: #0F0F1E for even darker variant

// Secondary Background (Cards, containers)
static let secondaryBackground = UIColor(hex: "#32324C") // User's preferred dark
// This is the main card/surface color

// Tertiary Background (Elevated elements)
static let tertiaryBackground = UIColor(hex: "#3D3D5C") // Slightly lighter for hierarchy

// Surface Overlay (Modals, sheets)
static let surfaceOverlay = UIColor(hex: "#2A2A3E") // Semi-transparent overlays
```

#### Accent Colors
```swift
// Primary Accent (Primary actions, highlights)
static let primaryAccent = UIColor(hex: "#FFD700") // Pure gold/yellow
// Alternative: #FFC107 (Amber) or #FFB800 (Warmer yellow)

// Secondary Accent (Secondary actions, info)
static let secondaryAccent = UIColor(hex: "#FFA500") // Orange-yellow for variety

// Success/Positive
static let successColor = UIColor(hex: "#4CAF50") // Green for success states

// Warning/Caution
static let warningColor = UIColor(hex: "#FF9800") // Orange for warnings

// Error/Danger
static let errorColor = UIColor(hex: "#F44336") // Red for errors

// Info/Neutral
static let infoColor = UIColor(hex: "#2196F3") // Blue for informational states
```

#### Text Colors
```swift
// Primary Text (Headings, important content)
static let primaryText = UIColor(hex: "#FFFFFF") // Pure white
// Alternative: #FFFFF8 for slightly warmer white

// Secondary Text (Body, descriptions)
static let secondaryText = UIColor(hex: "#E0E0E0") // Light gray

// Tertiary Text (Hints, placeholders)
static let tertiaryText = UIColor(hex: "#B0B0B0") // Medium gray

// Disabled Text
static let disabledText = UIColor(hex: "#666666") // Dark gray

// Accent Text (On dark backgrounds)
static let accentText = UIColor(hex: "#FFD700") // Gold for emphasis
```

#### Border & Divider Colors
```swift
// Borders
static let borderColor = UIColor(hex: "#4A4A6E") // Subtle borders
static let borderAccent = UIColor(hex: "#FFD700") // Accent borders

// Dividers
static let dividerColor = UIColor(hex: "#2A2A3E") // Subtle dividers
```

### Color Usage Guidelines

#### Background Hierarchy
- **Primary Background**: Main view background (all screens)
- **Secondary Background**: Cards, input fields, table cells
- **Tertiary Background**: Pressed states, selected items
- **Surface Overlay**: Modal backgrounds, bottom sheets

#### Accent Usage
- **Primary Accent (Gold)**: 
  - Primary action buttons
  - Active tab indicators
  - Important highlights
  - Logo elements
  - Recommendation priority indicators
  
- **Secondary Accent (Orange-Yellow)**:
  - Secondary buttons
  - Progress indicators
  - Warning states

#### Text Contrast Ratios
- Primary text on dark backgrounds: Minimum 4.5:1 (WCAG AA)
- Accent text on dark backgrounds: Minimum 3:1
- All text must be readable in both light and dark contexts

---

## Typography

### Font System

#### Primary Font Family
**SF Pro Display** (iOS system font)
- Clean, modern, highly readable
- Optimized for iOS displays
- Supports multiple weights

#### Font Weights & Usage

```swift
// Headings
static let heading1 = UIFont.systemFont(ofSize: 34, weight: .bold)      // Screen titles
static let heading2 = UIFont.systemFont(ofSize: 28, weight: .bold)      // Section headers
static let heading3 = UIFont.systemFont(ofSize: 22, weight: .semibold)  // Card titles
static let heading4 = UIFont.systemFont(ofSize: 20, weight: .semibold)  // Subsection headers

// Body Text
static let bodyLarge = UIFont.systemFont(ofSize: 17, weight: .regular)   // Primary body
static let bodyMedium = UIFont.systemFont(ofSize: 15, weight: .regular) // Secondary body
static let bodySmall = UIFont.systemFont(ofSize: 13, weight: .regular)  // Captions, hints

// UI Elements
static let buttonText = UIFont.systemFont(ofSize: 17, weight: .semibold) // Button labels
static let tabBarText = UIFont.systemFont(ofSize: 10, weight: .medium)   // Tab bar labels
static let inputText = UIFont.systemFont(ofSize: 16, weight: .regular)   // Text field input
```

#### Typography Scale
- **34pt**: App title, hero text (Login, Home welcome)
- **28pt**: Major section headers
- **22pt**: Card titles, recommendation hero names
- **20pt**: Subsection headers
- **17pt**: Body text, button labels, primary content
- **15pt**: Secondary content, descriptions
- **13pt**: Captions, metadata, timestamps
- **10pt**: Tab bar labels

#### Text Styles by Component

**Buttons**
- Primary: 17pt, Semibold, White text on gold background
- Secondary: 17pt, Medium, Gold text on transparent/dark background
- Tertiary: 15pt, Regular, Secondary text color

**Labels**
- Headers: 22-28pt, Bold/Semibold, Primary text color
- Body: 17pt, Regular, Secondary text color
- Captions: 13pt, Regular, Tertiary text color

**Input Fields**
- Placeholder: 16pt, Regular, Tertiary text color
- Input: 16pt, Regular, Primary text color

---

## Logo & Branding Assets

### Main App Logo

#### Design Concept
The RivalsSwitch logo should combine:
- **Switch Symbolism**: A stylized switch/swap icon (two arrows, circular swap, or toggle)
- **Marvel Rivals Aesthetic**: Sharp, angular, dynamic shapes
- **Color Scheme**: Gold/yellow (#FFD700) primary, white accents, dark background
- **Typography**: Bold, angular "RIVALS SWITCH" text (similar to Marvel Rivals logo style)

#### Logo Specifications

**Full Logo (Horizontal)**
- **Dimensions**: 1200x400px (3:1 ratio)
- **Format**: PNG with transparency, SVG for vector
- **Variants**: 
  - Full color (gold + white on transparent)
  - White only (for dark backgrounds)
  - Gold only (for specific use cases)
  - Monochrome (for single-color printing)

**App Icon**
- **Dimensions**: 1024x1024px (iOS App Icon)
- **Format**: PNG
- **Style**: Simplified version of logo, centered, with rounded corners applied by iOS
- **Background**: Solid #32324C or gradient from #1A1A2E to #32324C

**Loading Icon/Animation**
- **Dimensions**: 200x200px
- **Format**: Animated (Lottie JSON or frame sequence)
- **Style**: Rotating switch icon, pulsing gold accent
- **Duration**: 1-2 second loop

#### AI Generation Prompts

**For Main Logo (Nano Banana / Midjourney / DALL-E):**
```
Create a modern gaming app logo for "RivalsSwitch" - a Marvel Rivals companion app. 
Design elements: A stylized circular switch/swap icon in the center with two curved arrows forming a circle, 
representing character switching. The icon should be bold and angular with sharp edges, rendered in bright gold (#FFD700) 
with white accents. Below the icon, the text "RIVALS SWITCH" in a bold, angular, futuristic font similar to the 
Marvel Rivals logo style - sharp diagonal cuts, aggressive letterforms, all caps. The text should be white with 
a subtle gold outline or glow. Background should be transparent. Overall aesthetic: competitive gaming, high energy, 
clean and modern. Style: vector art, flat design with subtle depth, gaming aesthetic, sharp and dynamic.
```

**For App Icon (Simplified):**
```
Create a square app icon for "RivalsSwitch" - a simplified version of a switch/swap symbol. 
Center a bold, angular circular switch icon with two curved arrows forming a circle, rendered in bright gold (#FFD700) 
on a dark blue-purple background (#32324C). The icon should be large and centered, with sharp, modern edges. 
No text. Style: flat design, high contrast, gaming aesthetic, clean and minimal. The icon should be recognizable 
at small sizes (app icon dimensions).
```

**For Loading Animation Icon:**
```
Create an animated loading icon concept for "RivalsSwitch" - a circular switch/swap symbol that rotates smoothly. 
The icon should be a stylized circular switch with two curved arrows forming a circle, rendered in bright gold (#FFD700) 
with a subtle pulsing glow effect. The rotation should be smooth and continuous. Background should be transparent. 
Style: modern, clean, gaming aesthetic. The animation should feel energetic but not distracting. 
Consider a subtle scale pulse (1.0 to 1.1) combined with rotation for added dynamism.
```

**For Splash Screen Background:**
```
Create a dark, atmospheric background for a gaming app splash screen. Deep blue-purple gradient from #1A1A2E 
at the top to #32324C at the bottom. Subtle geometric patterns or energy lines in the background, very subtle, 
almost imperceptible. The overall feel should be dark, modern, gaming-focused, with a sense of anticipation and energy. 
No text or logos. Style: abstract, gradient, subtle texture, gaming aesthetic.
```

### Asset File Structure
```
RivalsSwitch/Assets.xcassets/
├── AppIcon.appiconset/
│   └── app-icon-1024.png
├── Logo.imageset/
│   ├── logo-full-color.png
│   ├── logo-white.png
│   └── logo-gold.png
├── LoadingIcon.imageset/
│   └── loading-icon.png
└── SplashBackground.imageset/
    └── splash-background.png
```

---

## Component Library

### Buttons

#### Primary Button
```swift
// Style
- Background: Primary Accent (#FFD700)
- Text: Primary Text (White, 17pt, Semibold)
- Corner Radius: 12px
- Height: 50px (minimum tap target)
- Padding: 16px horizontal
- Shadow: Subtle elevation shadow
- Pressed State: 0.9 alpha, slight scale (0.98)

// Usage: Main actions (Login, Create Account, Start Match, Save Match)
```

#### Secondary Button
```swift
// Style
- Background: Transparent
- Border: 2px solid Primary Accent (#FFD700)
- Text: Primary Accent (Gold, 17pt, Medium)
- Corner Radius: 12px
- Height: 50px
- Padding: 16px horizontal
- Pressed State: Background fill with gold at 0.2 alpha

// Usage: Secondary actions (Back, Cancel, Edit)
```

#### Tertiary Button
```swift
// Style
- Background: Transparent
- Text: Secondary Text (Light gray, 15pt, Regular)
- No border
- Height: 44px
- Padding: 12px horizontal
- Pressed State: Background fill with white at 0.1 alpha

// Usage: Less important actions, text links
```

#### Icon Button
```swift
// Style
- Background: Transparent or Secondary Background
- Icon: SF Symbol, 24pt, Primary Accent or Primary Text
- Size: 44x44px (minimum tap target)
- Corner Radius: 8px (if background)
- Pressed State: Background fill or 0.7 alpha

// Usage: Navigation, actions without text
```

### Text Fields

#### Standard Input Field
```swift
// Style
- Background: Secondary Background (#32324C)
- Border: 1px solid Border Color (#4A4A6E)
- Text: Primary Text (White, 16pt, Regular)
- Placeholder: Tertiary Text (Gray, 16pt, Regular)
- Corner Radius: 12px
- Height: 50px
- Padding: 16px horizontal
- Focused State: Border changes to Primary Accent (#FFD700), 2px width

// Usage: Username, password, hero names, stats
```

#### Search Field
```swift
// Style
- Same as Standard Input Field
- Left Icon: Magnifying glass (SF Symbol)
- Clear Button: X icon on right when text present
- Background: Slightly lighter (#3D3D5C)

// Usage: Search in History, Party
```

### Cards

#### Standard Card
```swift
// Style
- Background: Secondary Background (#32324C)
- Corner Radius: 16px
- Padding: 20px
- Shadow: Subtle elevation (offset: 0, radius: 8, opacity: 0.15)
- Border: Optional 1px solid Border Color

// Usage: Recommendations, match history items, profile sections
```

#### Elevated Card
```swift
// Style
- Background: Tertiary Background (#3D3D5C)
- Corner Radius: 16px
- Padding: 24px
- Shadow: More pronounced elevation
- Border: Optional 1px solid Border Accent (gold)

// Usage: Primary recommendations, featured content
```

### Labels

#### Section Header
```swift
// Style
- Text: Heading 2 (28pt, Bold, Primary Text)
- Spacing: 24px top margin, 16px bottom margin
- Color: Primary Text (White)

// Usage: Screen sections, major groupings
```

#### Card Title
```swift
// Style
- Text: Heading 3 (22pt, Semibold, Primary Text)
- Spacing: 0px top, 8px bottom
- Color: Primary Text (White)

// Usage: Card headers, recommendation hero names
```

#### Body Text
```swift
// Style
- Text: Body Large (17pt, Regular, Secondary Text)
- Line Height: 24px
- Spacing: 8px vertical between paragraphs
- Color: Secondary Text (Light gray)

// Usage: Descriptions, explanations, body content
```

### Navigation Elements

#### Tab Bar
```swift
// Style
- Background: Primary Background (#1A1A2E) with blur effect
- Border: Top border, 1px solid Divider Color
- Height: 49px (standard iOS) + safe area
- Item Text: Tab Bar Text (10pt, Medium)
- Selected: Primary Accent (Gold)
- Unselected: Tertiary Text (Gray)
- Icons: SF Symbols, 24pt, same color as text

// Tabs: Home, Match, History, Profile, Settings, Party
```

#### Navigation Bar
```swift
// Style
- Background: Primary Background with blur
- Title: Heading 3 (22pt, Semibold, Primary Text)
- Back Button: System back button, Primary Accent color
- Height: 44px + safe area
- Border: Bottom border, 1px solid Divider Color (optional)
```

### Alerts & Modals

#### Alert Style
```swift
// Style
- Background: Secondary Background (#32324C)
- Corner Radius: 16px
- Padding: 24px
- Title: Heading 3 (22pt, Semibold, Primary Text)
- Message: Body Medium (15pt, Regular, Secondary Text)
- Buttons: Primary/Secondary button styles
- Overlay: Surface Overlay with 0.6 alpha backdrop
```

#### Action Sheet
```swift
// Style
- Background: Secondary Background (#32324C)
- Corner Radius: 16px (top corners only)
- Items: 56px height each
- Text: Body Large (17pt, Regular, Primary Text)
- Destructive Actions: Error Color (Red)
- Cancel Button: Separate, bold, at bottom
```

---

## Screen-by-Screen Design Specifications

### 1. Launch Screen / Splash Screen

#### Purpose
First visual impression, brand identity, smooth app launch experience

#### Design Elements
- **Background**: 
  - Gradient from #1A1A2E (top) to #32324C (bottom)
  - Optional: Subtle animated particles or energy lines (very subtle)
  
- **Logo**:
  - Centered, large (200x200px equivalent)
  - Full color logo (gold + white)
  - Optional: Subtle scale animation on appear (1.0 → 1.05 → 1.0)
  
- **Loading Indicator** (if needed):
  - Below logo
  - Gold spinner or progress bar
  - Minimal, doesn't compete with logo

#### Implementation Notes
- Use `LaunchScreen.storyboard` or programmatic launch screen
- Logo should appear immediately (no delay)
- If app takes time to load, show loading indicator
- Transition to Login or Home based on auth state

#### Assets Needed
- `splash-background.png` (or gradient code)
- `logo-full-color.png` (centered)
- Optional: `loading-spinner.png` or Lottie animation

---

### 2. Login Screen

#### Purpose
User authentication entry point, establish app identity

#### Layout Structure
```
┌─────────────────────────────┐
│                             │
│      [App Logo]             │  ← Centered, 120x120px
│                             │
│    RIVALS SWITCH            │  ← App title, 28pt, Bold, Gold
│                             │
│                             │
│  ┌───────────────────────┐  │
│  │   Username            │  │  ← Text field, 50px height
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │   Password            │  │  ← Text field, 50px height
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │       LOGIN          │  │  ← Primary button, full width
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │   Create Account      │  │  ← Secondary button, full width
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

#### Design Specifications
- **Background**: Primary Background (#1A1A2E)
- **Logo**: Centered top, 120x120px, gold + white
- **App Title**: "RIVALS SWITCH" below logo, 28pt, Bold, Gold (#FFD700)
- **Text Fields**: 
  - Background: Secondary Background (#32324C)
  - Border: 1px solid Border Color, changes to gold on focus
  - Height: 50px
  - Padding: 16px horizontal
  - Corner Radius: 12px
  - Placeholder: Tertiary Text color
- **Login Button**: 
  - Primary button style
  - Full width minus 32px margins
  - Top margin: 32px from password field
- **Create Account Button**: 
  - Secondary button style
  - Full width minus 32px margins
  - Top margin: 16px from login button

#### Visual Hierarchy
1. Logo (brand identity)
2. App title (reinforce brand)
3. Input fields (functional)
4. Action buttons (primary actions)

#### Assets Needed
- `logo-full-color.png` (120x120px)
- Optional: Background pattern or gradient overlay

---

### 3. Create Account Screen

#### Purpose
New user registration, should feel welcoming but efficient

#### Layout Structure
```
┌─────────────────────────────┐
│  ← [Back]                   │  ← Navigation bar with back button
│                             │
│      Create Account         │  ← Title, 28pt, Bold, White
│                             │
│  ┌───────────────────────┐  │
│  │   Username            │  │  ← Text field
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │   Password            │  │  ← Text field
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │   Create Account      │  │  ← Primary button, full width
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

#### Design Specifications
- **Background**: Primary Background (#1A1A2E)
- **Navigation Bar**: 
  - Transparent or Primary Background
  - Back button: Gold color
  - Title: "Create Account", 22pt, Semibold, White
- **Text Fields**: Same style as Login screen
- **Create Account Button**: Primary button style, full width

#### Implementation Note
- After successful account creation, automatically log in and navigate to Home (per professor feedback)

---

### 4. Home Screen

#### Purpose
Welcome hub, quick access to start new match, show user context

#### Layout Structure
```
┌─────────────────────────────┐
│  Home              [Profile]│  ← Navigation bar
│                             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │   Welcome, [Username] │  │  ← Large welcome card
│  │                       │  │
│  │   Ready to switch?    │  │
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │   [Icon]              │  │  ← Start Match card
│  │                       │  │
│  │   Start New Match     │  │
│  │                       │  │
│  │   Scan your scoreboard│  │
│  │   and get recommendations│
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│  [Quick Stats Card]         │  ← Optional: Recent match summary
│                             │
└─────────────────────────────┘
```

#### Design Specifications
- **Background**: Primary Background (#1A1A2E)
- **Navigation Bar**: 
  - Title: "Home", 22pt, Semibold
  - Right: Profile icon button (optional)
- **Welcome Card**:
  - Background: Secondary Background (#32324C)
  - Corner Radius: 16px
  - Padding: 24px
  - Welcome Text: "Welcome, [Username]", 28pt, Bold, Gold
  - Subtitle: "Ready to switch?", 17pt, Regular, Secondary Text
- **Start Match Card**:
  - Background: Elevated Card style (Tertiary Background)
  - Corner Radius: 16px
  - Padding: 32px
  - Icon: Large camera/scan icon, 64x64px, Gold
  - Title: "Start New Match", 22pt, Semibold, White
  - Description: "Scan your scoreboard and get recommendations", 15pt, Regular, Secondary Text
  - Entire card is tappable (button-like)
  - Pressed state: Scale to 0.98, slight darken

#### Visual Hierarchy
1. Welcome message (personal connection)
2. Start Match card (primary action)
3. Optional stats (context)

#### Assets Needed
- Camera/scan icon (SF Symbol or custom)
- Optional: Decorative background elements

---

### 5. Match Screen (Match Hub)

#### Purpose
Main match workflow entry point, shows scan status, allows recommendations

#### Layout Structure
```
┌─────────────────────────────┐
│  Match                      │  ← Navigation bar
│                             │
│  ┌───────────────────────┐  │
│  │  Match Status         │  │  ← Status card
│  │                       │  │
│  │  My Hero: [Hero]      │  │
│  │  Enemy Team: [Count]  │  │
│  │  Status: [Ready/Not]  │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  [Camera Icon]         │  │  ← Scan button card
│  │                       │  │
│  │  Scan Scoreboard      │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  Get Recommendations  │  │  ← Recommendations button
│  └───────────────────────┘  │  ← Disabled until scan complete
│                             │
└─────────────────────────────┘
```

#### Design Specifications
- **Background**: Primary Background (#1A1A2E)
- **Status Card**:
  - Background: Secondary Background (#32324C)
  - Shows current match state
  - My Hero: Display detected hero or "Not set"
  - Enemy Team: Count of detected enemies
  - Status: "Ready" (gold) or "Scan Required" (gray)
- **Scan Button Card**:
  - Background: Elevated Card (Tertiary Background)
  - Large camera icon, 64x64px, Gold
  - Title: "Scan Scoreboard", 22pt, Semibold
  - Entire card tappable
- **Get Recommendations Button**:
  - Primary button style
  - Disabled state: 0.5 alpha, gray text
  - Enabled when scan is confirmed
  - Full width minus margins

#### State Management
- **No Scan**: Recommendations button disabled
- **Scan Complete**: Status shows "Ready", Recommendations enabled
- **Visual Feedback**: Status card updates with detected data

---

### 6. Camera Scan Screen

#### Purpose
Capture or select scoreboard photo, preview before processing

#### Layout Structure
```
┌─────────────────────────────┐
│  ← [Back]  Scan Match        │  ← Navigation bar
│                             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │                       │  │
│  │   [Photo Preview]     │  │  ← Image view, aspect fit
│  │                       │  │
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│  Instructions:               │  ← Help text
│  Take a photo of the         │
│  scoreboard showing all      │
│  stats and heroes            │
│                             │
│  ┌───────────────────────┐  │
│  │  [Camera Icon]        │  │  ← Take Photo button
│  │  Take Photo           │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  Use Photo            │  │  ← Primary button (when photo exists)
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  Retake Photo         │  │  ← Secondary button (when photo exists)
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

#### Design Specifications
- **Background**: Primary Background (#1A1A2E)
- **Photo Preview**:
  - Background: Secondary Background (#32324C)
  - Corner Radius: 16px
  - Border: 2px solid Border Color
  - Aspect fit, centered
  - Placeholder: Camera icon with "Tap to take photo" text
- **Instructions**:
  - Text: Body Medium (15pt, Regular, Secondary Text)
  - Centered, max width 280px
  - Top margin: 16px from preview
- **Take Photo Button**:
  - Primary button style
  - Icon + text
  - Full width minus margins
- **Use Photo Button**:
  - Primary button style
  - Only visible when photo exists
  - Full width
- **Retake Photo Button**:
  - Secondary button style
  - Only visible when photo exists
  - Full width
  - Top margin: 12px from Use Photo

#### States
- **No Photo**: Show placeholder, only "Take Photo" visible
- **Photo Selected**: Show preview, "Use Photo" and "Retake Photo" visible
- **Processing**: Show loading indicator over preview

---

### 7. Confirm My Stats Screen

#### Purpose
Verify and edit detected player stats (hero, K/D/A)

#### Layout Structure
```
┌─────────────────────────────┐
│  ← [Back]  Confirm Stats    │  ← Navigation bar
│                             │
│  Review and edit your stats │  ← Instructions
│                             │
│  ┌───────────────────────┐  │
│  │  My Hero              │  │  ← Card container
│  │  ┌─────────────────┐  │  │
│  │  │ [Hero Name]     │  │  │  ← Text field
│  │  └─────────────────┘  │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  Performance Stats    │  │  ← Card container
│  │                       │  │
│  │  Kills                │  │
│  │  ┌─────────────────┐  │  │
│  │  │ [Number]        │  │  │  ← Text field
│  │  └─────────────────┘  │  │
│  │                       │  │
│  │  Deaths               │  │
│  │  ┌─────────────────┐  │  │
│  │  │ [Number]        │  │  │
│  │  └─────────────────┘  │  │
│  │                       │  │
│  │  Assists              │  │
│  │  ┌─────────────────┐  │  │
│  │  │ [Number]        │  │  │
│  │  └─────────────────┘  │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  Done                 │  │  ← Primary button
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

#### Design Specifications
- **Background**: Primary Background (#1A1A2E)
- **Instructions**: 
  - Text: Body Medium (15pt, Regular, Secondary Text)
  - Top margin: 16px from nav bar
- **Card Containers**:
  - Background: Secondary Background (#32324C)
  - Corner Radius: 16px
  - Padding: 20px
  - Margin: 16px between cards
- **Section Headers** (within cards):
  - "My Hero", "Performance Stats"
  - Text: Heading 4 (20pt, Semibold, White)
  - Bottom margin: 12px
- **Text Fields**:
  - Standard input field style
  - Full width within card
  - Label above: Body Medium (15pt, Regular, Secondary Text)
  - Label margin: 8px bottom
- **Done Button**:
  - Primary button style
  - Full width minus margins
  - Top margin: 24px from last card

#### Visual Grouping
- Hero in separate card (most important)
- Stats grouped together (related data)
- Clear visual separation between sections

---

### 8. Confirm Enemy Team Screen

#### Purpose
Verify and edit detected enemy team composition

#### Layout Structure
```
┌─────────────────────────────┐
│  ← [Back]  Confirm Enemies  │  ← Navigation bar
│                             │
│  Review detected enemy team  │  ← Instructions
│                             │
│  ┌───────────────────────┐  │
│  │  Enemy Team           │  │  ← Card container
│  │                       │  │
│  │  Enemy 1              │  │
│  │  ┌─────────────────┐  │  │
│  │  │ [Hero Name]     │  │  │  ← Text field
│  │  └─────────────────┘  │  │
│  │                       │  │
│  │  Enemy 2              │  │
│  │  ┌─────────────────┐  │  │
│  │  │ [Hero Name]     │  │  │
│  │  └─────────────────┘  │  │
│  │  ... (Enemy 3-6)       │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  Done                 │  │  ← Primary button
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

#### Design Specifications
- **Background**: Primary Background (#1A1A2E)
- **Card Container**:
  - Background: Secondary Background (#32324C)
  - Corner Radius: 16px
  - Padding: 20px
- **Enemy Fields**:
  - Same text field style as Confirm My Stats
  - Label: "Enemy 1", "Enemy 2", etc.
  - Spacing: 16px between fields
- **Done Button**:
  - Primary button style
  - Triggers recommendation generation
  - Full width

#### Layout Optimization
- Consider scrollable view if 6 fields don't fit
- Group fields visually (maybe 2 columns on larger screens)

---

### 9. Recommendations Screen

#### Purpose
Display character switch recommendations with explanations

#### Layout Structure
```
┌─────────────────────────────┐
│  ← [Back]  Recommendations  │  ← Navigation bar
│                             │
│  Based on your performance  │  ← Context text
│  and enemy team, consider:  │
│                             │
│  ┌───────────────────────┐  │
│  │  [Gold Badge: #1]     │  │  ← Recommendation 1 (Elevated)
│  │                       │  │
│  │  Switch to: [Hero]    │  │  ← Hero name, large
│  │                       │  │
│  │  [Reason text...]     │  │  ← Explanation
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  [Badge: #2]          │  │  ← Recommendation 2
│  │                       │  │
│  │  Switch to: [Hero]    │  │
│  │                       │  │
│  │  [Reason text...]     │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  [Badge: #3]          │  │  ← Recommendation 3
│  │                       │  │
│  │  Switch to: [Hero]    │  │
│  │                       │  │
│  │  [Reason text...]     │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  Save Match           │  │  ← Primary button
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

#### Design Specifications
- **Background**: Primary Background (#1A1A2E)
- **Context Text**:
  - Body Medium (15pt, Regular, Secondary Text)
  - Centered, italic
  - Top margin: 16px
- **Recommendation Cards**:
  - **Card 1 (Top Recommendation)**:
    - Background: Elevated Card (Tertiary Background #3D3D5C)
    - Border: 2px solid Primary Accent (Gold)
    - Badge: "RECOMMENDED #1" in gold, top right
    - Hero Name: Heading 2 (28pt, Bold, Gold)
    - Reason: Body Large (17pt, Regular, Secondary Text)
    - Padding: 24px
    - Margin: 16px between cards
  
  - **Cards 2 & 3**:
    - Background: Standard Card (Secondary Background #32324C)
    - Border: 1px solid Border Color
    - Badge: "#2" or "#3" in Secondary Text
    - Hero Name: Heading 3 (22pt, Semibold, White)
    - Reason: Body Medium (15pt, Regular, Secondary Text)
    - Padding: 20px

- **Save Match Button**:
  - Primary button style
  - Full width minus margins
  - Top margin: 24px from last card
  - Shows success alert after save

#### Visual Hierarchy
1. Top recommendation (most prominent)
2. Alternative options (secondary)
3. Save action (persistence)

#### Tone-Based Styling
- **Direct**: Shorter text, bold statements
- **Neutral**: Balanced, informative
- **Encouraging**: Supportive language, positive framing

---

### 10. History Screen

#### Purpose
Display saved match history in chronological list

#### Layout Structure
```
┌─────────────────────────────┐
│  History                    │  ← Navigation bar
│                             │
│  ┌───────────────────────┐  │
│  │  [Date/Time]          │  │  ← Table cell
│  │  [Hero] | K:D:A       │  │
│  │  Enemies: [List]      │  │
│  │  Recommended: [Hero]  │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  [Date/Time]          │  │  ← More cells
│  │  ...                  │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

#### Design Specifications
- **Background**: Primary Background (#1A1A2E)
- **Table View**:
  - Background: Primary Background
  - Separator: Divider Color (#2A2A3E)
  - Row Height: Automatic (minimum 100px)
- **Table Cell**:
  - Background: Secondary Background (#32324C)
  - Corner Radius: 12px (top and bottom)
  - Margin: 8px horizontal, 4px vertical
  - Padding: 16px
  - Selected State: Tertiary Background (#3D3D5C)
- **Cell Content**:
  - **Date/Time**: Body Small (13pt, Regular, Tertiary Text), top
  - **Hero & Stats**: Body Large (17pt, Semibold, Primary Text)
  - **Enemies**: Body Medium (15pt, Regular, Secondary Text)
  - **Recommended**: Body Medium (15pt, Regular, Accent Text - Gold)
  - Line spacing: 4px between lines

#### Empty State
- **No Matches**:
  - Centered message
  - Icon: History icon, 64x64px, Tertiary Text
  - Text: "No matches saved yet", Body Large, Secondary Text
  - Subtext: "Save matches from recommendations to see them here", Body Medium, Tertiary Text

#### Cell Layout (Detailed)
```
┌─────────────────────────────┐
│  Mar 15, 2026 • 3:42 PM     │  ← Date/time, small, gray
│                             │
│  Spider-Man | K:8 D:6 A:3   │  ← Hero & stats, large, white
│                             │
│  Enemies: Iron Man, Storm,  │  ← Enemy list, medium, gray
│  Hulk, Loki                 │
│                             │
│  Recommended: Magneto       │  ← Recommendation, medium, gold
└─────────────────────────────┘
```

---

### 11. Profile Screen

#### Purpose
Display user profile information, account management, logout

#### Layout Structure
```
┌─────────────────────────────┐
│  Profile                    │  ← Navigation bar
│                             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │    [Profile Image]    │  │  ← Circular image, 120x120px
│  │                       │  │
│  │    [Username]         │  │  ← Large text, gold
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  Match Statistics     │  │  ← Stats card
│  │                       │  │
│  │  Total Matches: [N]   │  │
│  │  Switches Made: [N]   │  │
│  │  Win Rate: [%]        │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  Account Settings     │  │  ← Settings link card
│  │  →                    │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  Logout               │  │  ← Logout button (destructive)
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

#### Design Specifications
- **Background**: Primary Background (#1A1A2E)
- **Profile Header Card**:
  - Background: Secondary Background (#32324C)
  - Corner Radius: 16px
  - Padding: 32px
  - Centered content
  - Profile Image: 120x120px circle, border 3px gold
  - Username: Heading 2 (28pt, Bold, Gold)
- **Stats Card**:
  - Background: Secondary Background (#32324C)
  - Corner Radius: 16px
  - Padding: 20px
  - Section Header: "Match Statistics", Heading 4 (20pt, Semibold)
  - Stats: Body Large (17pt, Regular, Secondary Text)
  - Format: "Label: Value" with value in Gold
- **Account Settings Card**:
  - Background: Secondary Background (#32324C)
  - Corner Radius: 16px
  - Padding: 20px
  - Tappable, shows chevron
  - Text: Body Large (17pt, Regular, Primary Text)
- **Logout Button**:
  - Background: Error Color (#F44336) or transparent with red text
  - Text: Body Large (17pt, Semibold, Error Color or White)
  - Full width minus margins
  - Top margin: 24px
  - Confirmation alert before logout

#### Profile Image
- Default: Placeholder icon (user icon, SF Symbol)
- Future: User-uploaded photo (Camera/Photo Library framework)
- Circular, 120x120px, gold border

---

### 12. Settings Screen

#### Purpose
Customize app behavior: messaging tone, recommendation style

#### Layout Structure
```
┌─────────────────────────────┐
│  Settings                   │  ← Navigation bar
│                             │
│  ┌───────────────────────┐  │
│  │  Messaging Tone       │  │  ← Section card
│  │                       │  │
│  │  [Direct] [Neutral]   │  │  ← Segmented control
│  │       [Encouraging]   │  │
│  │                       │  │
│  │  Controls how the app │  │  ← Description
│  │  phrases messages     │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  Recommendation Style │  │  ← Section card
│  │                       │  │
│  │  [Only Critical]      │  │  ← Segmented control
│  │  [Balanced] [Always]  │  │
│  │                       │  │
│  │  Controls how often   │  │  ← Description
│  │  switches are suggested│ │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  Save                 │  │  ← Primary button
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

#### Design Specifications
- **Background**: Primary Background (#1A1A2E)
- **Section Cards**:
  - Background: Secondary Background (#32324C)
  - Corner Radius: 16px
  - Padding: 20px
  - Margin: 16px between cards
- **Section Headers**:
  - Text: Heading 4 (20pt, Semibold, White)
  - Bottom margin: 16px
- **Segmented Controls**:
  - Custom styled to match app theme
  - Background: Tertiary Background (#3D3D5C)
  - Selected: Primary Accent (Gold)
  - Text: Body Medium (15pt, Medium, White/Gold)
  - Corner Radius: 8px
- **Descriptions**:
  - Text: Body Small (13pt, Regular, Tertiary Text)
  - Top margin: 12px
  - Italic
- **Save Button**:
  - Primary button style
  - Full width minus margins
  - Top margin: 24px
  - Shows success feedback

#### Custom Segmented Control Styling
- Replace default iOS segmented control with custom styled version
- Selected segment: Gold background, white text
- Unselected: Dark background, gray text
- Smooth transitions between selections

#### Settings Persistence
- Save to UserDefaults
- Load on app launch
- Apply immediately when changed

---

### 13. Party Screen

#### Purpose
View friends, invite friends, share match data

#### Layout Structure
```
┌─────────────────────────────┐
│  Party                      │  ← Navigation bar
│                             │
│  ┌───────────────────────┐  │
│  │  [Icon]               │  │  ← Invite Friend button card
│  │                       │  │
│  │  Invite Friend        │  │
│  └───────────────────────┘  │
│                             │
│  Friends                    │  ← Section header
│  ┌───────────────────────┐  │
│  │  [Avatar] [Username]  │  │  ← Friend list cell
│  │  [Status: Online]     │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  [Avatar] [Username]  │  │
│  │  [Status: Offline]    │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  Share Match Data     │  │  ← Share button card
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

#### Design Specifications
- **Background**: Primary Background (#1A1A2E)
- **Invite Friend Card**:
  - Background: Elevated Card (Tertiary Background)
  - Corner Radius: 16px
  - Padding: 24px
  - Icon: Add user icon, 48x48px, Gold
  - Title: "Invite Friend", 22pt, Semibold
  - Tappable
- **Section Header**:
  - "Friends", Heading 3 (22pt, Semibold, White)
  - Top margin: 24px
  - Bottom margin: 12px
- **Friend List**:
  - Table view or custom list
  - Cell: Secondary Background (#32324C)
  - Corner Radius: 12px
  - Padding: 16px
  - Avatar: 48x48px circle
  - Username: Body Large (17pt, Semibold, White)
  - Status: Body Small (13pt, Regular, Secondary/Tertiary Text)
  - Online indicator: Green dot
- **Share Match Data Card**:
  - Background: Secondary Background (#32324C)
  - Corner Radius: 16px
  - Padding: 20px
  - Text: Body Large (17pt, Regular, Primary Text)
  - Tappable, shows share sheet

#### Empty State
- **No Friends**:
  - Centered message
  - Icon: Users icon, 64x64px
  - Text: "No friends yet", Body Large
  - Subtext: "Invite friends to share matches", Body Medium

---

## Animation & Transitions

### Screen Transitions

#### Standard Push/Pop
- **Duration**: 0.3 seconds
- **Timing**: Ease-in-out
- **Style**: Standard iOS push animation
- **Use**: Navigation between screens in same flow

#### Modal Presentation
- **Duration**: 0.35 seconds
- **Timing**: Ease-out
- **Style**: Slide up from bottom (iOS standard)
- **Use**: Settings, Profile (if modal), Create Account

#### Custom Transitions (Optional)
- **Fade**: For loading states, overlay transitions
- **Scale**: For card expansions, button presses
- **Slide**: For drawer menus, side panels

### Micro-Interactions

#### Button Press
- **Scale**: 0.98 (slight shrink)
- **Duration**: 0.1 seconds
- **Timing**: Ease-out
- **Feedback**: Haptic feedback (light impact)

#### Card Tap
- **Scale**: 0.97
- **Duration**: 0.15 seconds
- **Timing**: Ease-in-out
- **Feedback**: Haptic feedback (medium impact)

#### Text Field Focus
- **Border**: Animate from gray to gold
- **Duration**: 0.2 seconds
- **Timing**: Ease-out
- **Scale**: Border width 1px → 2px

#### Loading States
- **Spinner**: Rotating gold spinner
- **Duration**: Continuous
- **Pulse**: Subtle scale pulse (1.0 → 1.1 → 1.0)
- **Use**: Photo processing, recommendation generation

### Page-Specific Animations

#### Home Screen
- **Welcome Card**: Fade in from bottom (0.2s delay)
- **Start Match Card**: Fade in from bottom (0.4s delay)
- **Stagger**: Creates sense of hierarchy

#### Recommendations Screen
- **Cards**: Fade in sequentially (0.1s delay between)
- **Top Recommendation**: Slight scale animation (1.0 → 1.02 → 1.0)

#### History Screen
- **Cells**: Fade in as user scrolls (lazy load animation)

### Haptic Feedback

#### Light Impact
- Button taps
- Tab selection
- Toggle switches

#### Medium Impact
- Card selection
- Important actions (Save Match)
- Error states

#### Success Impact
- Successful save
- Successful login
- Scan complete

---

## Asset Organization

### File Structure
```
RivalsSwitch/
├── Assets.xcassets/
│   ├── AppIcon.appiconset/
│   │   └── app-icon-1024.png
│   ├── Logo.imageset/
│   │   ├── logo-full-color.png (@1x, @2x, @3x)
│   │   ├── logo-white.png
│   │   └── logo-gold.png
│   ├── LoadingIcon.imageset/
│   │   └── loading-icon.png
│   ├── SplashBackground.imageset/
│   │   └── splash-background.png
│   ├── Icons.imageset/
│   │   ├── camera-icon.png
│   │   ├── history-icon.png
│   │   ├── profile-icon.png
│   │   └── settings-icon.png
│   └── Colors/
│       ├── PrimaryBackground.colorset/
│       ├── SecondaryBackground.colorset/
│       ├── PrimaryAccent.colorset/
│       └── ...
├── Fonts/ (if custom fonts)
└── Animations/ (if Lottie)
    └── loading-animation.json
```

### Asset Naming Convention
- **Logos**: `logo-[variant].png`
- **Icons**: `[name]-icon.png`
- **Backgrounds**: `[name]-background.png`
- **Placeholders**: `placeholder-[name].png`

### Image Sizes
- **App Icon**: 1024x1024px
- **Logo (Full)**: 1200x400px (3:1 ratio)
- **Logo (App)**: 512x512px
- **Icons**: 64x64px (@1x), 128x128px (@2x), 192x192px (@3x)
- **Profile Images**: 240x240px (@1x), 480x480px (@2x), 720x720px (@3x)

---

## Implementation Roadmap

### Phase 1: Foundation (Week 1)
1. **Color System Implementation**
   - Create UIColor extensions for color constants
   - Define all color values in centralized file
   - Test color contrast ratios

2. **Typography System**
   - Create UIFont extensions for text styles
   - Define all font sizes and weights
   - Test readability on different screen sizes

3. **Component Library**
   - Implement button styles (Primary, Secondary, Tertiary)
   - Implement text field styles
   - Implement card components
   - Create reusable UI components

4. **Asset Integration**
   - Generate and import logo assets
   - Generate and import app icon
   - Generate loading icon
   - Organize assets in Assets.xcassets

### Phase 2: Core Screens (Week 2)
1. **Launch & Login Flow**
   - Design and implement Launch Screen
   - Redesign Login screen with new styling
   - Redesign Create Account screen
   - Implement auto-login after account creation

2. **Home & Match Flow**
   - Redesign Home screen
   - Redesign Match Hub screen
   - Redesign Camera Scan screen
   - Implement photo preview styling

3. **Confirmation Screens**
   - Redesign Confirm My Stats screen
   - Redesign Confirm Enemy Team screen
   - Implement card-based layouts
   - Add proper field styling

### Phase 3: Results & History (Week 3)
1. **Recommendations Screen**
   - Redesign with card hierarchy
   - Implement tone-based styling
   - Add visual distinction for top recommendation
   - Style save button

2. **History Screen**
   - Redesign table cells
   - Implement custom cell layout
   - Add empty state
   - Style date/time formatting

### Phase 4: Profile & Settings (Week 4)
1. **Profile Screen**
   - Design profile header
   - Implement stats card
   - Add account settings link
   - Style logout button

2. **Settings Screen**
   - Design settings cards
   - Implement custom segmented controls
   - Add descriptions
   - Implement save functionality

3. **Party Screen**
   - Design friend list
   - Implement invite card
   - Add empty state
   - Style share functionality

### Phase 5: Polish & Animation (Week 5)
1. **Animations**
   - Implement button press animations
   - Add screen transition polish
   - Implement loading states
   - Add haptic feedback

2. **Final Polish**
   - Review all screens for consistency
   - Test on different device sizes
   - Adjust spacing and margins
   - Final asset optimization

3. **Testing**
   - Test all user flows
   - Verify color contrast
   - Test animations
   - Performance testing

---

## Implementation Details

### Color System Implementation

#### Create Color Extension
```swift
// UIColor+AppColors.swift
extension UIColor {
    // Backgrounds
    static let appPrimaryBackground = UIColor(hex: "#1A1A2E")
    static let appSecondaryBackground = UIColor(hex: "#32324C")
    static let appTertiaryBackground = UIColor(hex: "#3D3D5C")
    
    // Accents
    static let appPrimaryAccent = UIColor(hex: "#FFD700")
    static let appSecondaryAccent = UIColor(hex: "#FFA500")
    
    // Text
    static let appPrimaryText = UIColor.white
    static let appSecondaryText = UIColor(hex: "#E0E0E0")
    static let appTertiaryText = UIColor(hex: "#B0B0B0")
    
    // Helper initializer
    convenience init(hex: String) {
        // Implementation for hex color conversion
    }
}
```

### Typography Implementation

#### Create Font Extension
```swift
// UIFont+AppFonts.swift
extension UIFont {
    static let appHeading1 = UIFont.systemFont(ofSize: 34, weight: .bold)
    static let appHeading2 = UIFont.systemFont(ofSize: 28, weight: .bold)
    static let appHeading3 = UIFont.systemFont(ofSize: 22, weight: .semibold)
    static let appBodyLarge = UIFont.systemFont(ofSize: 17, weight: .regular)
    // ... etc
}
```

### Button Component

#### Create Custom Button Class
```swift
// AppButton.swift
class AppButton: UIButton {
    enum Style {
        case primary
        case secondary
        case tertiary
    }
    
    var buttonStyle: Style = .primary {
        didSet {
            updateStyle()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateStyle()
    }
    
    private func updateStyle() {
        switch buttonStyle {
        case .primary:
            backgroundColor = .appPrimaryAccent
            setTitleColor(.appPrimaryText, for: .normal)
            titleLabel?.font = .appButtonText
            layer.cornerRadius = 12
        // ... etc
        }
    }
}
```

### Card Component

#### Create Card View
```swift
// AppCard.swift
class AppCard: UIView {
    enum Elevation {
        case standard
        case elevated
    }
    
    var elevation: Elevation = .standard {
        didSet {
            updateElevation()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCard()
    }
    
    private func setupCard() {
        backgroundColor = .appSecondaryBackground
        layer.cornerRadius = 16
        // Add shadow, etc.
    }
}
```

---

## Testing Checklist

### Visual Consistency
- [ ] All screens use consistent color palette
- [ ] Typography is consistent across all screens
- [ ] Button styles match design system
- [ ] Card styles are uniform
- [ ] Spacing and margins are consistent
- [ ] Icons are properly sized and colored

### Functionality
- [ ] All buttons have proper tap targets (minimum 44x44px)
- [ ] Text fields are properly styled and functional
- [ ] Navigation flows work correctly
- [ ] Animations are smooth and not jarring
- [ ] Loading states display correctly
- [ ] Empty states are informative

### Accessibility
- [ ] Color contrast meets WCAG AA standards
- [ ] Text is readable at all sizes
- [ ] Interactive elements are clearly identifiable
- [ ] VoiceOver labels are descriptive
- [ ] Dynamic Type support (if applicable)

### Device Testing
- [ ] iPhone SE (small screen)
- [ ] iPhone 14/15 (standard screen)
- [ ] iPhone 14/15 Pro Max (large screen)
- [ ] Dark mode compatibility (if applicable)
- [ ] Landscape orientation (if supported)

---

## Notes & Considerations

### Performance
- Use asset catalogs for all images
- Optimize image sizes (use @2x, @3x appropriately)
- Lazy load animations where possible
- Cache frequently used assets

### Future Enhancements
- Custom hero icons for each character
- Animated transitions between screens
- Custom tab bar icons
- Profile picture upload functionality
- Dark/light mode toggle (if needed)
- Custom fonts (if brand requires)

### Brand Consistency
- All visual elements should reinforce the Marvel Rivals gaming aesthetic
- Gold accent should be used sparingly for maximum impact
- Dark backgrounds create focus on content
- Sharp, angular elements reflect competitive gaming theme

---

## Conclusion

This design plan provides a comprehensive foundation for implementing a cohesive, visually appealing RivalsSwitch app. The design system ensures consistency across all screens while maintaining the high-energy, competitive gaming aesthetic that aligns with Marvel Rivals.

Key priorities:
1. **Consistency**: Every screen follows the same design language
2. **Clarity**: Information hierarchy is clear and readable
3. **Brand Identity**: Logo, colors, and styling reinforce app identity
4. **User Experience**: Smooth animations, clear feedback, intuitive navigation

By following this plan, the app will transform from a functional prototype into a polished, professional companion app that enhances the Marvel Rivals gaming experience.

---

**Document Version**: 1.0  
**Last Updated**: March 2026  
**Author**: Design Team  
**Status**: Ready for Implementation
