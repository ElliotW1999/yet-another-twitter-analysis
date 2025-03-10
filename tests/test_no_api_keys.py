import os
import re

# Define regex patterns for common API keys and secrets
API_KEY_PATTERNS = [
    r"(?i)API_KEY\s*=\s*[\'\"][A-Za-z0-9_\-]{20,}[\'\"]",  # API_KEY = "sk_123..."
    r"(?i)SECRET_KEY\s*=\s*[\'\"][A-Za-z0-9_\-]{20,}[\'\"]",  # SECRET_KEY = "abcd1234..."
    r"(?i)BEARER_TOKEN\s*=\s*[\'\"][A-Za-z0-9_\-]{20,}[\'\"]",  # BEARER_TOKEN = "abc123..."
    r"(?i)(AWS|GCP|AZURE)_.*_KEY\s*=\s*[\'\"][A-Za-z0-9_\-]{20,}[\'\"]",  # Cloud API Keys
]

# Directories to scan (modify as needed)
DIRECTORIES_TO_SCAN = ["./src", "./tests"]

def find_api_keys_in_file(file_path):
    """Scans a file for hardcoded API keys."""
    with open(file_path, "r", encoding="utf-8", errors="ignore") as file:
        content = file.read()
        for pattern in API_KEY_PATTERNS:
            if re.search(pattern, content):
                return True
    return False

def test_no_plaintext_api_keys():
    """Test to check that no API keys are present in plaintext."""
    flagged_files = []

    # Scan all files in specified directories
    for directory in DIRECTORIES_TO_SCAN:
        for root, _, files in os.walk(directory):
            for file in files:
                if file.endswith((".py", ".env", ".json", ".yaml", ".yml")):  # Scan relevant file types
                    file_path = os.path.join(root, file)
                    if find_api_keys_in_file(file_path):
                        flagged_files.append(file_path)

    # Assert that no files contain hardcoded API keys
    assert not flagged_files, f"❌ API keys found in: {flagged_files}"
