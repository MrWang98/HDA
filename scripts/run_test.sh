python main.py --task data --dset baby-care --gpu_id 1 --lr 0.005 --seed 2019 --test_interval 500 --num_iterations 20004 --snapshot_interval 20000 --s_dset_path data/DATA/adult_s.txt --t_dset_path data/DATA/adult_t.txt --batch_size 36 --net ResNet34 --heuristic 1 --heuristic_num 3 --heuristic_initial True --num_labels 2 --output_dir HDA/DATA
