# Spec template: animated tray icon

Use this outline for a design document. Replace placeholders with the user's own names; do not add product names the user has not given.

```
# Feature: Animated Tray Icon

One paragraph: what the icon shows and when (activity, result).

## 1. States
Table: state | icon | tooltip | when  (idle, busy, ok, error)

## 2. Tasks That Trigger It
Table: task name | runs when

## 3. Rules
Table: frames, frame rate, minimum spinner time, ok duration, overlapping tasks,
failure tracking, idle cost, threads, icon update errors, icon size, custom icon

## 4. Design Notes
Badge position and background, colors, shapes, readability at 16 px.

## 5. Code
Module, how to create it with the tray icon, how to wrap work (run or begin/end),
quit handling.

## 6. Acceptance Tests
Table: # | scenario | expected result  (idle, fast task, overlap, failure, retry,
repeated manual refresh, quit, display scaling, dark and light taskbar)

## 7. Notes and Limits
What was tested and what was not, hidden-icon behavior, platform differences.
```

Keep the numbers (frame rate, minimum time, ok duration) identical to the code defaults: 10 fps, 0.8 s, 2 s.
