#!/bin/bash
#SBATCH -J fck_right
#SBATCH -o slurm.out
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --gres=gpu:1

conda activate pytorch
python main.py