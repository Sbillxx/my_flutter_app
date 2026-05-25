---
name: Executive Command
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#45474d'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#75777d'
  outline-variant: '#c5c6cd'
  surface-tint: '#545e76'
  primary: '#051125'
  on-primary: '#ffffff'
  primary-container: '#1b263b'
  on-primary-container: '#828da7'
  inverse-primary: '#bbc6e2'
  secondary: '#2c694e'
  on-secondary: '#ffffff'
  secondary-container: '#aeeecb'
  on-secondary-container: '#316e52'
  tertiary: '#200c00'
  on-tertiary: '#ffffff'
  tertiary-container: '#3e1e00'
  on-tertiary-container: '#d57401'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d7e2ff'
  primary-fixed-dim: '#bbc6e2'
  on-primary-fixed: '#101b30'
  on-primary-fixed-variant: '#3c475d'
  secondary-fixed: '#b1f0ce'
  secondary-fixed-dim: '#95d4b3'
  on-secondary-fixed: '#002114'
  on-secondary-fixed-variant: '#0e5138'
  tertiary-fixed: '#ffdcc3'
  tertiary-fixed-dim: '#ffb77d'
  on-tertiary-fixed: '#2f1500'
  on-tertiary-fixed-variant: '#6e3900'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
  data-display:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-margin: 20px
  stack-gap: 16px
  inline-gap: 12px
  section-padding: 24px
---

## Brand & Style

The design system is engineered for high-level decision-makers who require clarity, speed, and authority. The brand personality is **sophisticated, precise, and dependable**, mirroring the mindset of an executive overseeing complex operations. 

The aesthetic follows a **Modern Corporate** movement—a refined evolution of minimalism that prioritizes data density without sacrificing legibility. By utilizing a "less but better" philosophy, the UI minimizes cognitive load through purposeful whitespace and a restricted, high-contrast color palette. The goal is to evoke a sense of "calm control," where the interface feels like a high-end dashboard of a precision instrument rather than a cluttered task tracker.

## Colors

The color strategy uses **Deep Navy Blue** as the anchor to establish institutional trust and authority. This is balanced against a **Subtle Slate Gray** background, which reduces eye strain during prolonged review sessions compared to pure white.

- **Primary (#1B263B):** Used for navigation, primary actions, and brand touchpoints.
- **Success (#2D6A4F):** Applied to positive performance indicators and "On Track" statuses.
- **Warning (#D97706):** Reserved for "At Risk" projects and urgent attention items.
- **Neutrals:** A scale of Slate grays is used for structural borders and secondary text to maintain a monochromatic hierarchy that allows status colors to "pop."

## Typography

The typography utilizes **Inter**, a typeface specifically designed for screen legibility and functional clarity. The hierarchy is highly structured to facilitate quick scanning of metrics and project titles.

- **Data-Display:** A specialized style for KPI numbers, using tight letter-spacing and bold weights to emphasize quantitative results.
- **Label-Caps:** Used for section headers and metadata to provide clear categorization without overwhelming the body text.
- **Body-MD:** The workhorse for descriptions and list items, optimized for high readability on mobile displays.

## Layout & Spacing

This design system employs a **8px linear scale** to ensure mathematical harmony across all components. 

The layout follows a **Fixed-Margin Fluid Grid** model for mobile:
- **Margins:** 20px horizontal safe-zones to prevent content from touching the screen edges.
- **Gutters:** 16px spacing between cards and multi-column elements.
- **Alignment:** All text and elements are strictly left-aligned to create a strong vertical "spine," making the interface feel organized and professional. 
- **Vertical Rhythm:** Larger 32px or 40px gaps are used between distinct content sections to provide the "ample whitespace" required for a premium feel.

## Elevation & Depth

Visual hierarchy is achieved through **Tonal Layering** supplemented by soft **Ambient Shadows**.

- **Level 0 (Background):** The Slate Gray (#F8FAFC) base.
- **Level 1 (Cards):** Pure white surfaces with a very subtle 1px border (#E2E8F0) and a soft, low-opacity shadow (Y: 2px, Blur: 4px, 4% Opacity Black). This makes KPI cards appear subtly "lifted."
- **Level 2 (Modals/Overlays):** Stronger shadows (Y: 8px, Blur: 16px, 8% Opacity Black) to indicate temporary, high-priority interaction layers.

Avoid heavy blurs or vibrant glassmorphism; the depth should feel architectural and stable.

## Shapes

The shape language uses **Level 2 (Rounded)** corners. 

- **Components (Buttons, Inputs, Cards):** 0.5rem (8px) radius. This provides a modern, approachable feel while maintaining enough structural "squareness" to feel professional and serious.
- **Status Badges:** Use a more aggressive rounding (12px or full pill) to distinguish them from interactive containers.
- **Progress Bars:** Fully rounded ends (pill-shaped) to create a sense of movement and "flow."

## Components

### KPI Cards
The primary data visualization tool. Cards feature a **Data-Display** metric in the top left, a **Label-Caps** title above it, and a small sparkline or percentage indicator in the bottom right. The background is pure white to contrast against the slate UI.

### Progress Bars
Ultra-clean, 8px height bars. The track is a light neutral (#F1F5F9) while the indicator uses the Primary, Success, or Warning color. No gradients; use solid, high-contrast fills.

### Status Badges
Small, low-profile indicators. Use a "Tonal" style: a 10% opacity background of the status color with 100% opacity bold text of the same color (e.g., Success text on a pale green background).

### Primary Buttons
Deep Navy Blue (#1B263B) with white text. Height is fixed at 48px for mobile tap-targets. Use heavy-weight Inter for the label to ensure it commands attention.

### Input Fields
Minimalist borders (1px Slate-200) that transition to the Primary Navy on focus. Labels should always be visible above the field in **Label-Caps** style.

### Lists
Lists are separated by thin 1px dividers rather than cards to maximize data density in the "Project Feed" view. Each item should have a clear 16px padding on the top and bottom.