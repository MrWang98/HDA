#!/bin/bash
#SBATCH -J submit
#SBATCH -o slurm.out
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --gres=gpu:1

python main.py --task data --dset baby-care --gpu_id ${3} --lr 0.003 --seed 2019 --test_interval 1000 --num_iterations 10004 --snapshot_interval 10000 --s_dset_path data/DATA/${1}/50cm.txt --t_dset_path data/DATA/${1}/${2}_s.txt --some_target data/DATA/${1}/${2}_t.txt --batch_size 36 --net ResNet34 --heuristic 1 --heuristic_num 3 --heuristic_initial True --num_labels 2 --output_dir checkpoint/DATA --data_path ../raw_data/210621/150cm --image_prepare False --user ${1} 2> log/${1}/${2}.log