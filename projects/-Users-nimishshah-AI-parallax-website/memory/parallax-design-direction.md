---
name: parallax-design-direction
description: Chosen premium design direction for the Parallax Engineering website
metadata: 
  node_type: memory
  type: project
  originSessionId: 372f15c6-ff2c-41e5-8441-a4f135b9ba45
---

The Parallax Engineering Solutions LLP website (`/Users/nimishshah/AI/parallax website/index.html`) was rebuilt to a "super premium / global standard" look. After presenting three demo directions (kept in `demos/`: A cinematic-steel dark-tech, B blueprint light-editorial, C molten-luxury serif), the founder chose **"Fuse A + B"** on 2026-06-19.

Design system: deep true-black base (#070809), molten-amber accent (#FF7A18 / #FFB347) + cyan data-glow, fonts Space Grotesk (display) + Inter (body) + JetBrains Mono (technical labels/numbers). Effects: Three.js 3D wireframe hero, glassmorphism panels, ambient glow blobs, GSAP scroll reveals, custom cursor, scroll-progress bar; Blueprint detailing in inner sections — engineering grid overlay, mono spec-tables, technical numbering (01/08), section index tags [ 0X ].

**Why:** Founder felt the first reskin (kept original navy/orange + emoji icons) was "barely any change." The ui-ux-pro-max design library flagged emoji-as-icons as the #1 cheapness signal.
**How to apply:** All icons are inline SVG (Lucide-style, stroke ~1.6) — never emoji. Hidden animation states are gated behind a `.js` class with a setTimeout failsafe so content is never permanently invisible if JS/RAF fails. Honor prefers-reduced-motion.
