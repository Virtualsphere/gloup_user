import codecs
import re

# Read utf-16le
try:
    with codecs.open('analyze_output.txt', 'r', 'utf-16le') as f:
        lines = f.readlines()
except:
    with open('analyze_output.txt', 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()

errors = []
for line in lines:
    if ' - lib\\' in line and '.dart:' in line:
        # e.g.: error - Invalid constant value - lib\file.dart:372:57 - invalid_constant
        # Or: error - ... - lib\file.dart:181:38 - const_with_non_constant_argument
        parts = line.strip().split(' - ')
        for part in parts:
            if part.startswith('lib\\') or part.startswith('lib/'):
                file_info = part.split(':')
                if len(file_info) >= 3:
                    file_path = file_info[0]
                    line_num = int(file_info[1])
                    errors.append((file_path, line_num))
                break

# Group by file
from collections import defaultdict
file_errors = defaultdict(list)
for path, l in errors:
    file_errors[path].append(l)

for file_path, lines_with_errors in file_errors.items():
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            file_lines = f.readlines()
            
        modified = False
        for line_num in set(lines_with_errors):
            idx = line_num - 1
            if idx < len(file_lines):
                original = file_lines[idx]
                # Look for 'const ' and replace with ''
                # We also might need to check the previous line if 'const' was on the previous line
                # e.g. 
                # const
                # Padding(...)
                
                # Replace all 'const ' with '' on the error line
                if 'const ' in original:
                    file_lines[idx] = re.sub(r'\bconst\s+', '', original)
                    modified = True
                else:
                    # Sometimes the const is on the line above
                    if idx > 0 and 'const ' in file_lines[idx-1]:
                        file_lines[idx-1] = re.sub(r'\bconst\s+', '', file_lines[idx-1])
                        modified = True
        
        if modified:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(file_lines)
            print(f"Fixed {file_path}")
    except Exception as e:
        print(f"Failed to fix {file_path}: {e}")
