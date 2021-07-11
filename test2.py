import os
root = 'D:\lab\\radar_script\\raw_data\experiments'
root2 = 'D:\lab\\radar_script\\raw_data\experiments'
# root2 = 'E:\experiments\\'
dirs=os.listdir(os.path.join(root,'guxiang'))
n = 'fck3'
for dir in dirs:
    if not os.path.exists(os.path.join(root2,n)):
        os.mkdir(os.path.join(root2,n))
    path = os.path.join(root2,n,dir)
    if not os.path.exists(path):
        os.mkdir(path)