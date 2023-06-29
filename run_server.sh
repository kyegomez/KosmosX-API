# #!/bin/bash

# model_path=/model/kosmos2.pt

# master_port=$((RANDOM%1000+20000))

# CUDA_LAUNCH_BLOCKING=1 CUDA_VISIBLE_DEVICES=0 python -m torch.distributed.launch --master_port=$master_port --nproc_per_node=1 /api.py None \
#     --task generation_obj \
#     --path $model_path \
#     --model-overrides "{'visual_pretrained': '',
#             'dict_path':'data/dict.txt'}" \
#     --dict-path 'data/dict.txt' \
#     --required-batch-size-multiple 1 \
#     --remove-bpe=sentencepiece \
#     --max-len-b 500 \
#     --add-bos-token \
#     --beam 1 \
#     --buffer-size 1 \
#     --image-feature-length 64 \
#     --locate-special-token 1 \
#     --batch-size 1 \
#     --nbest 1 \
#     --no-repeat-ngram-size 3 \
#     --location-bin-size 32



#!/bin/bash

model_path=/app/model/kosmos2.pt

master_port=$((RANDOM%1000+20000))

CUDA_LAUNCH_BLOCKING=1 CUDA_VISIBLE_DEVICES=0 python -m torch.distributed.launch --master_port=$master_port --nproc_per_node=1 /app/api.py None \
    --task generation_obj \
    --path $model_path \
    --model-overrides "{'visual_pretrained': '',
            'dict_path':'data/dict.txt'}" \
    --dict-path 'data/dict.txt' \
    --required-batch-size-multiple 1 \
    --remove-bpe=sentencepiece \
    --max-len-b 500 \
    --add-bos-token \
    --beam 1 \
    --buffer-size 1 \
    --image-feature-length 64 \
    --locate-special-token 1 \
    --batch-size 1 \
    --nbest 1 \
    --no-repeat-ngram-size 3 \
    --location-bin-size 32
