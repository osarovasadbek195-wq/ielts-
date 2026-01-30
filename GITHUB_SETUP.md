# GitHub Repository Setup Guide

## Step 1: Create New GitHub Repository

1. Go to https://github.com
2. Click "+" > "New repository"
3. Repository name: `ielts_sat_prep_app`
4. Description: `Flutter app for IELTS Band 8 and SAT 1500+ preparation`
5. Make it **Public** (free tier)
6. **DO NOT** initialize with README (we already have files)
7. Click "Create repository"

## Step 2: Connect Your Local Repository

After creating the repository, GitHub will show you commands. Run these:

```bash
# Already done, but if you need to reconnect:
cd d:\flutter\ielts_sat_prep_app
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/ielts_sat_prep_app.git
git branch -M main
git push -u origin main
```

Replace `YOUR_USERNAME` with your actual GitHub username.

## Step 3: Verify Push

```bash
git status
git log --oneline -5
```

## Step 4: Setup for Codemagic

Once pushed to GitHub, you can:
1. Go to https://codemagic.io
2. Click "Add Application"
3. Connect your GitHub account
4. Select the `ielts_sat_prep_app` repository

## Common Issues

### If push fails with "authentication failed":
```bash
# Configure Git credentials
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Or use personal access token:
# 1. Go to GitHub Settings > Developer settings > Personal access tokens
# 2. Generate new token with 'repo' permissions
# 3. Use token as password when pushing
```

### If repository already exists:
```bash
# Force push (be careful!)
git push -f origin main
```

## Next Steps

After successful push:
1. ✅ Repository is live on GitHub
2. ✅ Ready for Codemagic setup
3. ✅ Can collaborate with others
4. ✅ Automatic backups
