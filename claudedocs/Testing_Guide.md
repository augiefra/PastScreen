# ScreenSnap Testing Guide - Phase 1

This guide provides step-by-step instructions to test the Phase 1 (P0) improvements.

---

## Quick Start

1. **Build and Run:**
   ```bash
   cd /Users/ecologni/Desktop/Clemadel/ScreenSnap/ScreenSnap
   xcodebuild -project ScreenSnap.xcodeproj -scheme ScreenSnap -configuration Debug
   ```
   Or open in Xcode and press ⌘R

2. **Check Console:**
   Open Console.app and filter for "ScreenSnap" to see diagnostic logs

---

## Test Scenarios

### 1. Fresh Install - Permission Flow

**Goal:** Verify permission management system works correctly

**Steps:**
1. Quit ScreenSnap if running
2. Reset permissions (if testing):
   ```bash
   tccutil reset ScreenCapture com.yourcompany.screensnap
   tccutil reset Accessibility com.yourcompany.screensnap
   tccutil reset UserNotifications com.yourcompany.screensnap
   ```
3. Launch ScreenSnap
4. Observe console output

**Expected Results:**
```
🔐 [APP] Requesting all necessary permissions...

═══════════════════════════════════════
📊 PERMISSION STATUS SUMMARY
═══════════════════════════════════════
📱 Screen Recording: ❌ Denied
♿️ Accessibility:     ❌ Denied
🔔 Notifications:     ⏳ Not Determined
═══════════════════════════════════════
```

5. Grant Screen Recording permission when prompted
6. Grant Accessibility permission when prompted
7. Grant Notification permission when prompted

**Expected After Granting:**
```
═══════════════════════════════════════
📊 PERMISSION STATUS SUMMARY
═══════════════════════════════════════
📱 Screen Recording: ✅ Authorized
♿️ Accessibility:     ✅ Authorized
🔔 Notifications:     ✅ Authorized
═══════════════════════════════════════

✅ [APP] All permissions granted
```

---

### 2. Permission Retry Logic

**Goal:** Verify retry mechanism and max retry alert

**Steps:**
1. Revoke Screen Recording permission:
   - System Preferences > Privacy & Security > Screen Recording
   - Uncheck ScreenSnap
2. Restart ScreenSnap
3. When prompted for Screen Recording, click "Deny" 3 times

**Expected Results:**
- After 1st denial: "🔄 [PERMISSIONS] Requesting Screen Recording (attempt 1/3)..."
- After 2nd denial: "🔄 [PERMISSIONS] Requesting Screen Recording (attempt 2/3)..."
- After 3rd denial: Alert appears:
  ```
  "📱 Screen Recording Permission Required

  ScreenSnap has reached the maximum number of permission requests.

  Please manually enable Screen Recording in:
  System Preferences > Privacy & Security > Screen Recording"

  [Open System Preferences] [OK]
  ```

4. Click "Open System Preferences" - should open System Preferences

---

### 3. Screenshot Capture - Basic Flow

**Goal:** Verify screenshot capture works end-to-end

**Steps:**
1. Ensure all permissions are granted
2. Click ScreenSnap menu bar icon (camera icon) - LEFT CLICK
3. Cursor should change to crosshair
4. Drag to select an area
5. Release mouse

**Expected Results:**

**Console:**
```
🎬 [SERVICE] Début de la capture avec screencapture natif...
✅ [SERVICE] screencapture lancé - sélectionnez une zone
✅ [SERVICE] Capture réussie: /tmp/ScreenSnap-1704652800.png
📋 [SERVICE] Chemin copié au clipboard: /tmp/ScreenSnap-1704652800.png
🔵 [SERVICE] Affichage de la pilule...
🟣 [PILL] Affichage de la pilule: Saved
✅ [PILL] Pilule affichée
🔔 [SERVICE] Envoi de la notification...
📢 [CUSTOM NOTIF] Showing: 📸 Screenshot Ready - Click to reveal in Finder
✅ [CUSTOM NOTIF] Notification displayed
```

**Visual:**
- ✅ Hear "Glass" sound
- ✅ See "✓ Saved" pill in menu bar (for 3 seconds)
- ✅ See custom notification in top-right corner

**Clipboard:**
```bash
pbpaste
# Should output: /tmp/ScreenSnap-XXXXXXXXXX.png
```

---

### 4. Screenshot Capture - Cancel

**Goal:** Verify cancel works without errors

**Steps:**
1. Click ScreenSnap menu bar icon
2. Press ESC key (before selecting area)

**Expected Results:**
```
❌ [SERVICE] Capture annulée (exit code: 1)
```
- No error messages
- No notification shown
- No sound played

---

### 5. Clipboard Integration with Zed

**Goal:** Verify clipboard works with Zed IDE

**Steps:**
1. Take a screenshot (see Test 3)
2. Verify clipboard contains file path:
   ```bash
   pbpaste
   # Output: /tmp/ScreenSnap-XXXXXXXXXX.png
   ```
3. Open Zed IDE
4. Press ⌘V to paste

**Expected Results:**
- Zed should accept the file path
- Image should be insertable/previewable in Zed

---

### 6. Custom Notification - Click to Open Finder

**Goal:** Verify notification click action works

**Steps:**
1. Take a screenshot
2. When custom notification appears in top-right corner
3. Click anywhere on the notification (or click the 📁 icon)

**Expected Results:**
```
🖱️ [CUSTOM NOTIF] Opening Finder: /tmp/ScreenSnap-XXXXXXXXXX.png
🗑️ [CUSTOM NOTIF] Notification dismissed
```
- Finder opens with screenshot file selected
- Notification disappears immediately

---

### 7. Custom Notification - Auto-Dismiss

**Goal:** Verify auto-dismiss works

**Steps:**
1. Take a screenshot
2. When custom notification appears, DO NOT click anything
3. Wait 4 seconds

**Expected Results:**
```
⏱️ [CUSTOM NOTIF] Auto-dismiss
🗑️ [CUSTOM NOTIF] Notification dismissed
```
- Notification fades out smoothly after 4 seconds

---

### 8. Custom Notification - Manual Dismiss

**Goal:** Verify X button works

**Steps:**
1. Take a screenshot
2. When custom notification appears, click the X button

**Expected Results:**
- Notification disappears immediately
- No errors in console

---

### 9. Dynamic Island Pill

**Goal:** Verify menu bar pill displays correctly

**Steps:**
1. Take a screenshot
2. Observe menu bar during and after capture

**Expected Results:**
```
🟣 [PILL] Affichage de la pilule: Saved
✅ [PILL] Pilule affichée
⏱️ [PILL] Auto-dismiss après 3.0s
🗑️ [PILL] Suppression de la pilule
```

**Visual:**
- Pill appears in menu bar with text "✓ Saved"
- Pill has smooth fade-in animation
- Pill displays for 3 seconds
- Pill has smooth fade-out animation
- Pill disappears completely

---

### 10. Sound Playback

**Goal:** Verify sound plays correctly (no double sound)

**Steps:**
1. Ensure sound is enabled in settings
2. Take a screenshot

**Expected Results:**
- Hear "Glass" sound ONCE (not twice)
- Sound plays immediately after capture completes

---

### 11. Global Hotkey

**Goal:** Verify keyboard shortcut works

**Steps:**
1. Press ⌥⌘S (Option + Command + S)

**Expected Results:**
```
Raccourci ⌥⌘S détecté!
🎬 [SERVICE] Début de la capture avec screencapture natif...
```
- Screenshot capture starts
- Same behavior as clicking menu bar icon

---

### 12. Right-Click Menu

**Goal:** Verify menu bar right-click works

**Steps:**
1. Right-click on ScreenSnap menu bar icon

**Expected Results:**
- Context menu appears with options:
  - 📸 Capturer une zone
  - 🪟 Capturer une fenêtre
  - ⚙️ Préférences...
  - Quitter

---

### 13. Multi-Screen Support

**Goal:** Verify capture works across screens

**Prerequisites:** External display connected

**Steps:**
1. Click ScreenSnap menu bar icon
2. Drag selection across screen boundary (from main to external)
3. Release mouse

**Expected Results:**
- Selection works across both screens
- Capture includes content from both screens
- No errors in console

---

### 14. Error Handling

**Goal:** Verify error notification works

**Steps:**
1. Revoke Screen Recording permission
2. Try to take screenshot

**Expected Results:**
```
❌ [SERVICE] Erreur lancement screencapture: ...
```
- Custom notification appears with error message
- User can click notification to see details

---

## Diagnostic Console Output Reference

### Successful Capture Flow:
```
🔐 [APP] Requesting all necessary permissions...
✅ [APP] All permissions granted
🎬 [SERVICE] Début de la capture avec screencapture natif...
✅ [SERVICE] screencapture lancé - sélectionnez une zone
✅ [SERVICE] Capture réussie: /tmp/ScreenSnap-1704652800.png
📋 [SERVICE] Chemin copié au clipboard: /tmp/ScreenSnap-1704652800.png
🔵 [SERVICE] Affichage de la pilule...
🟣 [PILL] Affichage de la pilule: Saved
✅ [PILL] Pilule affichée
🔔 [SERVICE] Envoi de la notification...
✅ [NOTIF] UNUserNotification sent (may not display for .accessory apps)
📢 [CUSTOM NOTIF] Showing: 📸 Screenshot Ready - Click to reveal in Finder
✅ [CUSTOM NOTIF] Notification displayed
⏱️ [PILL] Auto-dismiss après 3.0s
🗑️ [PILL] Suppression de la pilule
⏱️ [CUSTOM NOTIF] Auto-dismiss
🗑️ [CUSTOM NOTIF] Notification dismissed
```

### Permission Status at Startup:
```
═══════════════════════════════════════
📊 PERMISSION STATUS SUMMARY
═══════════════════════════════════════
📱 Screen Recording: ✅ Authorized
♿️ Accessibility:     ✅ Authorized
🔔 Notifications:     ✅ Authorized
═══════════════════════════════════════

═══════════════════════════════════════
🔔 NOTIFICATION DIAGNOSTICS
═══════════════════════════════════════
Authorization Status:  Authorized (2)
Alert Setting:         2
Badge Setting:         2
Sound Setting:         2
Notification Center:   2
Lock Screen:           2

🔍 ACTIVATION POLICY
Current Policy:        1
LSUIElement in Info:   YES

💡 KNOWN ISSUE
Apps with LSUIElement=true or .accessory policy
are filtered by macOS from showing UNUserNotifications.
This is a macOS design limitation, not an app bug.
═══════════════════════════════════════
```

---

## Troubleshooting

### Problem: No console output

**Solution:**
1. Open Console.app
2. Filter for "ScreenSnap"
3. Select "Action" > "Include Info Messages"
4. Select "Action" > "Include Debug Messages"

### Problem: Permissions not requested

**Solution:**
```bash
# Reset TCC permissions
tccutil reset ScreenCapture com.yourcompany.screensnap
tccutil reset Accessibility com.yourcompany.screensnap
tccutil reset UserNotifications com.yourcompany.screensnap

# Restart app
killall ScreenSnap
open /Users/ecologni/Library/Developer/Xcode/DerivedData/ScreenSnap-*/Build/Products/Debug/ScreenSnap.app
```

### Problem: Custom notification not appearing

**Check:**
1. Console logs - does it say "✅ [CUSTOM NOTIF] Notification displayed"?
2. Is notification hidden behind other windows?
3. Try closing all windows and test again

### Problem: Clipboard empty after capture

**Check:**
```bash
pbpaste  # Should show file path, not empty

# If empty, check console for:
# "📋 [SERVICE] Chemin copié au clipboard: /tmp/..."
```

### Problem: Sound not playing

**Check:**
1. System sound volume (not muted)
2. App settings - sound enabled?
3. Console for sound playback confirmation

---

## Performance Benchmarks

**Expected Performance:**
- Permission check: < 100ms
- Screenshot capture: 100-500ms (depends on area size)
- Clipboard copy: < 10ms
- Notification display: < 50ms
- Pill animation: < 300ms

**Memory Usage:**
- Base app: ~20-30 MB
- During capture: +5-10 MB (temporary)
- Custom notification: +2-3 MB (while displayed)

---

## Regression Testing

After any code changes, re-run:
- Test 1 (Permission Flow)
- Test 3 (Basic Capture)
- Test 6 (Notification Click)
- Test 9 (Dynamic Island)
- Test 11 (Global Hotkey)

These cover the core functionality paths.

---

## Next Steps After Testing

1. **If all tests pass:**
   - ✅ Phase 1 (P0) is complete
   - Ready to proceed to Phase 2 (P1) - ScreenCaptureKit migration

2. **If issues found:**
   - Document specific failure scenarios
   - Check console logs for error details
   - Report to development team with logs
