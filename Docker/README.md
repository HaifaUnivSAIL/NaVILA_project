# NaVILA_project
Based on the NaVILA repo

1) Inference:
* To download the MatterPort3D dataset, add the following arguments to the script "download_mp3D.py" (in the "Extras" folder): *
-o "/mnt/dataset/NaVILA_Dataset/data/scene_datasets" --task_data habitat
Then unzip the file "mp3d_habitat.zip" using the following command:
unzip mp3d_habitat.zip -d /mnt/dataset/NaVILA_Dataset/data/scene_datasets
(If you dont have zip install it using sudo apt-get update \ sudo apt-get install unzip).
(If the folder doesnt exist create it using: mkdir -p /mnt/dataset/NaVILA_Dataset/data/scene_datasets).

mkdir -p /mnt/dataset/NaVILA_Dataset/data/datasets
# R2R_VLNCE_v1-3_preprocessed:
cd /mnt/dataset/NaVILA_Dataset/data/datasets
gdown https://drive.google.com/uc?id=1fo8F4NKgZDH-bPSdVU3cONAkt5EW-tyr
unzip R2R_VLNCE_v1-3_preprocessed.zip -d ./

# RxR_VLNCE_v0:
cd /mnt/dataset/NaVILA_Dataset/data/datasets
gdown https://drive.google.com/uc?id=145xzLjxBaNTbVgBfQ8e9EsBAV8W-SM0t
unzip RxR_VLNCE_v0.zip -d ./


** To download the final weights: **
huggingface-cli download a8cheng/navila-llama3-8b-8f --local-dir /mnt/dataset/NaVILA_Dataset/checkpoints/navila-llama3-8b-8f --local-dir-use-symlinks False

*** Then to actually run Inference just run the "run.py" (in /workspace/NaVILA/evaluation) script with the following arguments: ***
--exp-config /workspace/NaVILA/evaluation/vlnce_baselines/config/r2r_baselines/navila.yaml --run-type eval --num-chunks 1 --chunk-idx 0 EVAL_CKPT_PATH_DIR /mnt/dataset/NaVILA_Dataset/checkpoints/navila-llama3-8b-8f

2) Training:
* To download the datasets, add the following arguments to the script "download_mp3D.py": *
Datasets annotations:
mkdir -p /mnt/dataset/NaVILA_Dataset/NaVILA_Dataset
cd /mnt/dataset/NaVILA_Dataset/NaVILA_Dataset
sudo apt install git-lfs
git lfs install
git clone https://huggingface.co/datasets/a8cheng/NaVILA-Dataset

unzip all of the tar.gz files inside the new cloned folder:
cd /mnt/dataset/NaVILA_Dataset/NaVILA_Dataset/NaVILA-Dataset/ScanQA
tar -xf videos.tar.gz
/mnt/dataset/NaVILA_Dataset/NaVILA_Dataset/NaVILA-Dataset/R2R
tar -xf train.tar.gz
cd /mnt/dataset/NaVILA_Dataset/NaVILA_Dataset/NaVILA-Dataset/RxR
tar -xf train.tar.gz
Optional: For space efficcancy remove the tar files after extraction with "rm train.tar.gz".

Actuall data:
R2R:
# R2R_VLNCE_v1-3
gdown https://drive.google.com/uc?id=1T9SjqZWyR2PCLSXYkFckfDeIs6Un0Rjm


RxR:
Download from the following link:
gdown https://drive.google.com/file/d/145xzLjxBaNTbVgBfQ8e9EsBAV8W-SM0t

** To download the pretrained weights run the following command from the prompt: **
huggingface-cli download a8cheng/navila-siglip-llama3-8b-v1.5-pretrain --local-dir /mnt/dataset/NaVILA_Dataset/checkpoints/navila-siglip-llama3-8b-v1.5-pretrain --local-dir-use-symlinks False

On Jonathan Steinberg's remote server, there is an issue of running the file "train_mem.py" using only a single GPU at the moment, so the code should be called from the terminal in the following way (Or you should run/debug from Pycharm using the customized wrapper I created "debug_train_mem.py" with out any arguments in the configuration window, since all of the necessary arguments are hard copied inside the wrapper):
 python -m torch.distributed.run --nproc_per_node=1 /workspace/NaVILA/llava/train/train_mem.py [with the following arguments...]
 
*** Then to actually run Training just run the "train_mem.py" (in /workspace/NaVILA/llava/train) script with the following arguments: ***
--longvila_sampler True --model_name_or_path a8cheng/navila-siglip-llama3-8b-v1.5-pretrain --version llama_3 --seed 10 --data_mixture r2r+rxr+scanqa --vision_tower google/siglip-so400m-patch14-384 --mm_vision_select_feature cls_patch --mm_projector mlp_downsample --num_video_frames 8 --tune_vision_tower True --tune_mm_projector True --tune_language_model True --mm_vision_select_layer -2 --mm_use_im_start_end False --mm_use_im_patch_token False --image_aspect_ratio resize --bf16 True --output_dir /mnt/dataset/NaVILA_Dataset/checkpoints/navila-8b-8f-sft --num_train_epochs 1 --per_device_train_batch_size 10 --gradient_accumulation_steps 2 --do_eval False --save_strategy steps --save_steps 100 --fps 0.0 --save_total_limit 1 --learning_rate 1e-4 --weight_decay 0. --warmup_ratio 0.03 --lr_scheduler_type cosine --logging_steps 1 --model_max_length 4096 --gradient_checkpointing True --dataloader_num_workers 16 --lazy_preprocess True --report_to wandb
