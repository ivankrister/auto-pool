#!/bin/bash

# Setup script for AutoPool environment

echo "Setting up AutoPool environment..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
    echo "✅ .env file created successfully!"
    echo ""
    echo "⚠️  IMPORTANT: Please edit the .env file and set your actual values:"
    echo "   - ORYX_SERVER: Your streaming server address"
    echo "   - VIDEO_JWT_SECRET: A secure random secret key"
    echo ""
    echo "💡 To generate a secure JWT secret, you can use:"
    echo "   openssl rand -base64 32"
    echo ""
else
    echo "⚠️  .env file already exists. Skipping creation."
fi

echo "🚀 Setup complete! You can now run: docker-compose up -d"