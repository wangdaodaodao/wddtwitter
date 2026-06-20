#!/usr/bin/env python3
import os
import re
import subprocess

packages_dir = 'packages'
control_file = 'control'

# Create packages directory if it doesn't exist
if not os.path.exists(packages_dir):
    os.makedirs(packages_dir)

# Count .deb files in packages
deb_files = [f for f in os.listdir(packages_dir) if f.endswith('.deb')]

max_suffix = -1
for f in deb_files:
    match = re.search(r'1\.0\.0-(\d+)', f)
    if match:
        val = int(match.group(1))
        if val > max_suffix:
            max_suffix = val

if max_suffix == -1:
    if len(deb_files) == 0:
        version = "1.0.0"
    else:
        version = f"1.0.0-{len(deb_files)}"
else:
    version = f"1.0.0-{max_suffix + 1}"

print(f"=== Detected {len(deb_files)} existing package(s). Next version: {version} ===")

# Read control file
with open(control_file, 'r') as f:
    control_content = f.read()

# Replace version in control
new_control_content = re.sub(r'^Version:\s*.*$', f"Version: {version}", control_content, flags=re.MULTILINE)

# Write modified control
with open(control_file, 'w') as f:
    f.write(new_control_content)

try:
    # Run theos build
    env = os.environ.copy()
    env["THEOS"] = "/Users/wangdaodao/theos"
    env["FINALPACKAGE"] = "1"
    subprocess.run(["make", "clean", "package"], env=env, check=True)
    print("=== Build succeeded! ===")
finally:
    # Restore original control file
    with open(control_file, 'w') as f:
        f.write(control_content)
    print("=== Restored original control file. ===")
