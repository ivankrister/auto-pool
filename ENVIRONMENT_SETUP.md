# AutoPool Environment Setup

This project uses environment variables to manage configuration securely. Follow these steps to set up your environment.

## Quick Setup

1. **Run the setup script:**
   ```bash
   ./setup.sh
   ```

2. **Edit the `.env` file** and update the values:
   ```bash
   nano .env
   ```

3. **Generate a secure JWT secret:**
   ```bash
   openssl rand -base64 32
   ```

4. **Start the services:**
   ```bash
   docker-compose up -d
   ```

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `ORYX_SERVER` | Your streaming server address | `10.104.0.3:80` |
| `VIDEO_JWT_SECRET` | JWT secret for token authentication | `generated-secure-key` |
| `SRS_M3U8_EXPIRE` | M3U8 playlist expiration (seconds) | `10` |
| `SRS_TS_EXPIRE` | TS segment expiration (seconds) | `3600` |

## Files

- `.env` - Your actual configuration (not committed to git)
- `.env.example` - Template file with example values
- `.gitignore` - Ensures `.env` is not committed

## Security Notes

⚠️ **Never commit the `.env` file to version control**

✅ **The `.env` file is automatically ignored by git**

🔑 **Generate strong JWT secrets for production**

## Manual Setup

If you prefer to set up manually:

1. Copy the example file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your values:
   ```bash
   # Environment variables for AutoPool
   ORYX_SERVER=your-streaming-server:port
   VIDEO_JWT_SECRET=your-secure-jwt-secret
   SRS_M3U8_EXPIRE=10
   SRS_TS_EXPIRE=3600
   ```

3. Start the services:
   ```bash
   docker-compose up -d
   ```