"""
End-to-end test: start server, send test image, check response.
"""
import sys
import io
import time
import base64
import threading
import urllib.request
import urllib.parse

sys.path.insert(0, '.')

# Start server in background thread
import uvicorn
from app.main import app

server = uvicorn.Server(uvicorn.Config(app, host='127.0.0.1', port=18765, log_level='warning'))

t = threading.Thread(target=server.run, daemon=True)
t.start()
time.sleep(3)

print('[TEST] Server started')

# Create a small test JPEG image
from PIL import Image
img = Image.new('RGB', (200, 200), color=(200, 150, 100))
buf = io.BytesIO()
img.save(buf, format='JPEG')
img_bytes = buf.getvalue()
print(f'[TEST] Test image: {len(img_bytes)} bytes')

# Multipart POST
import http.client
boundary = 'testboundary123'
body = (
    f'--{boundary}\r\n'
    f'Content-Disposition: form-data; name="file"; filename="test.jpg"\r\n'
    f'Content-Type: image/jpeg\r\n\r\n'
).encode() + img_bytes + f'\r\n--{boundary}--\r\n'.encode()

conn = http.client.HTTPConnection('127.0.0.1', 18765, timeout=120)
try:
    conn.request(
        'POST',
        '/api/ai/enhance-image',
        body,
        {'Content-Type': f'multipart/form-data; boundary={boundary}', 'Content-Length': str(len(body))}
    )
    resp = conn.getresponse()
    print(f'[TEST] Response status: {resp.status}')
    data = resp.read()
    print(f'[TEST] Response bytes: {len(data)}')
    if resp.status == 200:
        import json
        j = json.loads(data)
        print(f'[TEST] success: {j.get("success")}')
        print(f'[TEST] steps: {j.get("processing_steps")}')
        enhanced = j.get('enhanced_image', '')
        print(f'[TEST] enhanced_image length: {len(enhanced)}')
        print('[TEST] PASSED')
    else:
        print(f'[TEST] FAILED: {data[:500]}')
except Exception as e:
    print(f'[TEST] EXCEPTION: {e}')
    import traceback
    traceback.print_exc()
finally:
    conn.close()
    server.should_exit = True

print('[TEST] Done')
