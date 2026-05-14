#!/bin/bash
# Generate images via GPT-5.5 API and save as PNG

API_URL="https://cpa.forgotdream.cn/4dream/v1/chat/completions"
API_KEY="sk-5Uwggxirv8oeqkqDLhCOL4AzVrS3VdR5xVTRaH3OEaq2v"
MODEL="gpt-5.5"
ASSETS_DIR="/tmp/fb520-redesign/assets"

generate_image() {
  local prompt="$1"
  local filename="$2"
  local attempt=1
  local max_attempts=2
  
  echo "=== Generating: $filename ==="
  echo "Prompt: ${prompt:0:60}..."
  
  while [ $attempt -le $max_attempts ]; do
    RESPONSE=$(curl -s -m 120 "$API_URL" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $API_KEY" \
      -d "{
        \"model\": \"$MODEL\",
        \"messages\": [{\"role\": \"user\", \"content\": \"$prompt\"}]
      }")
    
    # Check if response has image data
    IMAGE_URL=$(echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    url = data['choices'][0]['message']['images'][0]['image_url']['url']
    print(url)
except Exception as e:
    print(f'ERROR: {e}', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$IMAGE_URL" ]; then
      # Extract base64 data (remove data:image/png;base64, prefix if present)
      echo "$IMAGE_URL" | sed 's|^data:image/[^;]*;base64,||' | base64 -d > "$ASSETS_DIR/$filename"
      
      FILESIZE=$(stat -c%s "$ASSETS_DIR/$filename" 2>/dev/null || stat -f%z "$ASSETS_DIR/$filename" 2>/dev/null)
      if [ "$FILESIZE" -gt 1000 ]; then
        echo "✓ Saved $filename ($FILESIZE bytes)"
        return 0
      else
        echo "✗ File too small ($FILESIZE bytes), attempt $attempt"
      fi
    else
      echo "✗ API error on attempt $attempt"
      echo "$RESPONSE" | head -c 200
      echo ""
    fi
    
    attempt=$((attempt + 1))
    sleep 3
  done
  
  echo "✗ FAILED: $filename (skipping)"
  return 1
}

# Image 1: Q版菲比头像
generate_image "Design a cute chibi/Q-version mascot avatar for a bot called 'Phoebe'. The character should be a cute anime girl with flowing cyan and purple hair, glowing eyes, wearing a futuristic outfit inspired by Wuthering Waves game aesthetic. Circular avatar format, clean background, kawaii style, high quality icon suitable for website header. 64x64 to 128x128 feel." "phoebe-avatar.png"
sleep 2

# Image 2: 菲比立绘
generate_image "Full body anime character illustration of a cute female bot mascot named Phoebe for Wuthering Waves game community. She has flowing cyan-purple gradient hair, glowing teal eyes, wearing a sleek futuristic outfit with energy patterns. Dynamic pose, ethereal glow effects, dark background with subtle energy particles. High quality anime art style, vertical composition." "phoebe-fullbody.png"
sleep 2

# Image 3: 鸣潮角色合照
generate_image "Epic group illustration of Wuthering Waves game characters standing together in a dramatic pose. Include multiple characters with diverse designs - warriors, mages, and support characters. Dark fantasy sci-fi aesthetic with glowing cyan energy effects, dramatic lighting. Wide horizontal composition suitable for a website banner. High quality anime game art." "waves-group.png"
sleep 2

# Image 4: 原神角色合照
generate_image "Epic group illustration of Genshin Impact characters standing together. Include iconic characters like travelers and archons with elemental effects pyro hydro anemo electro. Bright fantasy world with floating islands in background. Wide horizontal composition for website banner. High quality anime game art style." "genshin-group.png"
sleep 2

# Image 5: 崩铁角色合照
generate_image "Epic group illustration of Honkai Star Rail characters together on the Astral Express. Include diverse characters with cosmic and stellar themes. Space train and galaxy background with dramatic lighting. Wide horizontal composition for website banner. High quality anime game art." "starrail-group.png"
sleep 2

# Image 6: 绝区零角色合照
generate_image "Epic group illustration of Zenless Zone Zero characters in an urban cyberpunk setting. Include multiple agents with diverse fighting styles. Neon-lit city streets with Hollows energy effects. Wide horizontal composition for website banner. High quality anime game art style." "zzz-group.png"

echo ""
echo "=== Done! ==="
ls -la "$ASSETS_DIR"/*.png 2>/dev/null
