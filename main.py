import argparse
import os
import os.path as osp

import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
from torch.autograd import Variable
import random
import pdb
import math
from distutils.version import LooseVersion

import network.network as network
import utils.loss as loss
import utils.lr_schedule as lr_schedule
import dataset.preprocess as prep
from dataset.dataloader import ImageList
from scripts.train_uda import train_uda
from scripts.train_ssda import train_ssda
from scripts.train_msda import train_msda
from scripts.train_test import train_test
from radar_script.matlab_processer import image_processer,write_txt



if __name__ == "__main__":

    #parameters
    assert LooseVersion(torch.__version__) >= LooseVersion('1.0.0'), 'PyTorch>=1.0.0 is required'

    parser = argparse.ArgumentParser(description='Domain Adaptation')
    parser.add_argument('--task', type=str, default='data', help="select the task(UDA, SSDA, MSDA)")
    parser.add_argument('--image_prepare', type=bool, default='False', help="prepare image")
    parser.add_argument('--data_path', type=str, default='../raw_data/210621/150cm', help="raw-data path of radar")
    parser.add_argument('--range', type=int, default=256, help="range of rangefft")
    parser.add_argument('--gpu_id', type=str, nargs='?', default='1', help="device id to run")
    parser.add_argument('--net', type=str, default='ResNet34', help="Options: ResNet50")
    parser.add_argument('--dset', type=str, default='baby-care', help="The dataset or source dataset used")

    parser.add_argument('--user', type=str, default='juhao3', help="user name")
    parser.add_argument('--kind', type=str, default='30h', help="kind of experiments")

    parser.add_argument('--s_dset_path', type=str, default='data/DATA/', help="The source dataset path list")
    parser.add_argument('--t_dset_path', type=str, default='data/DATA/', help="The target dataset path list")
    parser.add_argument('--some_target', type=str, default='data/DATA/', help="The target dataset path list")
    parser.add_argument('--output_dir', type=str, default='checkpoint/DATA', help="output directory of our model (in ../snapshot directory)")
    parser.add_argument('--test_interval', type=int, default=1000, help="interval of two continuous test phase")
    parser.add_argument('--snapshot_interval', type=int, default=10000, help="interval of two continuous output model")
    parser.add_argument('--print_num', type=int, default=100, help="interval of two print loss")
    parser.add_argument('--num_iterations', type=int, default=10004, help="interation num ")
    parser.add_argument('--lr', type=float, default=0.003, help="learning rate")
    parser.add_argument('--trade_off', type=float, default=1, help="parameter for transfer loss")
    parser.add_argument('--batch_size', type=int, default=36, help="batch size")
    parser.add_argument('--seed', type=int, default=2019, help="batch size ???")
    parser.add_argument('--heuristic_num', type=int, default=3, help="number of heuristic subnetworks")
    parser.add_argument('--heuristic_initial', type=bool, default=True, help="number of heuristic subnetworks")
    parser.add_argument('--heuristic', type=float, default=1, help="lambda: parameter for heuristic (if lambda==0 then heuristic is not utilized)")
    parser.add_argument('--gauss', type=float, default=0, help="utilize different initialization or not)")
    parser.add_argument('--num_labels', type=int, default=2, help="parameter for SSDA")
    args = parser.parse_args()
    os.environ["CUDA_VISIBLE_DEVICES"] = args.gpu_id

    # train config
    config = {}
    config["heuristic"] = args.heuristic
    config["gauss"] = args.gauss
    config["gpu"] = args.gpu_id
    config["num_iterations"] = args.num_iterations 
    config["print_num"] = args.print_num
    config["test_interval"] = args.test_interval
    config["snapshot_interval"] = args.snapshot_interval
    config["output_for_test"] = True
    config["output_path"] = osp.join('result',args.user)

    if not osp.exists(config["output_path"]):
        os.system('mkdir -p '+config["output_path"])
    config["out_file"] = open(osp.join(config["output_path"],args.kind+".log"), "w")
    if not osp.exists(config["output_path"]):
        os.mkdir(config["output_path"])


    config["prep"] = {'params':{"resize_size":256, "crop_size":224, 'alexnet':False}}
    config["loss"] = {"trade_off":args.trade_off}
    if "ResNet" in args.net:
        config["network"] = {"name":network.ResNetFc, \
            "params":{"resnet_name":args.net, "bottleneck_dim":256, "new_cls":True, "heuristic_num":args.heuristic_num, "heuristic_initial":args.heuristic_initial} }
    else:
        raise ValueError('Network cannot be recognized. Please define your own dataset here.')

    config["optimizer"] = {"type":optim.SGD, "optim_params":{'lr':args.lr, "momentum":0.9, \
                           "weight_decay":0.0005, "nesterov":True}, "lr_type":"inv", \
                           "lr_param":{"lr":args.lr, "gamma":0.001, "power":0.75} }

    config["dataset"] = args.dset
    if config["dataset"] == "office-home":
        config["optimizer"]["lr_param"]["lr"] = 0.001 # optimal parameters
        config["network"]["params"]["class_num"] = 65
    elif config["dataset"] == "office":
        seed = 2019
        if   ("webcam" in args.s_dset_path and "amazon" in args.t_dset_path) or \
             ("dslr" in args.s_dset_path and "amazon" in args.t_dset_path):
             config["optimizer"]["lr_param"]["lr"] = 0.001 # optimal parameters
        elif ("amazon" in args.s_dset_path and "webcam" in args.t_dset_path) or \
             ("amazon" in args.s_dset_path and "dslr" in args.t_dset_path) or \
             ("webcam" in args.s_dset_path and "dslr" in args.t_dset_path) or \
             ("dslr" in args.s_dset_path and "webcam" in args.t_dset_path):
             config["optimizer"]["lr_param"]["lr"] = 0.0003 # optimal parameters
        config["network"]["params"]["class_num"] = 31
    elif config["dataset"] == "visda":
        seed = 9297
        config["optimizer"]["lr_param"]["lr"] = 0.0003 # optimal parameters
        config["network"]["params"]["class_num"] = 12
    elif config["dataset"] == "domainnet":
        config["network"]["params"]["class_num"] = 345
        #config["optimizer"]["lr_param"]["lr"] = 0.001 # optimal parameters
        config["optimizer"]["lr_param"]["lr"] = args.lr # optimal parameters
    elif config["dataset"] == "baby-care":
        config["optimizer"]["lr_param"]["lr"] = args.lr  # optimal parameters
        config["network"]["params"]["class_num"] = 2
    else:
        raise ValueError('Dataset cannot be recognized. Please define your own dataset here.')
    if args.seed:
        seed = args.seed
    else:
        seed = random.randint(1,10000)
    print(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    np.random.seed(seed)
    random.seed(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False

    config["out_file"].write(str(config))
    config["out_file"].flush()
    if args.task== "UDA":
        config["data"] = {"source":{"list_path":os.path.join('data_test','UDA_officehome',args.s_dset_path), "batch_size":args.batch_size}, \
                      "target":{"list_path":os.path.join('data_test','UDA_officehome',args.t_dset_path), "batch_size":args.batch_size}, \
                      "test":{"list_path":os.path.join('data_test','UDA_officehome',args.t_dset_path), "batch_size":args.batch_size}}
        train_uda(config)
    elif args.task== "SSDA":
        config["network"]["params"]["class_num"] = 126
        target_path = args.t_dset_path.replace('.txt','_'+str(args.num_labels)+'.txt')
        config["data"] = {"source":{"list_path":args.s_dset_path, "batch_size":args.batch_size}, \
                      "target1":{"list_path":target_path, "batch_size":args.batch_size}, \
                      "target2":{"list_path":target_path.replace('labeled', 'unlabeled'), "batch_size":args.batch_size}, \
                      "test":{"list_path":target_path.replace('labeled','unlabeled'), "batch_size":args.batch_size}}
        train_ssda(config)
    elif args.task== "MSDA":
        config["data"] = {"target":{"list_path":args.t_dset_path, "batch_size":args.batch_size}, \
                      "test":{"list_path":args.t_dset_path.replace('train','test'), "batch_size":args.batch_size*2}}
        config["data_list"] = ["data/MSDA_domainnet/clipart_train.txt","data/MSDA_domainnet/infograph_train.txt","data/MSDA_domainnet/painting_train.txt","data/MSDA_domainnet/quickdraw_train.txt","data/MSDA_domainnet/real_train.txt","data/MSDA_domainnet/sketch_train.txt"]
        train_msda(config)
    elif args.task=="data":
        config["data"] = {"source": {"list_path": os.path.join(args.s_dset_path),
                                     "batch_size": args.batch_size}, \
                          "source2":{"list_path": os.path.join(args.some_target)},
                          "target": {"list_path": os.path.join(args.t_dset_path),
                                     "batch_size": args.batch_size}, \
                          "test": {"list_path": os.path.join(args.t_dset_path),
                                   "batch_size": args.batch_size}}
        # config["data"] = {"source": {"list_path": os.path.join(args.s_dset_path,args.user,args.kind+'.txt'),
        #                              "batch_size": args.batch_size}, \
        #                   "source2": {"list_path": os.path.join(args.some_target,args.user,args.kind+'_t.txt')},
        #                   "target": {"list_path": os.path.join(args.t_dset_path,args.user,args.kind+'_s.txt'),
        #                              "batch_size": args.batch_size}, \
        #                   "test": {"list_path": os.path.join(args.t_dset_path,args.user,args.kind+'_S.txt'),
        #                            "batch_size": args.batch_size}}
        config["user"] = {"name":args.user}
        config["kind"] = args.kind
        # if not args.image_prepare:
        #     config["data"] = {"source": {"list_path": args.s_dset_path,
        #                                  "batch_size": args.batch_size}, \
        #                       "target": {"list_path": args.t_dset_path,
        #                                  "batch_size": args.batch_size}, \
        #                       "test": {"list_path": args.t_dset_path,
        #                                "batch_size": args.batch_size}}
        # else:
        #     data_path = args.data_path
        #     range = 256
        #     image_path = image_processer(data_path, range,flag=True)
        #     all_path, sorce_path, target_path = write_txt(image_path, 0.7)
        #     config["data"] = {"source": {"list_path": sorce_path,
        #                                  "batch_size": args.batch_size}, \
        #                       "target": {"list_path": target_path,
        #                                  "batch_size": args.batch_size}, \
        #                       "test": {"list_path": target_path,
        #                                "batch_size": args.batch_size}}
        train_test(config)
    else:
        print("GG")
        print("Please choose the correct task")
