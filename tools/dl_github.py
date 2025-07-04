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
import urllib.request
from typing import Optional

class DownloadError(Exception):
    """Custom download exception"""
    pass

def download_file(url: str, output_path: str) -> None:
    """Download file with progress display"""
    def progress(count, block_size, total_size):
        if total_size > 0:
            percent = min(100, int(count * block_size * 100 / total_size))
            sys.stdout.write(f"\rDownloading... {percent}%")
            sys.stdout.flush()
        else:
            # Handle cases where total size is unknown
            sys.stdout.write(f"\rDownloading... {count * block_size:,} bytes")
            sys.stdout.flush()

    # print(f"\nFetching: {url}")
    try:
        urllib.request.urlretrieve(url, output_path, reporthook=progress)
    except urllib.error.HTTPError as e:
        raise DownloadError(f"HTTP Error {e.code}: {e.reason}")
    except urllib.error.URLError as e:
        raise DownloadError(f"URL Error: {e.reason}")

    sys.stdout.write("\n")

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
    # Create temporary directory structure
    temp_dir = tempfile.mkdtemp()
    try:
        temp_pack_dir = os.path.join(temp_dir, subdir_name)
        shutil.copytree(source_dir, temp_pack_dir)

        # re-packing command
        subprocess.run([
            'tar',
            '--sort=name',
            '--mtime=@0',
            '--owner=0',
            '--group=0',
            '-czf', output_path,
            '-C', temp_dir, subdir_name
        ], check=True)
    finally:
        shutil.rmtree(temp_dir)

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
        sys.stdout.write(f"Checking and repacking ... \n")
        extracted_dir = os.path.join(temp_dir, "extracted")
        os.makedirs(extracted_dir)
        with tarfile.open(temp_file, "r:gz") as tar:
            tar.extractall(extracted_dir, filter='data')
        
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
