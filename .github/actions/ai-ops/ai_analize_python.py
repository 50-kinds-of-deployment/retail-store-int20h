import os
import json
import sys
import time
from google import genai

# Rate limiting: 30 requests per minute (2 seconds between requests)
RATE_LIMIT_REQUESTS = 30
RATE_LIMIT_PERIOD = 60  # seconds
MIN_REQUEST_INTERVAL = RATE_LIMIT_PERIOD / RATE_LIMIT_REQUESTS  # 2 seconds

last_request_time = 0

def rate_limit():
    """Enforce rate limiting - max 30 requests per minute."""
    global last_request_time
    current_time = time.time()
    time_since_last_request = current_time - last_request_time
    
    if time_since_last_request < MIN_REQUEST_INTERVAL:
        sleep_time = MIN_REQUEST_INTERVAL - time_since_last_request
        debug_log(f"Rate limiting: sleeping for {sleep_time:.2f} seconds")
        time.sleep(sleep_time)
    
    last_request_time = time.time()

# Debug flag
DEBUG = True

def debug_log(msg):
    if DEBUG:
        print(f"[DEBUG] {msg}")

# === CONFIG ===
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
REPO = os.getenv("GITHUB_REPOSITORY")  # Format: owner/repo
PR_NUMBER = os.getenv("GITHUB_REF").split("/")[2]
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

# Initialize Gemma client
client = genai.Client(api_key=GEMINI_API_KEY)

import requests
HEADERS = {
    "Authorization": f"Bearer {GITHUB_TOKEN}",
    "Accept": "application/vnd.github+json"
}


def get_changed_files():
    rate_limit()
    url = f"https://api.github.com/repos/{REPO}/pulls/{PR_NUMBER}/files"
    print(f"[INFO] Fetching changed files from: {url}")
    response = requests.get(url, headers=HEADERS)
    if response.status_code != 200:
        print(f"[ERROR] GitHub API error {response.status_code}: {response.text}")
        return []
    return response.json()


def clean_gemini_comment(comment):
    """
    Clean and format Gemma's response for GitHub PR comments.
    - Trims whitespace
    - Limits length to 65536 chars (GitHub API limit is much higher)
    - Removes excessive blank lines
    """
    comment = comment.strip()
    comment = '\n'.join([line.rstrip() for line in comment.splitlines() if line.strip() != ''])
    max_length = 65536
    if len(comment) > max_length:
        comment = comment[:max_length] + "\u2026"
    return comment

def generate_review_comment(diff_hunk, filename):
    prompt = f"""
You're a senior DevOps reviewer. Carefully review this code diff from `{filename}`.

- Only return specific, actionable, and concise inline review comments.
- Use clear markdown formatting for code, lists, or warnings.
- Avoid generic feedback. Focus on deprecated APIs, performance, testability, and DevOps best practices.
- Each comment should be suitable for direct posting as a GitHub inline review.
- If the diff is fine, return a short positive note.

Diff:
{diff_hunk}
"""
    debug_log(f"Generating review for {filename}")
    rate_limit()
    try:
        response = client.models.generate_content(
            model="gemma-3-27b-it",
            contents=prompt,
        )
        comment = response.text
    except Exception as e:
        print(f"[ERROR] Gemma API error: {e}")
        return ""
    return clean_gemini_comment(comment)

def get_latest_commit_sha():
    rate_limit()
    url = f"https://api.github.com/repos/{REPO}/pulls/{PR_NUMBER}"
    response = requests.get(url, headers=HEADERS)
    if response.status_code != 200:
        print(f"[ERROR] GitHub API error {response.status_code}: {response.text}")
        return None
    return response.json()["head"]["sha"]

def post_inline_comment(body, path, position):
    commit_id = get_latest_commit_sha()
    rate_limit()
    url = f"https://api.github.com/repos/{REPO}/pulls/{PR_NUMBER}/comments"
    data = {
        "body": body,
        "commit_id": commit_id,
        "path": path,
        "side": "RIGHT",
        "line": position
    }
    response = requests.post(url, headers=HEADERS, data=json.dumps(data))
    if response.status_code != 201:
        print(f"[ERROR] Failed to post inline comment: {response.status_code} {response.text}")
    else:
        print(f"[INFO] Posted inline comment on {path}:{position}")

def fetch_file_content(repo, path):
    rate_limit()
    url = f"https://api.github.com/repos/{repo}/contents/{path}"
    response = requests.get(url, headers=HEADERS)
    if response.status_code != 200:
        print(f"[ERROR] Failed to fetch file content: {response.status_code} {response.text}")
        return None
    content = response.json()["content"]
    import base64
    return base64.b64decode(content).decode("utf-8")

def generate_test_coverage_comment(source_code, test_code, source_filename, test_filename):
    prompt = f"""
You're a senior DevOps reviewer. Compare the following source file and its test file. Give feedback on:
- Test coverage and missing test cases
- Test quality (clarity, isolation, edge cases)
- Suggestions to improve testability

Source file: {source_filename}
{source_code}

Test file: {test_filename}
{test_code}
"""
    debug_log(f"Generating test coverage review for {source_filename} and {test_filename}")
    rate_limit()
    try:
        response = client.models.generate_content(
            model="gemma-3-27b-it",
            contents=prompt,
        )
        comment = response.text
    except Exception as e:
        print(f"[ERROR] Gemma API error: {e}")
        return ""
    return clean_gemini_comment(comment)

def post_pr_comment(body):
    rate_limit()
    url = f"https://api.github.com/repos/{REPO}/issues/{PR_NUMBER}/comments"
    data = {"body": body}
    response = requests.post(url, headers=HEADERS, data=json.dumps(data))
    if response.status_code != 201:
        print(f"[ERROR] Failed to post PR comment: {response.status_code} {response.text}")
    else:
        print(f"[INFO] Posted PR comment")

def main():
    changed_files = get_changed_files()
    review_comments = []
    
    for file in changed_files:
        filename = file["filename"]
        diff_hunk = file["patch"]
        comment = generate_review_comment(diff_hunk, filename)
        if comment:
            review_comments.append(f"**{filename}**\n{comment}")
    
    if review_comments:
        full_comment = "\n\n---\n\n".join(review_comments)
        post_pr_comment(f"## AI Code Review\n\n{full_comment}")

if __name__ == "__main__":
    main()