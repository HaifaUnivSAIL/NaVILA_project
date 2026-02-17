import os
import torch
import torch.distributed as dist
import sys

# -----------------------------
# 1. Pretend torchrun was used
# -----------------------------
os.environ["MASTER_ADDR"] = "localhost"
os.environ["MASTER_PORT"] = "12345"

# Single process, single GPU
os.environ["RANK"] = "0"
os.environ["LOCAL_RANK"] = "0"
os.environ["WORLD_SIZE"] = "1"

# Optional – prevent FlashAttention auto mess
os.environ["DISABLE_FLASH_ATTENTION"] = "1"

# -----------------------------
# 2. Initialize fake process group
# -----------------------------
def init_ddp():
    if not dist.is_initialized():
        dist.init_process_group(
            backend="nccl",        # CUDA
            init_method="env://",  # same as torchrun
            world_size=1,
            rank=0
        )
        print("⚡ DDP initialized for single-GPU debugging.")

# -----------------------------
# 3. Patch sys.argv to forward arguments to train_mem.py
# -----------------------------
sys.argv = [
    "train_mem.py",
    "--longvila_sampler", "True",
    "--model_name_or_path", "a8cheng/navila-siglip-llama3-8b-v1.5-pretrain",
    "--version" ,"llama_3",
    "--seed", "10",
    "--data_mixture", "r2r+rxr+scanqa",
    "--vision_tower", "google/siglip-so400m-patch14-384",
    "--mm_vision_select_feature", 'cls_patch',
    "--mm_projector", "mlp_downsample",
    "--num_video_frames", "8",
    "--tune_vision_tower", "False",
    "--tune_mm_projector", "True",
    "--tune_language_model", "False",
    "--mm_vision_select_layer", "-2",
    "--mm_use_im_start_end", "False",
    "--mm_use_im_patch_token", "False",
    "--image_aspect_ratio", "resize",
    "--bf16", "True",
    "--output_dir", "/mnt/dataset/NaVILA_Dataset/checkpoints/navila-8b-8f-sft",
    "--num_train_epochs", "1",
    "--per_device_train_batch_size", "1",
    "--gradient_accumulation_steps", "4",
    "--do_eval", "False",
    "--save_strategy", "steps",
    "--save_steps", "100",
    "--fps", "0.0",
    "--save_total_limit", "1",
    "--learning_rate", "1e-4",
    "--weight_decay", "0.",
    "--warmup_ratio", "0.03",
    "--lr_scheduler_type", "cosine",
    "--logging_steps", "1",
    "--model_max_length", "4096",
    "--gradient_checkpointing", "True",
    "--dataloader_num_workers", "16",
    "--lazy_preprocess", "True",
    "--report_to", "none"
]

# -----------------------------
# 4. Initialize DDP BEFORE importing train_mem
# -----------------------------
init_ddp()

# -----------------------------
# 5. Import the actual training script
# -----------------------------
print("⚡ Launching train_mem.py inside PyCharm...")

from NaVILA.llava.train import train_mem

# train_mem.py calls train() when executed directly,
# but here we want to call train() manually:
train_mem.train()

print("✅ Training finished.")
