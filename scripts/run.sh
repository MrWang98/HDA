#kinds=(35cm 50cm 65cm 80cm 15d 30d 45d 60d 15h 30h down left right)
kinds=(15d 30d 30h down left right)
persons=(fck)
cur=`pwd`
echo $cur
gpu_id=1
count=0
for person in ${persons[@]}
do
  for kind in ${kinds[@]}
  do
    path="$cur/scripts/run_test.sh"
#    path="$cur/scripts/test.sh"
    gpu_id=`expr $gpu_id % 2`
    nohup bash ${path} ${person} ${kind} ${gpu_id} > "result/${person}/${kind}.txt" &
    sleep 20
#    gpu_id=`expr $gpu_id + 1`
    count=`expr $count + 1`
    if [ $count -eq 2 ]
    then
      count=0
      sleep 5400
#      echo "$count"
    fi
  done
done