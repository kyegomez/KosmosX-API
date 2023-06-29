## Checkpoints

The checkpoint can be downloaded from [here](https://conversationhub.blob.core.windows.net/beit-share-public/kosmos-2/kosmos-2.pt?sv=2021-10-04&st=2023-06-08T11%3A16%3A02Z&se=2033-06-09T11%3A16%3A00Z&sr=c&sp=r&sig=N4pfCVmSeq4L4tS8QbrFVsX6f6q844eft8xSuXdxU48%3D):
```bash
wget -O kosmos-2.pt "https://conversationhub.blob.core.windows.net/beit-share-public/kosmos-2/kosmos-2.pt?sv=2021-10-04&st=2023-06-08T11%3A16%3A02Z&se=2033-06-09T11%3A16%3A00Z&sr=c&sp=r&sig=N4pfCVmSeq4L4tS8QbrFVsX6f6q844eft8xSuXdxU48%3D"
```
## Setup

1. Download recommended docker image and launch it:
```bash
alias=`whoami | cut -d'.' -f2`; docker run -it --rm --runtime=nvidia --ipc=host --privileged -v /home/${alias}:/home/${alias} nvcr.io/nvidia/pytorch:22.10-py3 bash
```
2. Clone the repo:
```bash
git clone https://github.com/microsoft/unilm.git
cd unilm/kosmos-2
```
3. Install the packages:
```bash
bash vl_setup_xl.sh
``` 

## Demo

We host a public demo at [link](https://aka.ms/kosmos-2-demo). If you would like to host a local Gradio demo, run the following command after [setup](#setup):
```bash
# install gradio
pip install gradio

bash run_gradio.sh
``` 
