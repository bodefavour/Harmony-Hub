# Supabase Migration Guide for Harmony Hub

## ✅ What's Been Done

### 1. Dependencies Updated
- ✅ Removed all Firebase packages
- ✅ Added `supabase_flutter: ^2.10.3`
- ✅ Kept Google Sign-In and Apple Sign-In packages (they work with Supabase OAuth)

### 2. New Files Created
- ✅ `lib/backend/supabase/supabase_config.dart` - Supabase initialization
- ✅ `lib/auth/supabase_auth/supabase_user_provider.dart` - User provider
- ✅ `lib/auth/supabase_auth/auth_util.dart` - Authentication utilities

### 3. Updated Files
- ✅ `lib/main.dart` - Now uses Supabase instead of Firebase

## 🔧 Setup Steps You Need to Complete

### Step 1: Create Your Supabase Project

1. Go to [https://supabase.com](https://supabase.com) and sign up/sign in
2. Click "New Project"
3. Fill in your project details:
   - Name: `harmony-hub`
   - Database Password: (create a strong password)
   - Region: Choose closest to your users
4. Wait for the project to be created (~2 minutes)

### Step 2: Get Your Supabase Credentials

1. In your Supabase project dashboard, go to **Settings** > **API**
2. Copy the following:
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon public key** (starts with `eyJ...`)

3. Update `lib/backend/supabase/supabase_config.dart`:
   ```dart
   const String supabaseUrl = 'YOUR_PROJECT_URL_HERE';
   const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
   ```

### Step 3: Set Up Authentication in Supabase

1. In Supabase dashboard, go to **Authentication** > **Providers**
2. Enable the providers you want to use:
   - ✅ Email (enabled by default)
   - ✅ Google OAuth (if using Google Sign-In)
   - ✅ Apple OAuth (if using Apple Sign-In)
   - ✅ Anonymous (if needed)

#### For Google OAuth:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create OAuth 2.0 credentials
3. Add your Supabase callback URL: `https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback`
4. Copy Client ID and Client Secret to Supabase

#### For Apple OAuth:
1. Go to [Apple Developer](https://developer.apple.com/account/resources/identifiers/list)
2. Create a Service ID
3. Configure Sign in with Apple
4. Add callback URL to Supabase settings

### Step 4: Set Up Database Schema

Create your database tables in Supabase:

```sql
-- Example: User profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  email TEXT,
  display_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own profile" 
  ON profiles FOR SELECT 
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
  ON profiles FOR UPDATE 
  USING (auth.uid() = id);

-- Create trigger to auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name, avatar_url)
  VALUES (
    new.id,
    new.email,
    new.raw_user_meta_data->>'display_name',
    new.raw_user_meta_data->>'avatar_url'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

### Step 5: Update Authentication Throughout Your App

You need to update all files that use Firebase auth. Here's a search and replace guide:

**Find and Replace:**
- `firebase_auth/auth_util` → `supabase_auth/auth_util`
- `firebase_auth/firebase_user_provider` → `supabase_auth/supabase_user_provider`
- `FirebaseAuth.instance` → `Supabase.instance.client.auth`
- `FirebaseAuthException` → `AuthException` (from Supabase)

**Files that need updating:**
- All components in `lib/components/` that use auth
- All pages in `lib/pages/` that use auth (login, signup, profile, etc.)

### Step 6: Configure Deep Links (for OAuth)

#### Android (`android/app/src/main/AndroidManifest.xml`):
```xml
<intent-filter android:label="supabase_auth">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="io.supabase.harmonyhub" />
</intent-filter>
```

#### iOS (`ios/Runner/Info.plist`):
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.harmonyhub</string>
    </array>
  </dict>
</array>
```

### Step 7: Remove Firebase Configuration Files

Delete these files:
- ❌ `android/app/google-services.json`
- ❌ `ios/Runner/GoogleService-Info.plist`
- ❌ `lib/backend/firebase/`
- ❌ `lib/backend/firebase_analytics/`
- ❌ `lib/auth/firebase_auth/` (entire directory)
- ❌ `firebase/` (root directory)

## 📝 API Changes Reference

### Authentication

| Firebase | Supabase |
|----------|----------|
| `FirebaseAuth.instance.signInWithEmailAndPassword()` | `authManager.signInWithEmail()` |
| `FirebaseAuth.instance.createUserWithEmailAndPassword()` | `authManager.signUpWithEmail()` |
| `FirebaseAuth.instance.signOut()` | `authManager.signOut()` |
| `FirebaseAuth.instance.sendPasswordResetEmail()` | `authManager.sendPasswordResetEmail()` |
| `currentUserUid` | `currentUserUid` (same!) |

### Real-time Data (if you use it later)

```dart
// Subscribe to changes
supabase
  .from('your_table')
  .stream(primaryKey: ['id'])
  .listen((data) {
    // Handle updates
  });
```

### Storage (for file uploads)

```dart
// Upload file
final response = await supabase.storage
  .from('bucket_name')
  .upload('path/to/file', file);

// Get public URL
final url = supabase.storage
  .from('bucket_name')
  .getPublicUrl('path/to/file');
```

## 🎯 Next Steps

1. ✅ Set up your Supabase project
2. ✅ Add your credentials to `supabase_config.dart`
3. ⏳ Update all auth references in your UI pages
4. ⏳ Test authentication flows (email, Google, Apple)
5. ⏳ Set up your database schema
6. ⏳ Implement any additional features you need

## 📚 Additional Resources

- [Supabase Docs](https://supabase.com/docs)
- [Supabase Flutter Docs](https://supabase.com/docs/reference/dart/introduction)
- [Authentication Guide](https://supabase.com/docs/guides/auth)
- [Database Guide](https://supabase.com/docs/guides/database)
- [Storage Guide](https://supabase.com/docs/guides/storage)

## 💡 Benefits of Supabase

- ✅ **Open Source**: No vendor lock-in
- ✅ **PostgreSQL**: Full SQL database with relations
- ✅ **Real-time**: Built-in real-time subscriptions
- ✅ **Row Level Security**: Database-level security
- ✅ **Self-hostable**: Can host your own instance
- ✅ **Lower Cost**: More generous free tier
- ✅ **Better Developer Experience**: Cleaner APIs

## 🆘 Need Help?

If you encounter issues:
1. Check the Supabase logs in your dashboard
2. Review the error messages carefully
3. Check the Supabase Discord community
4. Review the example code in the auth files created

Good luck with your migration! 🚀
