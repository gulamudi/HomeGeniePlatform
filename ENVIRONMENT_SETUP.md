# Environment Configuration Guide

This guide explains how to switch between **local** and **production** environments for both the HomeGenie and HomeGenie Partner apps.

## 🎯 Quick Start: How to Switch Environments

### Single Point of Change

To switch between environments, you only need to change **ONE LINE** in **ONE FILE**:

**File:** `shared/lib/config/app_config.dart`

**Line 23:** Change the `currentEnvironment` value:

```dart
// For LOCAL development (against local Supabase)
static const Environment currentEnvironment = Environment.local;

// For PRODUCTION (against cloud Supabase)
static const Environment currentEnvironment = Environment.production;
```

That's it! Both apps will automatically use the correct configuration.

---

## 📋 What Gets Configured

When you change the environment, the following values are automatically updated across both apps:

- **Supabase URL**: Local (`http://127.0.0.1:54321`) or Production cloud URL
- **Supabase Anon Key**: Local demo key or Production project key
- **Functions Base URL**: Edge functions endpoint

---

## 🛠️ Setting Up Production Environment

Before deploying to production, you need to add your production Supabase credentials.

### Step 1: Get Your Production Credentials

1. Go to your [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Go to **Settings** → **API**
4. Copy:
   - **Project URL** (e.g., `https://xxxxxxxxxxxxx.supabase.co`)
   - **anon/public key** (starts with `eyJhbGc...`)

### Step 2: Update the Configuration

Open `shared/lib/config/app_config.dart` and update the production configuration:

```dart
Environment.production: EnvironmentConfig(
  supabaseUrl: 'https://your-project.supabase.co',  // Replace with your Project URL
  supabaseAnonKey: 'your-production-anon-key-here',   // Replace with your anon key
  functionsBaseUrl: 'https://your-project.supabase.co/functions/v1',
),
```

### Step 3: Switch to Production

Change line 23 to:

```dart
static const Environment currentEnvironment = Environment.production;
```

---

## 🏗️ Building for App Store

### For HomeGenie Main App

```bash
cd homegenie_app

# 1. Ensure production environment is set in shared/lib/config/app_config.dart
# 2. Clean and get dependencies
flutter clean
flutter pub get

# 3. Build for iOS
flutter build ios --release

# 4. Build for Android
flutter build appbundle --release
```

### For HomeGenie Partner App

```bash
cd homegenie_partner_app

# 1. Ensure production environment is set in shared/lib/config/app_config.dart
# 2. Clean and get dependencies
flutter clean
flutter pub get

# 3. Build for iOS
flutter build ios --release

# 4. Build for Android
flutter build appbundle --release
```

---

## 🔍 Verification Checklist

Before deploying to production:

- [ ] Production Supabase credentials are correctly set in `shared/lib/config/app_config.dart`
- [ ] `currentEnvironment` is set to `Environment.production`
- [ ] Both apps build successfully without errors
- [ ] Test the built apps to ensure they connect to production Supabase
- [ ] All edge functions are deployed to production Supabase
- [ ] Database migrations are applied to production
- [ ] RLS (Row Level Security) policies are properly configured

---

## 🔄 Switching Back to Local Development

To switch back to local development:

1. Open `shared/lib/config/app_config.dart`
2. Change line 23 to:
   ```dart
   static const Environment currentEnvironment = Environment.local;
   ```
3. Ensure local Supabase is running:
   ```bash
   supabase start
   ```

---

## 🗂️ Configuration Files Reference

### Files Modified for Environment Support

1. **`shared/lib/config/app_config.dart`**
   - Main configuration file
   - Defines environment enum and configurations
   - **THIS IS WHERE YOU SWITCH ENVIRONMENTS**

2. **`homegenie_app/lib/core/constants/app_constants.dart`**
   - Now dynamically reads from `AppConfig`
   - No hardcoded URLs

3. **`homegenie_app/lib/core/network/api_service.dart`**
   - Removed hardcoded baseUrl from annotation
   - Receives baseUrl dynamically

4. **`homegenie_app/lib/core/providers/api_provider.dart`**
   - Passes baseUrl from `AppConstants` to `ApiService`

5. **`homegenie_partner_app/lib/core/network/api_client.dart`**
   - Uses `AppConfig.functionsBaseUrl` as default
   - No hardcoded URLs

---

## 🐛 Troubleshooting

### "Cannot connect to Supabase" in Local Mode

**Solution:**
```bash
cd /Users/muditgulati/devel/HomeGenieApps
supabase start
```

### "Authentication failed" in Production Mode

**Solution:**
- Verify your production anon key is correct
- Check if your Supabase project is active
- Ensure RLS policies allow your operations

### Apps Still Using Old URL After Switch

**Solution:**
```bash
# Clean and rebuild
cd homegenie_app  # or homegenie_partner_app
flutter clean
flutter pub get
flutter run
```

### API Service Generation Errors

**Solution:**
```bash
cd homegenie_app
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📝 Notes

- **Shared Configuration**: Both apps use the same environment configuration from the `shared` package
- **Runtime Configuration**: The environment is determined at compile time, so you need to rebuild the app after changing the environment
- **No `.env` Files**: We're using Dart constants instead of environment files for simplicity and type safety
- **Security**: Never commit production keys to version control in a public repository

---

## ✅ Summary

### To Deploy to App Store:

1. ✏️ Edit `shared/lib/config/app_config.dart`
2. 🔑 Add production Supabase credentials (lines 34-37)
3. 🔄 Change `currentEnvironment` to `Environment.production` (line 23)
4. 🏗️ Build apps with `flutter build ios --release` or `flutter build appbundle --release`
5. 📤 Upload to App Store Connect / Google Play Console

### To Return to Local Development:

1. ✏️ Edit `shared/lib/config/app_config.dart`
2. 🔄 Change `currentEnvironment` to `Environment.local` (line 23)
3. ▶️ Run `supabase start` in project directory
4. 🚀 Run apps with `flutter run`

---

**Last Updated:** October 2025
