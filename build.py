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
count = len(deb_files)

# If no package exists, use 1.0.0. Otherwise, use 1.0.0-count
if count == 0:
    version = "1.0.0"
else:
    version = f"1.0.0-{count}"

print(f"=== Detected {count} existing package(s). Next version: {version} ===")

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
