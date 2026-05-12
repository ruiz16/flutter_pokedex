# Skill Registry — flutter_pokedex

**Project**: flutter_pokedex (Flutter 3+, Dart, Clean Architecture + Riverpod)  
**Generated**: 2026-05-12  
**Scope**: Project-level skills (source of truth for this project)

## Overview

This registry lists all skills available to agents working on the flutter_pokedex project. Skills are organized by domain and trigger keywords.

**Skill Sources**:
- Project-level: `.agents/skills/`, `.claude/skills/` (deduplicated; project wins)
- Global level: `~/.config/opencode/skills/`, `~/.claude/skills/`, etc. (fallback)

---

## Recommended Skills by Context

### When Building Widgets or State Management
→ Load **flutter-expert**
- Context: Widget development, Riverpod/Bloc state, GoRouter navigation, performance
- Triggers: `Flutter`, `Dart`, `widget`, `Riverpod`, `Bloc`, `GoRouter`, `cross-platform`
- Scope: Implementation

### When Adding/Fixing Tests
→ Load **flutter-testing**
- Context: Unit tests, widget tests, integration tests, test failures, mocks (Mockito/mocktail)
- Triggers: `Flutter test`, `unit test`, `widget test`, `integration test`, `golden`, `test failure`
- Scope: Testing

### When Refactoring Dart Code or Code Style Questions
→ Load **dart-best-practices**
- Context: Dart idioms, effective Dart, language features, code style
- Triggers: `Dart`, `best practices`, `code style`, `idioms`
- Scope: Quality

### When Adding Animations or Motion Effects
→ Load **flutter-animations**
- Context: Implicit animations (AnimatedContainer, AnimatedOpacity), explicit animations (AnimationController), Hero transitions, staggered animations
- Triggers: `animation`, `motion`, `AnimatedContainer`, `AnimationController`, `Hero`, `transitions`
- Scope: Implementation

### When Building UI Components or Pages
→ Load **frontend-design**
- Context: UI aesthetics, design systems, component polish
- Triggers: `design`, `UI`, `component`, `aesthetic`, `polish`, `layout`
- Scope: Design

### When Improving Accessibility
→ Load **accessibility**
- Context: WCAG 2.2, screen reader support, keyboard navigation, semantic HTML
- Triggers: `accessibility`, `a11y`, `WCAG`, `screen reader`, `keyboard`
- Scope: Quality

### When Working with Shell Scripts or CI/CD
→ Load **bash-defensive-patterns**
- Context: Robust shell scripts, CI/CD pipelines, defensive programming
- Triggers: `bash`, `shell`, `script`, `CI/CD`, `pipeline`, `defensive`
- Scope: DevOps

### When Optimizing for Search or SEO
→ Load **seo**
- Context: Search visibility, meta tags, structured data, sitemap
- Triggers: `SEO`, `search`, `optimization`, `meta`, `structured data`
- Scope: Quality

---

## Skills Index

| Skill | Domain | Role | Triggers | Scope |
|-------|--------|------|----------|-------|
| **flutter-expert** | frontend | specialist | Flutter, Dart, widget, Riverpod, Bloc, GoRouter | implementation |
| **flutter-testing** | testing | specialist | Flutter test, unit, widget, integration, mock | testing |
| **dart-best-practices** | language | specialist | Dart, best practices, code style | quality |
| **flutter-animations** | frontend | specialist | animation, motion, AnimatedContainer, Hero | implementation |
| **frontend-design** | design | specialist | design, UI, component, aesthetic | design |
| **accessibility** | quality | specialist | accessibility, a11y, WCAG, screen reader | quality |
| **bash-defensive-patterns** | devops | specialist | bash, shell, script, CI/CD, pipeline | devops |
| **seo** | marketing | specialist | SEO, search, optimization, meta | quality |

---

## Skill Descriptions

### flutter-expert
**Location**: `.agents/skills/flutter-expert/` (project-level, deduped)  
**Description**: Cross-platform application development with Flutter 3+ and Dart.  
**When to use**: Widget development, Riverpod/Bloc state management, GoRouter navigation, platform-specific implementations, performance optimization.  
**Scope**: Implementation specialist  
**Related**: react-native-expert, test-master, fullstack-guardian

### flutter-testing
**Location**: `.agents/skills/flutter-testing/` (project-level, deduped)  
**Description**: Write, fix, review, debug, and validate Flutter tests.  
**When to use**: Unit tests, widget tests, integration tests, MethodChannel/plugin mocks, Mockito/mocktail test doubles, golden/accessibility checks, CI test commands, test failures, MissingPluginException, pump/pumpAndSettle issues, finder errors, build_runner mock generation, device/web integration testing, flaky tests.  
**Scope**: Testing specialist  
**Key frameworks**: flutter_test, Mockito, mocktail, Golden tests

### dart-best-practices
**Location**: `.agents/skills/dart-best-practices/` (project-level, deduped)  
**Description**: General best practices for Dart development.  
**When to use**: Code style questions, effective Dart idioms, language features, type safety, null safety patterns.  
**Scope**: Quality specialist  
**Output**: Code examples, style recommendations, refactoring guidance

### flutter-animations
**Location**: `.agents/skills/flutter-animations/` (project-level, deduped)  
**Description**: Add, fix, refactor, debug, test, or explain Flutter animations.  
**When to use**: Implicit animations (AnimatedContainer, AnimatedOpacity, AnimatedSwitcher, TweenAnimationBuilder), explicit animations (AnimationController, Tween, CurvedAnimation, AnimatedWidget, AnimatedBuilder, transitions), Hero/shared-element transitions, staggered animations, physics-based motion, gesture-driven animations, scroll physics, curves, performance, accessibility (reduced motion), lifecycle bugs.  
**Scope**: Implementation specialist  
**Output**: Animated widgets, refactored animations, debugging solutions

### frontend-design
**Location**: `.agents/skills/frontend-design/` (project-level, deduped)  
**Description**: Create distinctive, production-grade frontend interfaces with high design quality.  
**When to use**: Building web components, pages, artifacts, UI layouts, dashboards, design systems, styling, beautification of any web/mobile UI.  
**Scope**: Design specialist  
**Output**: Polished code and UI design that avoids generic AI aesthetics

### accessibility
**Location**: `.agents/skills/accessibility/` (project-level, deduped)  
**Description**: Audit and improve web accessibility following WCAG 2.2 guidelines.  
**When to use**: Accessibility audits, WCAG compliance, screen reader support, keyboard navigation, semantic improvements.  
**Scope**: Quality specialist  
**Standards**: WCAG 2.2 Level AA

### bash-defensive-patterns
**Location**: `.agents/skills/bash-defensive-patterns/` (project-level, deduped)  
**Description**: Master defensive Bash programming techniques for production-grade scripts.  
**When to use**: Robust shell scripts, CI/CD pipelines, system utilities, fault tolerance, safety best practices.  
**Scope**: DevOps specialist  
**Output**: Safe, production-grade Bash code

### seo
**Location**: `.agents/skills/seo/` (project-level, deduped)  
**Description**: Optimize for search engine visibility and ranking.  
**When to use**: SEO improvements, search optimization, meta tag fixes, structured data, sitemap optimization, search engine optimization.  
**Scope**: Quality specialist  
**Output**: SEO recommendations, code improvements, markup suggestions

---

## Project-Level Skills vs. Global

**Project-level** (`.agents/skills/`, `.claude/skills/`): Highest priority. Deduped; if a skill exists in both, only one is registered.

**Global level** (fallback if not found at project level): User-level skills in `~/.config/opencode/skills/`, `~/.claude/skills/`, etc.

To update or add skills to this project:
1. Add/edit SKILL.md files in `.agents/skills/` or `.claude/skills/`
2. Regenerate this registry: `/skill-registry` or `openspec update registry`

---

## SDD-Specific Notes

### For /sdd-apply (Implementation)
Load **flutter-expert** for widget/Riverpod work, **flutter-testing** before writing tests, **dart-best-practices** for code style questions.

### For /sdd-verify (Testing & Validation)
Load **flutter-testing** to validate test coverage and fix failures.

### For /sdd-design (Architecture)
Context clues: If designing state management → consider **flutter-expert** patterns; if designing accessibility → load **accessibility**.

---

## Skill Invocation Quick Reference

```bash
# Before widget/state development
/skill flutter-expert

# Before test writing or fixing failures
/skill flutter-testing

# When asking about Dart code style
/skill dart-best-practices

# When implementing animations
/skill flutter-animations

# When designing UI components
/skill frontend-design

# When improving accessibility
/skill accessibility

# When writing CI/CD scripts
/skill bash-defensive-patterns

# When optimizing for search
/skill seo
```

---

**Registry Version**: 1.0  
**Last Updated**: 2026-05-12  
**Maintained By**: SDD init phase  
**Source**: `.agents/skills/`, `.claude/skills/` (project-level)
