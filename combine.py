#!/usr/bin/env python3
"""
📦 Flutter Project File Combiner
--------------------------------
- Combines selected project files into a single readable document
- Keeps folder structure visible
- Filters unnecessary / sensitive files
- Optimized for Flutter & general projects
"""

import os

# ========= CONFIG ========= #

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_FILE = os.path.join(BASE_DIR, "combined_flutter_project.txt")

# 🚫 Directories to ignore
EXCLUDED_DIRS = {
    "__pycache__",
    ".git",
    ".idea",
    ".vscode",
    "build",
    ".dart_tool",
    ".gradle",
    "node_modules",
    "ios/Pods",
    "android/.gradle",
    "android/build",
}

# ✅ Allowed file types (Flutter + general dev)
ALLOWED_EXTENSIONS = {
    ".dart",     # Flutter main code
    ".yaml",     # pubspec.yaml
    ".yml",
    ".json",
    ".arb",      # localization
    ".md",
    ".txt",
    ".env",
    ".ini",
    ".cfg",
    ".conf",
}

# ⛔ Block sensitive / useless files
BLOCKED_EXTENSIONS = {
    ".log",
    ".lock",
    ".keystore",
    ".jks",
    ".pyc",
    ".sqlite3",
}

# ⛔ Ignore specific filenames
IGNORED_FILES = {
    os.path.basename(OUTPUT_FILE),
    os.path.basename(__file__),
}

# ========= CORE LOGIC ========= #

def should_include(file_path: str) -> bool:
    """Determine if a file should be included."""

    filename = os.path.basename(file_path)

    # Skip excluded directories
    for excluded in EXCLUDED_DIRS:
        if excluded in file_path:
            return False

    # Skip ignored files
    if filename in IGNORED_FILES:
        return False

    # Skip blocked extensions
    if any(file_path.endswith(ext) for ext in BLOCKED_EXTENSIONS):
        return False

    # Allow based on extension
    ext = os.path.splitext(filename)[1]
    return ext in ALLOWED_EXTENSIONS


def write_file_block(out, rel_path, content):
    """Write a nicely formatted file section."""
    out.write("\n\n")
    out.write("═" * 100 + "\n")
    out.write(f"📄 FILE: {rel_path}\n")
    out.write("═" * 100 + "\n\n")
    out.write(content + "\n")


def combine_project_files():
    """Main function to combine files."""

    print("🔍 Scanning project...")

    with open(OUTPUT_FILE, "w", encoding="utf-8") as out:

        for root, dirs, files in os.walk(BASE_DIR):

            # Remove excluded directories early (performance boost)
            dirs[:] = [d for d in dirs if d not in EXCLUDED_DIRS]

            for file in sorted(files):
                file_path = os.path.join(root, file)

                if not should_include(file_path):
                    continue

                rel_path = os.path.relpath(file_path, BASE_DIR)

                try:
                    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                        content = f.read().rstrip()

                    write_file_block(out, rel_path, content)

                except Exception as e:
                    print(f"⚠️ Skipped {rel_path}: {e}")

    print("\n✅ Done!")
    print(f"📁 Output file: {OUTPUT_FILE}")


# ========= ENTRY POINT ========= #

if __name__ == "__main__":
    combine_project_files()