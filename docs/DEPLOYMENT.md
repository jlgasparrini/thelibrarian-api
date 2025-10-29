# 🚀 Deployment Guide

## Free Production Deployment with Render.com

This guide will help you deploy The Librarian API to production for **FREE** using Render.com with automated CI/CD.

---

## 📋 Prerequisites

1. GitHub account (for CI/CD)
2. Render.com account (free tier)
3. Your code pushed to GitHub

---

## 🎯 Option 1: Deploy to Render.com (Recommended - FREE)

### Step 1: Create Render Account
1. Go to [render.com](https://render.com)
2. Sign up with your GitHub account
3. Authorize Render to access your repositories

### Step 2: Deploy from Dashboard

#### Method A: Using render.yaml (Automated)
1. Click **"New +"** → **"Blueprint"**
2. Connect your GitHub repository
3. Render will automatically detect `render.yaml`
4. Click **"Apply"**
5. Wait for deployment (5-10 minutes)

#### Method B: Manual Setup
1. **Create PostgreSQL Database:**
   - Click **"New +"** → **"PostgreSQL"**
   - Name: `thelibrarian-db`
   - Plan: **Free**
   - Click **"Create Database"**

2. **Create Web Service:**
   - Click **"New +"** → **"Web Service"**
   - Connect your GitHub repository
   - Name: `thelibrarian-api`
   - Runtime: **Ruby**
   - Build Command: `./bin/render-build.sh`
   - Start Command: `bundle exec puma -C config/puma.rb`
   - Plan: **Free**

3. **Add Environment Variables:**
   ```
   RAILS_ENV=production
   RAILS_LOG_TO_STDOUT=enabled
   RAILS_SERVE_STATIC_FILES=enabled
   DATABASE_URL=[Link to your PostgreSQL database]
   RAILS_MASTER_KEY=[Your master key from config/master.key]
   ```

4. Click **"Create Web Service"**

### Step 3: Get Your Master Key

```bash
# On your local machine
cat config/master.key
```

Copy this value and add it as `RAILS_MASTER_KEY` environment variable in Render.

### Step 4: Verify Deployment

Once deployed, your API will be available at:
```
https://thelibrarian-api.onrender.com/api/v1/health
```

Test it:
```bash
curl https://thelibrarian-api.onrender.com/api/v1/health
```

---

## 🔄 Continuous Deployment

### Automatic Deployments
Render automatically deploys when you push to your main branch:

```bash
git add .
git commit -m "Update feature"
git push origin main
```

Render will:
1. ✅ Run CI tests via GitHub Actions
2. ✅ Build the application
3. ✅ Run migrations
4. ✅ Deploy to production

### Manual Deployment
You can also trigger manual deployments from the Render dashboard:
1. Go to your service
2. Click **"Manual Deploy"** → **"Deploy latest commit"**

---

## 🎯 Option 2: Deploy to Railway.app (Alternative - FREE)

### Step 1: Create Railway Account
1. Go to [railway.app](https://railway.app)
2. Sign up with GitHub
3. Click **"New Project"**

### Step 2: Deploy
1. Click **"Deploy from GitHub repo"**
2. Select your repository
3. Railway auto-detects Rails
4. Add PostgreSQL:
   - Click **"+ New"** → **"Database"** → **"Add PostgreSQL"**
5. Add environment variables:
   ```
   RAILS_MASTER_KEY=[Your master key]
   ```
6. Click **"Deploy"**

---

## 🎯 Option 3: Deploy to Fly.io (Alternative - FREE)

### Step 1: Install Fly CLI
```bash
# macOS
brew install flyctl

# Linux
curl -L https://fly.io/install.sh | sh

# Windows
powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"
```

### Step 2: Login and Launch
```bash
fly auth login
fly launch
```

Follow the prompts:
- App name: `thelibrarian-api`
- Region: Choose closest to you
- PostgreSQL: Yes
- Deploy now: Yes

### Step 3: Set Secrets
```bash
fly secrets set RAILS_MASTER_KEY=$(cat config/master.key)
```

### Step 4: Deploy
```bash
fly deploy
```

---

## 🔐 Security Checklist

Before deploying to production:

- [x] ✅ Set `RAILS_MASTER_KEY` environment variable
- [x] ✅ Use production database (PostgreSQL)
- [x] ✅ Enable HTTPS (automatic on Render/Railway/Fly)
- [ ] ⚠️ Update CORS settings in `config/initializers/cors.rb`
- [ ] ⚠️ Set allowed hosts in production
- [ ] ⚠️ Configure rate limiting (optional)

### Update CORS for Production

Edit `config/initializers/cors.rb`:
```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("CORS_ORIGINS", "http://localhost:3001").split(",")
    
    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
```

Then set environment variable:
```
CORS_ORIGINS=https://your-frontend.com,https://www.your-frontend.com
```

---

## 📊 Monitoring & Logs

### View Logs (Render)
```bash
# Install Render CLI
npm install -g render-cli

# View logs
render logs -s thelibrarian-api
```

Or view in dashboard: **Service** → **Logs**

### View Logs (Railway)
```bash
railway logs
```

### View Logs (Fly)
```bash
fly logs
```

---

## 🔄 Database Management

### Run Migrations
```bash
# Render
render run rails db:migrate -s thelibrarian-api

# Railway
railway run rails db:migrate

# Fly
fly ssh console -C "rails db:migrate"
```

### Access Rails Console
```bash
# Render
render run rails console -s thelibrarian-api

# Railway
railway run rails console

# Fly
fly ssh console -C "rails console"
```

### Reset Database (⚠️ Destructive)
```bash
# Render
render run rails db:reset -s thelibrarian-api

# Railway
railway run rails db:reset

# Fly
fly ssh console -C "rails db:reset"
```

---

## 🎉 Post-Deployment

### Test Your API

1. **Health Check:**
```bash
curl https://your-app.onrender.com/api/v1/health
```

2. **Sign Up:**
```bash
curl -X POST https://your-app.onrender.com/api/v1/auth/sign_up \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password",
      "password_confirmation": "password"
    }
  }'
```

3. **Get Books:**
```bash
curl https://your-app.onrender.com/api/v1/books \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Update Frontend

Update your frontend to point to the production API:
```javascript
// .env.production
VITE_API_URL=https://your-app.onrender.com/api/v1
// or
NEXT_PUBLIC_API_URL=https://your-app.onrender.com/api/v1
```

---

## 💰 Cost Breakdown

### Free Tier Limits

**Render.com (Free):**
- ✅ 750 hours/month web service
- ✅ PostgreSQL database (90 days, then expires)
- ✅ Automatic SSL
- ✅ Custom domains
- ⚠️ Sleeps after 15 min inactivity
- ⚠️ 512 MB RAM

**Railway.app (Free):**
- ✅ $5 credit/month
- ✅ PostgreSQL included
- ✅ Automatic SSL
- ⚠️ No sleep, but limited hours

**Fly.io (Free):**
- ✅ 3 shared-cpu VMs
- ✅ 3GB persistent storage
- ✅ 160GB outbound data
- ✅ Automatic SSL
- ✅ No sleep

### Upgrade Options

If you need more:
- **Render:** $7/month (no sleep, more RAM)
- **Railway:** Pay as you go (~$5-10/month)
- **Fly:** $1.94/month per VM

---

## 🐛 Troubleshooting

### Build Fails
```bash
# Check logs
render logs -s thelibrarian-api

# Common issues:
# 1. Missing RAILS_MASTER_KEY
# 2. Database connection error
# 3. Missing dependencies
```

### Database Connection Error
- Verify `DATABASE_URL` is set correctly
- Check database is running
- Verify credentials

### App Sleeps (Render Free Tier)
- First request after sleep takes ~30 seconds
- Consider upgrading or using a ping service
- Or use Railway/Fly which don't sleep

### CORS Errors
- Update `config/initializers/cors.rb`
- Set `CORS_ORIGINS` environment variable
- Restart the service

---

## 📚 Additional Resources

- [Render Rails Guide](https://render.com/docs/deploy-rails)
- [Railway Rails Guide](https://docs.railway.app/guides/rails)
- [Fly.io Rails Guide](https://fly.io/docs/rails/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

---

## ✅ Deployment Checklist

- [ ] Code pushed to GitHub
- [ ] CI tests passing
- [ ] Render/Railway/Fly account created
- [ ] Database created
- [ ] Environment variables set
- [ ] `RAILS_MASTER_KEY` configured
- [ ] CORS configured for frontend
- [ ] First deployment successful
- [ ] Seed data loaded
- [ ] API tested with curl/Postman
- [ ] Frontend connected
- [ ] Monitoring set up

---

**🎉 Congratulations! Your API is now live in production!**
