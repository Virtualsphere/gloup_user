import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Regex 1: const EdgeInsets.all(AppSizes...
    new_content = re.sub(r'const\s+(EdgeInsets\.[a-zA-Z]+\s*\([^)]*AppSizes[^)]*\))', r'\1', content)
    
    # Regex 2: const SizedBox(height: AppSizes...
    new_content = re.sub(r'const\s+(SizedBox\s*\([^)]*AppSizes[^)]*\))', r'\1', new_content)

    # Regex 3: const SizedBox.shrink() should NOT be matched unless it has AppSizes
    # Regex 4: Remove const before AppSizes directly (if any)
    new_content = re.sub(r'const\s+(AppSizes\.[a-zA-Z0-9_]+)', r'\1', new_content)

    # Regex 5: const EdgeInsets... if it spans multiple lines, we can use DOTALL or just handle common cases.
    # A simpler approach: if a line has 'const ' and 'AppSizes', we might need to remove const. 
    # But this might be too aggressive. The above covers 95% of cases.

    # Regex 6: const Padding(padding: AppSizes...
    new_content = re.sub(r'const\s+(Padding\s*\(\s*padding:\s*AppSizes)', r'\1', new_content)

    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
