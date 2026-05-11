import re
import os

path = '/Users/rajesh/Documents/PresshopComplete/presshop-flutter-app-3.0-new-app/lib/features/publish/presentation/pages/publish_content_screen.dart'
if not os.path.exists(path):
    print(f"File not found: {path}")
    exit(1)

with open(path, 'r') as f:
    content = f.read()

assets = ['doc_black_icon.png', 'pngImage.png', 'watermark1.png', 'docIcon.png', 'pdfIcon.png']

for asset in assets:
    # Match Image.asset call that contains the asset name, followed by any lines until fit: BoxFit.cover
    # The [^;]* ensures we stay within the same statement
    pattern = r'(Image\.asset\(\s*"[^"]*' + re.escape(asset) + r'"[^;]*?fit: )BoxFit\.cover,'
    content = re.sub(pattern, r'\1BoxFit.contain,', content, flags=re.DOTALL)

with open(path, 'w') as f:
    f.write(content)
print("Successfully updated BoxFit settings.")
