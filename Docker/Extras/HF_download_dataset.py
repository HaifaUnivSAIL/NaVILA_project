from huggingface_hub import snapshot_download
import argparse
import os

def download_dataset(repo_id: str, destination: str):
    """
    Download a Hugging Face dataset repo to a specified local directory.
    """
    os.makedirs(destination, exist_ok=True)

    print(f"Downloading dataset from {repo_id} to {destination}...")

    local_dir = snapshot_download(
        repo_id=repo_id,
        repo_type="dataset",
        local_dir=destination,
        local_dir_use_symlinks=False,   # IMPORTANT for large datasets
        revision="main",                # ensures latest version
        tqdm_class=None                 # optional: disable progress bar
    )

    print(f"Dataset downloaded to: {local_dir}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Download HF dataset to a specific folder")
    parser.add_argument("--source", required=True, help="Hugging Face dataset repo ID")
    parser.add_argument("--dest", required=True, help="Destination folder")

    args = parser.parse_args()

    download_dataset(args.source, args.dest)
