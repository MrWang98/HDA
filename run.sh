#kinds=(35cm 50cm 65cm 80cm 15d 30d 45d 60d 15h 30h down left right)
kinds=(35cm)
persons=(guxiang)

gpu_id=0

for person in ${persons[@]}
do
  #判断日志文件夹是否存在
  if [ ! -d "log/${person}" ];then
    mkdir log/${person}
  fi

  #每一类作为一个任务进行提交
  for kind in ${kinds[@]}
  do
    #尝试提交任务，最多尝试20次，成功后将flag置1
    flag=0
    count=0
    while [ ${count} -lt 20 ]
    do
      count=`expr ${count} + 1`
      sbatch test.slurm ${person} ${kind} ${gpu_id}
      if [ $? -eq 0 ]
      then
        flag=1
        break
      fi
    done

    #显示是否成功提交任务
    if [ ${flag} -eq 0 ]
    then
      echo "${person} ${kind} submit failed"
    fi
  done
done