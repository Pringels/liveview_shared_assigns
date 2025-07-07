#!/bin/bash

echo "🚀 Starting SharedAssigns Demo"
echo "================================"

cd demo

echo "📦 Installing dependencies..."
mix deps.get

echo "🏗️  Compiling..."
mix compile

echo "🌟 Starting Phoenix server on http://localhost:4000"
echo "Press Ctrl+C to stop"

mix phx.server
