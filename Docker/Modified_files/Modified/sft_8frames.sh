#!/bin/bash
n_node=1
GPUS_PER_NODE=1          # or 2 / 4 depending on your GPU count
MASTER_PORT=29500        # any free port
MASTER_ADDR=localhost
CURRENT_RANK=0
OUTPUT="/mnt/dataset/NaVILA_Dataset/checkpoints/navila-8b-8f-sft"

torchrun --nnodes=$n_node --nproc_per_node=$GPUS_PER_NODE --master_port=$MASTER_PORT \
    --master_addr $MASTER_ADDR --node_rank=$CURRENT_RANK \
    ../../llava/train/train_mem.py \
    --longvila_sampler True \
    --model_name_or_path a8cheng/navila-siglip-llama3-8b-v1.5-pretrain \
    --version llama_3 \
    --seed 10 \
    --data_mixture r2r+rxr+envdrop+human+scanqa+video_chatgpt+sharegpt_video+sharegpt4v_sft \
    --vision_tower google/siglip-so400m-patch14-384 \
    --mm_vision_select_feature cls_patch \
    --mm_projector mlp_downsample \
    --num_video_frames 8 \
    --tune_vision_tower True \
    --tune_mm_projector True \
    --tune_language_model True \
    --mm_vision_select_layer -2 \
    --mm_use_im_start_end False \
    --mm_use_im_patch_token False \
    --image_aspect_ratio resize \
    --bf16 True \
    --output_dir $OUTPUT \
    --num_train_epochs 1 \
    --per_device_train_batch_size 10 \
    --gradient_accumulation_steps 2 \
    --do_eval False \
    --save_strategy "steps" \
    --save_steps 100 \
    --fps 0.0 \
    --save_total_limit 1 \
    --learning_rate 1e-4 \
    --weight_decay 0. \
    --warmup_ratio 0.03 \
    --lr_scheduler_type "cosine" \
    --logging_steps 1 \
    --model_max_length 4096 \
    --gradient_checkpointing True \
    --dataloader_num_workers 16 \
    --lazy_preprocess True \
    --report_to wandb
    #--tf32 True
    #--deepspeed ../../scripts/zero3.json \
