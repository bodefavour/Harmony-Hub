# 🔧 Quick Fixes Needed

## Issues Found & Solutions

### 1. AppTheme Text Styles Issue
**Problem**: Text styles like `AppTheme.caption` are functions, not properties

**Fix**: In `lib/theme/app_theme.dart`, change:
```dart
// FROM:
static TextStyle caption() => GoogleFonts.inter(fontSize: 11);

// TO:
static TextStyle get caption => GoogleFonts.inter(fontSize: 11);
```

Apply this to ALL text style methods:
- `displayLarge` → `get displayLarge`
- `displayMedium` → `get displayMedium`
- `headlineLarge` → `get headlineLarge`
- `headlineMedium` → `get headlineMedium`
- `bodyLarge` → `get bodyLarge`
- `bodyMedium` → `get bodyMedium`
- `bodySmall` → `get bodySmall`
- `caption` → `get caption`

---

### 2. AppTheme Shadow Issues
**Problem**: Shadow properties are Lists, but being added to Lists (double wrapping)

**Fix**: In `lib/theme/app_theme.dart`, change:
```dart
// FROM:
static List<BoxShadow> cardShadow = [...];

// TO:
static BoxShadow cardShadow = BoxShadow(...);
```

Apply to all shadows:
- `cardShadow`
- `elevatedShadow`
- `glowShadow`

Then update usages from `[AppTheme.cardShadow]` to just `AppTheme.cardShadow`

**OR** keep as List and use:
```dart
boxShadow: AppTheme.cardShadow, // instead of [AppTheme.cardShadow]
```

---

### 3. Auth Manager Import Issue
**Problem**: `authManager` not imported in some files

**Fix**: Add this import to files that need it:
```dart
import '/auth/auth_manager.dart';
```

Files needing this:
- `lib/pages/user_profile/user_profile_widget_new.dart`

---

### 4. Auth Manager API Changes
**Problem**: signInWithEmail() method signature mismatch

**Fix**: Check your auth_manager.dart for the correct method signature.

In `lib/pages/login/login_widget_new.dart` and `signup_widget_new.dart`:

**Option A** - If method uses named parameters:
```dart
final user = await authManager.signInWithEmail(
  email: _emailController.text.trim(),
  password: _passwordController.text,
  context: context,
);
```

**Option B** - If method signature is different, check existing working login code for the right pattern.

---

### 5. HomePage Supabase Issues  
**Problem**: Missing Supabase table definitions

**Fix**: For now, comment out the database queries in `home_page_widget_new.dart` or use mock data.

Replace the FutureBuilder sections with:
```dart
// Mock data for now
final mockSongs = List.generate(10, (i) => {
  'id': i,
  'title': 'Song $i',
  'artist': 'Artist Name',
  'cover_url': null,
});
```

Later, update to use your actual Supabase schema.

---

## Quick Fix Commands

Run these to fix the most critical issues:

### 1. Fix AppTheme (MOST IMPORTANT)
Open `lib/theme/app_theme.dart` and run find/replace:
- Find: `static TextStyle displayLarge()`
- Replace: `static TextStyle get displayLarge`

Repeat for all text styles.

### 2. Test Compilation
```bash
flutter pub get
flutter analyze
```

### 3. Test on Device
```bash
flutter run
```

---

## Priority Order

1. ✅ **Fix AppTheme text styles** (CRITICAL - affects all new pages)
2. ✅ **Fix AppTheme shadows** (affects visual quality)
3. ⚠️ **Fix auth imports** (only affects profile page)
4. ⚠️ **Fix auth API calls** (only affects login/signup)
5. ℹ️ **HomePage database** (can use mock data for now)

---

## Estimated Fix Time: 10-15 minutes

Most issues are simple find/replace operations!
