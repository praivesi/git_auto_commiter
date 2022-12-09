# $1 - master branch, $2 - stored commits branch

## redirect to log file

exec 3>&1 4>&2
exec 1>auto_commiter.log 2>&1


## master branch

git checkout $1
git pull origin $1

git log --pretty=oneline > output.txt
head -n 1 output.txt > output2.txt
latest_master_comm_msg=$(cut -c 42- output2.txt)

rm output.txt output2.txt

echo "latest_master_comm_msg = " $latest_master_comm_msg

## stored commits branch

git checkout $2
git pull origin $2

git log --pretty=oneline > output.txt

while read -r line
do
echo $line
echo $line > output2.txt
cut -c 42- < output2.txt > output3.txt
if [ "$(head -n 1 output3.txt)" = "$latest_master_comm_msg" ];
then
break
fi;
oldest_uncommit_info="$line"
done < output.txt

echo $oldest_uncommit_info > output4.txt
cut -c -40 output4.txt > oldest_hash.txt
cut -c 42- output4.txt > oldest_msg.txt

echo "oldest_uncommit_info = " $oldest_uncommit_info

oldest_hash=$(head -n 1 oldest_hash.txt)
oldest_msg=$(head -n 1 oldest_msg.txt)

echo "oldest_hash = " $oldest_hash
echo "oldest_msg = " $oldest_msg

rm output.txt output2.txt output3.txt output4.txt oldest_hash.txt oldest_msg.txt

## master branch

git checkout $1

git cherry-pick $oldest_hash
git reset HEAD~1
git add .
git restore --staged auto_commiter.sh auto_commiter.log

git commit -m "$oldest_msg"
git push origin $1

