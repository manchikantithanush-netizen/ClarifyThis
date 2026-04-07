# Security Guidelines for ClarifyThis

## 🔒 API Key Management

### Current Security Measures

1. **Environment Variables**: All API keys are loaded from environment variables or `.env` file
2. **Git Ignore**: Sensitive files are excluded from version control
3. **No Hardcoding**: API keys are NEVER hardcoded in source code
4. **Encryption**: User data is encrypted before storage using EncryptionManager

### Setup Instructions

#### For Development:

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Fill in your actual API keys in `.env`:
   ```
   OPENROUTER_API_KEY=sk-or-v1-your-actual-key-here
   GROQ_API_KEY=gsk_your-actual-key-here
   ```

3. **NEVER** commit `.env` to git - it's already in `.gitignore`

#### For Production/Distribution:

Use Xcode build configurations to inject environment variables:

1. In Xcode, go to your target → Build Settings
2. Add User-Defined Settings:
   - `OPENROUTER_API_KEY` = $(OPENROUTER_API_KEY)
   - `GROQ_API_KEY` = $(GROQ_API_KEY)

3. Set these in your CI/CD pipeline or Xcode Cloud environment

### Protected Files

The following files contain sensitive information and are excluded from git:

- `.env` - Environment variables
- `GoogleService-Info.plist` - Firebase configuration (already committed, needs manual removal)

## 🛡️ Firebase Security

### GoogleService-Info.plist

**IMPORTANT**: This file contains Firebase configuration including:
- Client ID
- API Key: `AIzaSyA-VJ-apgNKsn0Moltezigj2yXXHy9qYbc`
- Project details

### Recommended Actions:

1. **Regenerate Firebase Keys**: 
   - Go to Firebase Console → Project Settings → General
   - Download a new `GoogleService-Info.plist`
   - Restrict API key usage in Google Cloud Console

2. **Remove from Git History**:
   ```bash
   git filter-branch --force --index-filter \
     'git rm --cached --ignore-unmatch ClarifyThisv2/GoogleService-Info.plist' \
     --prune-empty --tag-name-filter cat -- --all
   ```

3. **Set Firebase Security Rules**:
   - Enable authentication requirements
   - Restrict database access to authenticated users only
   - Add rate limiting

## 🔐 Additional Security Measures

1. **Data Encryption**: All user chat history is encrypted before storing in Firestore
2. **User Authentication**: Firebase Authentication with Google Sign-In and email/password
3. **Secure Communication**: All API calls use HTTPS
4. **No Logging of Secrets**: Keys are never logged or printed in full

## ⚠️ If Keys Are Compromised

If you suspect API keys have been exposed:

1. **OpenRouter**: 
   - Go to https://openrouter.ai/settings/keys
   - Revoke the compromised key
   - Generate a new one

2. **Groq**:
   - Visit https://console.groq.com/keys
   - Delete the exposed key
   - Create a new API key

3. **Firebase**:
   - Firebase Console → Project Settings
   - Restrict API key in Google Cloud Console
   - Update Firebase security rules

## 📋 Security Checklist

- [x] API keys removed from source code
- [x] `.gitignore` configured for sensitive files
- [x] `.env.example` template created
- [x] ConfigManager updated to use environment variables
- [x] Data encryption implemented for user content
- [ ] Remove `GoogleService-Info.plist` from git history
- [ ] Regenerate exposed Firebase API key
- [ ] Regenerate exposed OpenRouter API key
- [ ] Regenerate exposed Groq API key
- [ ] Set up Firebase security rules
- [ ] Configure API key restrictions in Google Cloud Console

## 🔄 Regular Maintenance

- Rotate API keys quarterly
- Review Firebase security rules monthly
- Monitor API usage for anomalies
- Keep dependencies updated for security patches
