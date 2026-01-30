# Codemagic Environment Variables Setup

## Required Environment Variables

### For Android Builds:
1. **CM_KEYSTORE**
   - Type: Text
   - Value: Base64 encoded keystore file
   - Group: keystore

2. **CM_KEYSTORE_PASSWORD**
   - Type: Text
   - Value: Your keystore password
   - Group: keystore

3. **CM_KEY_ALIAS**
   - Type: Text
   - Value: Your key alias (usually "upload")
   - Group: keystore

4. **CM_KEY_PASSWORD**
   - Type: Text
   - Value: Your key password
   - Group: keystore

### For iOS Builds (Optional):
1. **CM_CERTIFICATE**
   - Type: Text
   - Value: Base64 encoded certificate
   - Group: ios

2. **CM_CERTIFICATE_PASSWORD**
   - Type: Text
   - Value: Certificate password
   - Group: ios

3. **CM_PROVISIONING_PROFILE**
   - Type: Text
   - Value: Base64 encoded provisioning profile
   - Group: ios

### For Publishing:
1. **GCLOUD_SERVICE_ACCOUNT_CREDENTIALS**
   - Type: Text
   - Value: Google Play service account JSON
   - Group: google_play

2. **APP_ID**
   - Type: Text
   - Value: Apple App ID (for iOS)
   - Group: app_store

3. **FIREBASE_PROJECT_ID**
   - Type: Text
   - Value: Firebase project ID
   - Group: firebase

4. **FIREBASE_SERVICE_ACCOUNT_CREDENTIALS**
   - Type: Text
   - Value: Firebase service account JSON
   - Group: firebase

### For Notifications:
1. **SLACK_WEBHOOK_URL**
   - Type: Text
   - Value: Slack webhook URL for build notifications
   - Group: notifications

## How to Generate Keystore (Android)

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then encode it:
```bash
base64 -i ~/upload-keystore.jks | pbcopy
```

## Setup Steps in Codemagic:

1. Go to your application in Codemagic
2. Click "Settings" tab
3. Scroll down to "Environment variables"
4. Click "Add variable" for each variable above
5. Select appropriate group for organization
6. Click "Add" after each variable

## Build Configuration

The `codemagic.yaml` file is already configured to:
- ✅ Build Android APK and AAB
- ✅ Run tests
- ✅ Cache dependencies for faster builds
- ✅ Send notifications on build completion
- ✅ Deploy to Google Play Store (if configured)
- ✅ Deploy to App Store (if configured)

## First Build

1. After setting up environment variables, click "Build" in Codemagic
2. Select your branch (main)
3. Click "Start new build"
4. Monitor the build progress
5. Download artifacts when complete

## Troubleshooting

### Build fails with "keystore not found":
- Check CM_KEYSTORE variable is set correctly
- Ensure keystore is properly base64 encoded

### Build fails with permission error:
- Check all keystore variables are correct
- Verify keystore password and alias

### Tests fail:
- Run `flutter test` locally first
- Check test dependencies

### Need help?
- Check Codemagic logs
- Review build artifacts
- Contact support
