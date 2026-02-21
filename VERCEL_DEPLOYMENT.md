# Deploy Flutter App to Vercel

This Flutter app is configured to deploy on Vercel. Follow these steps:

## Prerequisites
- A Vercel account (sign up at https://vercel.com)
- Git repository (GitHub, GitLab, or Bitbucket)

## Deployment Steps

### Option 1: Deploy via Vercel CLI (Recommended)

1. Install Vercel CLI globally:
```bash
npm install -g vercel
```

2. Login to Vercel:
```bash
vercel login
```

3. Deploy from the project root:
```bash
vercel
```

4. Follow the prompts:
   - Set up and deploy? Yes
   - Which scope? (Select your account)
   - Link to existing project? No
   - What's your project's name? (Use default or enter a name)
   - In which directory is your code located? ./
   - Want to modify the settings? No

5. Vercel will build and deploy your app. You'll get a deployment URL.

### Option 2: Deploy via Vercel Dashboard

1. Push your code to a Git repository (GitHub, GitLab, or Bitbucket)

2. Go to https://vercel.com/new

3. Import your Git repository

4. Configure the project:
   - **Framework Preset**: Other
   - **Build Command**: `flutter build web --release`
   - **Output Directory**: `build/web`
   - **Install Command**: (Leave as auto-detected)

5. Click "Deploy"

## Important Configuration Files

- **vercel.json**: Contains build configuration and routing rules for client-side navigation
- **.vercelignore**: Excludes unnecessary files from deployment
- **web/index.html**: Updated with proper base href for production

## Environment Variables

If your app uses environment variables (API keys, etc.), add them in:
- Vercel Dashboard → Your Project → Settings → Environment Variables

Or via CLI:
```bash
vercel env add API_KEY
```

## Custom Domain (Optional)

To add a custom domain:
1. Go to your project in Vercel Dashboard
2. Navigate to Settings → Domains
3. Add your domain and follow DNS configuration instructions

## Troubleshooting

### Build Fails
- Ensure Flutter is properly installed in the build environment
- Check the Build Logs in Vercel Dashboard
- Verify all dependencies in pubspec.yaml are compatible with web

### Routing Issues
- The `vercel.json` contains SPA routing configuration
- All routes redirect to `/` to support client-side routing with GoRouter

### Performance
- The app is built with `--release` flag for optimization
- Icons are tree-shaken automatically
- Consider using `--wasm` flag for better performance (experimental)

## Local Testing

Test the production build locally:
```bash
flutter build web --release
cd build/web
python -m http.server 8000
```

Then visit http://localhost:8000

## Updates

To update your deployed app:
```bash
git add .
git commit -m "Your update message"
git push
```

Vercel will automatically rebuild and redeploy on git push if you used Option 2.

For CLI deployments (Option 1), run:
```bash
vercel --prod
```
