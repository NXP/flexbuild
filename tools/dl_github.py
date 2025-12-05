#!/usr/bin/env python3
"""
GitHub Source Download Tool
Features:
1. Output filename format: subdir_version.tar.gz
2. Supports hash verification (verifies repacked file)
3. Automatically detects and rejects repositories with submodules
"""

import argparse
import hashlib
import os
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
import requests
from requests.adapters import HTTPAdapter, Retry
from tqdm import tqdm
from typing import Optional

class DownloadError(Exception):
    """Custom download exception"""
    pass

def download_file(url: str, output_path: str, retries: int = 3, timeout: int = 30, use_tqdm: bool = False) -> None:
    """Download file with resume and retry support using requests.
    Args:
        url: Download URL.
        output_path: Destination file path.
        retries: Number of retry attempts.
        timeout: Timeout in seconds.
        use_tqdm: Whether to show tqdm progress bar.
    """

    # Ensure parent directory exists
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    # Configure requests session with retry strategy
    session = requests.Session()
    retry_strategy = Retry(
        total=retries,
        backoff_factor=2,        # exponential backoff: 2s, 4s, 8s
        status_forcelist=[500, 502, 503, 504],
        allowed_methods=["HEAD", "GET", "OPTIONS"]
    )
    adapter = HTTPAdapter(max_retries=retry_strategy)
    session.mount("http://", adapter)
    session.mount("https://", adapter)

    # If partial file exists, try to resume download
    resume_byte_pos = os.path.getsize(output_path) if os.path.exists(output_path) else 0
    headers = {"Range": f"bytes={resume_byte_pos}-"} if resume_byte_pos > 0 else {}

    # export GITHUB_TOKEN=your_personal_access_token
    # Add GitHub token if available to avoid rate limiting
    github_token = os.getenv("GITHUB_TOKEN")
    if github_token:
        headers["Authorization"] = f"token {github_token}"

    try:
        with session.get(url, headers=headers, timeout=timeout, stream=True) as response:
            # deal with the rate limit and other error
            if response.status_code == 403:
                try:
                    error_info = response.json()
                    if "API rate limit exceeded" in error_info.get("message", ""):
                        #raise DownloadError(
                        #    f"GitHub API rate limit exceeded.\n"
                        #    f"Message: {error_info['message']}\n"
                        #    f"See: {error_info['documentation_url']}"
                        #)
                        sys.exit(1)
                except ValueError:
                    raise DownloadError("Access denied or rate limited (403), and response is not JSON.")

            if response.status_code not in (200, 206):
                sys.exit(1)
                #raise DownloadError(f"Unexpected status code: {response.status_code}")

            # If server does not support Range, it will return 200 → overwrite file
            mode = "ab" if response.status_code == 206 else "wb"
            total_size = int(response.headers.get("Content-Length", 0)) + resume_byte_pos

            with open(output_path, mode) as f, tqdm(
                total=total_size if total_size > 0 else None,
                initial=resume_byte_pos,
                unit="B",
                unit_scale=True,
                unit_divisor=1024,
                desc="Downloading",
                disable=not use_tqdm,
            ) as pbar:
                for chunk in response.iter_content(chunk_size=8192):
                    if not chunk:
                        continue
                    f.write(chunk)
                    pbar.update(len(chunk))

        #sys.stdout.write("Download complete.\n")
    except requests.exceptions.RequestException as e:
        if os.path.exists(output_path):
            os.remove(output_path)  # remove partial file on failure
        raise DownloadError(f"Download failed: {e}") from e

def verify_hash(file_path: str, expected_hash: str) -> None:
    """Verify file hash (supports SHA256/MD5)"""
    hash_algo = hashlib.sha256() if len(expected_hash) == 64 else hashlib.md5()
    with open(file_path, 'rb') as f:
        while chunk := f.read(8192):
            hash_algo.update(chunk)
    if hash_algo.hexdigest() != expected_hash:
        raise DownloadError(f"Hash mismatch!\nExpected: {expected_hash}\nActual:   {hash_algo.hexdigest()}")

def check_gitmodules_subdir(extracted_dir: str) -> None:
    """Check for .gitmodules file existence"""
    for root, _, files in os.walk(extracted_dir):
        if '.gitmodules' in files:
            raise DownloadError("Repository contains submodules (not supported)")
def check_gitmodules(extracted_dir: str) -> None:
    """Check for .gitmodules file existence"""
    for root, _, files in os.walk(extracted_dir):
        if '.gitmodules' in os.listdir(extracted_dir):
            raise DownloadError("Repository contains submodules (not supported)")

def create_output_filename(subdir: str, version: str) -> str:
    """Generate standardized output filename: subdir_version.tar.gz"""
    safe_version = re.sub(r'[^a-zA-Z0-9._-]', '_', version)
    return f"{subdir}_{safe_version}.tar.gz"

def repack(source_dir: str, output_path: str, subdir_name: str) -> None:
    """
    OpenWrt standardized repacking method
    Key parameters:
    --sort=name      Fixed file order
    --mtime=@0       Fixed timestamp (UNIX epoch)
    --owner=0 --group=0  Fixed ownership
    -czf             Use gzip compression
    """

    original_dir = os.path.dirname(source_dir)
    temp_pack_dir = os.path.join(original_dir, subdir_name)

    if os.path.exists(temp_pack_dir):
        shutil.rmtree(temp_pack_dir)

    shutil.move(source_dir, temp_pack_dir)

    # re-packing command
    subprocess.run([
        'tar',
        '--sort=name',
        '--mtime=@0',
        '--owner=0',
        '--group=0',
        '-czf', output_path,
        '-C', original_dir, subdir_name
    ], check=True)


def find_extracted_source_dir(extracted_dir: str, repo: str, version: str) -> str:
    """Robust implementation for locating source directory from GitHub archive extraction

    Args:
        extracted_dir: Path where the archive was extracted
        repo: Repository name (e.g., 'alsa-lib')
        version: Version/ref (e.g., 'v1.2.11')

    Returns:
        Path to the identified source directory

    Raises:
        DownloadError: When no valid source directory can be determined
    """
    # 1. Normalize input parameters
    repo = repo.lower().replace('.git', '')
    version_clean = version.lstrip('vV').replace('/', '-')

    # 2. Generate all possible naming patterns
    separators = ['-', '_', '.', '']
    version_prefixes = ['', 'v', 'V']
    patterns = {
        f"{repo}{sep}{vpre}{version_clean}"
        for sep in separators
        for vpre in version_prefixes
    }

    # 3. Try exact case-insensitive match first
    for entry in os.listdir(extracted_dir):
        if entry.lower() in patterns:
            return os.path.join(extracted_dir, entry)

    # 4. Fallback to partial matching (repo name + version fragment)
    for entry in os.listdir(extracted_dir):
        entry_lower = entry.lower()
        if (repo in entry_lower) and (version_clean[:5] in entry_lower):
            return os.path.join(extracted_dir, entry)

    # 5. Smart fallback: Detect build system files
    candidates = []
    for entry in os.listdir(extracted_dir):
        dir_path = os.path.join(extracted_dir, entry)
        if os.path.isdir(dir_path):
            # Check for common build system indicators
            if any(os.path.exists(os.path.join(dir_path, marker))
                  for marker in ['CMakeLists.txt', 'Makefile', 'configure.ac']):
                candidates.append(dir_path)

    # 6. Return if only one candidate exists
    if len(candidates) == 1:
        return candidates[0]

    # 7. Final fallback: Select most recently modified directory
    if candidates:
        return max(candidates, key=lambda x: os.path.getmtime(x))

    # 8. Exhausted all strategies
    raise DownloadError(
        "Failed to automatically determine source directory.\n"
        f"Extracted contents: {os.listdir(extracted_dir)}\n"
        f"Search parameters: repo={repo}, version={version}"
    )

def download_and_process(
    repo_url: str,
    version: str,
    dl_dir: str,
    subdir_name: str,
    file_hash: Optional[str] = None
) -> str:
    """
    Main processing pipeline (OpenWrt compatible)
    """
    # Parse repository information
    match = re.match(r"(?:https?|git)://github.com/([^/]+)/([^/]+?)(?:\.git)?$", repo_url)
    if not match:
        raise DownloadError(f"Invalid GitHub URL: {repo_url}")
    owner, repo = match.groups()

    # Prepare output directory and filename
    os.makedirs(dl_dir, exist_ok=True)
    output_filename = create_output_filename(subdir_name, version)
    output_file = os.path.join(dl_dir, output_filename)

    # Process using temporary directory
    with tempfile.TemporaryDirectory() as temp_dir:
        # 1. Download original archive
        archive_url = f"https://github.com/{owner}/{repo}/archive/{version}.tar.gz"
        temp_file = os.path.join(temp_dir, "source.tar.gz")
        download_file(archive_url, temp_file)

        # 2. Extract original archive
        # sys.stdout.write(f"Checking and repacking  \n")
        extracted_dir = os.path.join(temp_dir, "extracted")
        os.makedirs(extracted_dir)
        try:
            with tarfile.open(temp_file, "r:gz") as tar:
                tar.extractall(extracted_dir, filter='data')
        except tarfile.AbsoluteLinkError:
            try:
                subprocess.run(
                    ['tar', 'xzf', temp_file, '--no-same-owner', '-C', extracted_dir],
                    check=True,
                    stderr=subprocess.PIPE
                )
            except subprocess.CalledProcessError as e:
                raise DownloadError(
                        f"Failed to extract archive (even with fallback): {e.stderr.decode().strip()}\n"
                        f"URL: {archive_url}"
                )

        #with tarfile.open(temp_file, "r:gz") as tar:
            #tar.extractall(extracted_dir, filter='data')

        # 3. Check for submodules
        check_gitmodules(extracted_dir)

        # 4. Standardized repacking
        source_dir = find_extracted_source_dir(extracted_dir, repo, version)
        repack(source_dir, output_file, subdir_name)

        # 5. Final hash verification
        if file_hash:
            verify_hash(output_file, file_hash)

    return output_file

def main():
    parser = argparse.ArgumentParser(
        description="GitHub Source Download Tool (OpenWrt Standardized)",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument("--url", required=True,
                      help="GitHub repository URL (e.g. https://github.com/user/repo.git)")
    parser.add_argument("--version", required=True,
                      help="Version (branch/tag/commit hash)")
    parser.add_argument("--dl-dir", required=True,
                      help="Output directory for downloaded files")
    parser.add_argument("--subdir", required=True,
                      help="Top-level directory name in the archive")
    parser.add_argument("--hash",
                      help="Optional hash value (SHA256/MD5) for final verification")

    args = parser.parse_args()

    try:
        result_path = download_and_process(
            repo_url=args.url,
            version=args.version,
            dl_dir=args.dl_dir,
            subdir_name=args.subdir,
            file_hash=args.hash
        )
        # print(f"\nOperation completed successfully! Output file: {result_path}")
    except DownloadError as e:
        print(f"\nError occurred: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
