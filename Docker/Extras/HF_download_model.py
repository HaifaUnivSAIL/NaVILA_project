from huggingface_hub import snapshot_download
import argparse
import os


def download_model(repo_id: str, destination: str):
    """
    Download a Hugging Face model repo to a specified local directory.

    Args:
        repo_id (str): Hugging Face repo ID (e.g., "a8cheng/navila-siglip-llama3-8b-v1.5-pretrain")
        destination (str): Local directory where files will be downloaded
    """
    # Make sure destination exists
    os.makedirs(destination, exist_ok=True)

    print(f"Downloading model from {repo_id} to {destination}...")
    local_dir = snapshot_download(repo_id, cache_dir=destination)
    print(f"Model downloaded to: {local_dir}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Download Hugging Face model to a specific folder")
    parser.add_argument("--source", required=True,
                        help="Hugging Face repo ID (e.g., a8cheng/navila-siglip-llama3-8b-v1.5-pretrain)")
    parser.add_argument("--dest", required=True, help="Destination folder for the model files")

    args = parser.parse_args()

    download_model(args.source, args.dest)
