#!/bin/bash

export CUDA_VISIBLE_DEVICES=3
export TOKENIZERS_PARALLELISM=false
# export CUDA_LAUNCH_BLOCKING=1


cd /root/SLAM-LLM

speech_encoder_path=/nfs/maziyang.mzy/models/Whisper/large-v3.pt

llm_path=/nfs/maziyang.mzy/models/vicuna-7b-v1.5

output_dir=/nfs/yangguanrou.ygr/experiments_slides_whisper/slides-finetune-whisperv3_notext
ckpt_path=$output_dir/asr/19760

decode_log=/root/SLAM-LLM/scripts_all/scripts_ner/decode_log_Giga_noname

# -m debugpy --listen 5678 --wait-for-client
python src/llama_recipes/pipeline/inference_batch.py \
--config-path "/root/SLAM-LLM/scripts/slides_conf" \
--config-name "ner.yaml" \
hydra.run.dir=$ckpt_path \
++model_config.llm_name="vicuna-7b-v1.5" \
++model_config.llm_path=$llm_path \
++model_config.llm_dim=4096 \
++model_config.encoder_name=whisper \
++model_config.encoder_ds_rate=2 \
++model_config.encoder_path=$speech_encoder_path \
++model_config.encoder_dim=1280 \
++model_config.encoder_projector=cov1d-linear \
++encoder_projector_ds_rate=5 \
++dataset_config.dataset=giga_dataset \
++dataset_config.file=src/llama_recipes/datasets/giga_dataset.py:get_audio_dataset \
++dataset_config.use_ocr=false \
++dataset_config.inference_mode=true \
++dataset_config.dev_scp_file_path=/nfs/yangguanrou.ygr/data/ner/giga_name_test/ \
++train_config.model_name=asr \
++train_config.batching_strategy=custom \
++train_config.num_epochs=1 \
++train_config.val_batch_size=4 \
++train_config.num_workers_dataloader=1 \
++train_config.output_dir=$output_dir \
++ckpt_path=$ckpt_path/model.pt \
++decode_log=$decode_log \
++train_config.freeze_encoder=true \
++train_config.freeze_llm=true \


# bash scripts_all/scripts_ner/inference_slide_whisperv3_notext_giga_noname.sh > scripts_all/scripts_ner/inference_slide_whisperv3_notext_giga_noname.log