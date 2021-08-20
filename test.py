import zipfile
import os
def creat(p_root):
    files=os.listdir(p_root)
    all_s=os.path.join(p_root,'all_s.txt')
    all_t=os.path.join(p_root,'all_t.txt')
    for file in files:
        name=file.split('.')[0]
        name=name.split('_')
        if len(name)>1:
            if name[-1]=='s':
                with open(all_s,'a') as f:
                    with open(os.path.join(p_root,file)) as f1:
                        lines=f1.readlines()
                    f.writelines(lines)
            if name[-1]=='t':
                with open(all_t,'a') as f:
                    with open(os.path.join(p_root,file)) as f1:
                        lines=f1.readlines()
                    f.writelines(lines)

if __name__=='__main__':
    root = 'data/DATA'
    persons=os.listdir(root)
    for person in persons:
        p_root=os.path.join(root,person)
        creat(p_root)
