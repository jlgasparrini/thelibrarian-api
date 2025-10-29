# ⚡ Quick Deploy to Production (5 Minutes)

## 🚀 Fastest Way to Deploy (Render.com - FREE)

### 1. Push to GitHub
```bash
git add .
git commit -m "Ready for production"
git push origin main
```

### 2. Deploy to Render
1. Go to [render.com](https://render.com) and sign up with GitHub
2. Click **"New +"** → **"Blueprint"**
3. Select your `thelibrarian-api` repository
4. Render detects `render.yaml` automatically
5. Add environment variable:
   - `RAILS_MASTER_KEY` = (copy from `config/master.key`)
6. Click **"Apply"**
7. Wait 5-10 minutes ☕

### 3. Done! 🎉
Your API is live at: `https://thelibrarian-api.onrender.com`

Test it:
```bash
curl https://thelibrarian-api.onrender.com/api/v1/health
```

---

## 📝 What Gets Deployed Automatically

✅ **PostgreSQL Database** (free tier)
✅ **Rails API** (free tier)
✅ **Automatic SSL** (HTTPS)
✅ **Database migrations** (runs on deploy)
✅ **Seed data** (demo users & books)
✅ **CI/CD** (auto-deploy on git push)

---

## 🔐 Get Your Master Key

```bash
cat config/master.key
```

Copy this value - you'll need it for the `RAILS_MASTER_KEY` environment variable.

---

## 🎯 Alternative: One-Click Deploy

### Railway.app
[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template)

1. Click the button above
2. Connect GitHub
3. Add `RAILS_MASTER_KEY`
4. Deploy!

### Fly.io
```bash
# Install CLI
brew install flyctl  # or: curl -L https://fly.io/install.sh | sh

# Deploy
fly launch
fly secrets set RAILS_MASTER_KEY=$(cat config/master.key)
fly deploy
```

---

## 📊 After Deployment

### Test Your API
```bash
# Health check
curl https://your-app.onrender.com/api/v1/health

# Sign up
curl -X POST https://your-app.onrender.com/api/v1/auth/sign_up \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"test@example.com","password":"password","password_confirmation":"password"}}'

# Sign in (get JWT token)
curl -X POST https://your-app.onrender.com/api/v1/auth/sign_in \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"admin@library.com","password":"password"}}' \
  -i

# Get books (use token from sign in)
curl https://your-app.onrender.com/api/v1/books \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Demo Credentials
```
Librarian: admin@library.com / password
Member:    member@library.com / password
```

---

## 🔄 Continuous Deployment

Every time you push to main:
```bash
git push origin main
```

1. ✅ GitHub Actions runs tests
2. ✅ If tests pass, Render auto-deploys
3. ✅ Migrations run automatically
4. ✅ App restarts with new code

---

## 💰 Cost: $0/month

**Render Free Tier:**
- 750 hours/month (enough for 24/7)
- PostgreSQL database
- Automatic SSL
- Custom domains
- ⚠️ Sleeps after 15min inactivity (first request takes ~30s)

**To prevent sleep:** Upgrade to $7/month or use a ping service

---

## 🐛 Troubleshooting

### "Build failed"
- Check you added `RAILS_MASTER_KEY`
- View logs in Render dashboard

### "Database connection error"
- Wait for database to finish creating
- Check `DATABASE_URL` is linked

### "App is sleeping"
- First request after 15min takes ~30s
- This is normal on free tier
- Upgrade to $7/month to prevent sleep

---

## 📚 Full Documentation

For detailed deployment options and troubleshooting:
- See [DEPLOYMENT.md](./DEPLOYMENT.md)
- See [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)

---

**That's it! Your API is live! 🚀**
