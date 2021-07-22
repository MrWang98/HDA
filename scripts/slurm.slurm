#!/bin/bash
#SBATCH -J guxiang
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20
#SBATCH --gres=gpu:1

bash run.sh
