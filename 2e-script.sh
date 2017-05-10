#!/bin/bash

size_ko=1024
size_mo=1048576
size_go=1073741824

path=`cut -d: -f1,3,6 /etc/passwd | egrep :[0-9]{4}: | cut -d: -f3`
user=`cut -d: -f1,3 /etc/passwd | egrep :[0-9]{4}$ | cut -d: -f1`

count=0

for value in $user
do
	name[$count]=$value
	count=$((count+1))
done

count=0

for value in $path
do
	total=`du -bs $value | cut -f1`
	compare[$count]=$total
	goo=$((total / size_go))
	total=$((total - $((goo * size_go))))
	moo=$((total /size_mo))
	total=$((total - $((moo * size_mo))))
	koo=$((total / size_ko))
	total=$((total - $((koo * size_ko))))
	go[$count]=$goo
	mo[$count]=$moo
	ko[$count]=$koo
	o[$count]=$total
	route[$count]=$value

	count=$((count+1))
done

count=$((count-1))

# --- Tri --- #

for i in `seq 0 $((count - 1))`
do
	for j in `seq $((i+1)) $count`
	do
		if [ ${compare[$j]} -lt ${compare[$i]} ]
		then

			swap=${name[$i]}
			name[$i]=${name[$j]}
			name[$j]=$swap
			swap=${go[$i]}
			go[$i]=${go[$j]}
			go[$j]=$swap
			swap=${mo[$i]}
			mo[$i]=${mo[$j]}
			mo[$j]=$swap
			swap=${ko[$i]}
			ko[$i]=${ko[$j]}
			ko[$j]=$swap
			swap=${o[$i]}
			o[$i]=${o[$j]}
			o[$j]=$swap
			swap=${route[$i]}
			route[$i]=${route[$j]}
			route[$j]=$swap
			swap=${compare[$i]}
			compare[$i]=${compare[$j]}
			compare[$j]=$swap
		fi
	done
done

# --- Affichage --- #

i=0
echo "Liste des plus gros consommateurs : " >> /etc/motd

while [ $i -le 4 ]
do
	j=$((count-i))
	echo "${name[$j]} => ${go[$j]}Go, ${mo[$j]}Mo, ${ko[$j]}Ko et ${o[$j]}octets" >> /etc/motd
	i=$((i+1))
done
echo "                                    " >> /etc/motd

for i in `seq 0 $count`
do
	path="${route[$i]}/.bashrc"
	line_nb=`grep -n "echo \"Votre dossier fait : " $path | cut -d: -f1`
	echo $path
	echo $line_nb

	if ! [ -z $line_nb ]
	then
		line_nb=$line_nb"d"
		sed $line_nb $path > delete_me
		mv delete_me $path
	fi

	if [ ${mo[$i]} -ge 100 ]
	then
		echo "echo \"Votre dossier fait : ${go[$i]}Go, ${mo[$i]}Mo, ${ko[$i]}Ko et ${o[$i]} octets, Attention vous etes au dessus de la limite\"" >> $path
	else
		echo "echo \"Votre dossier fait : ${go[$i]}Go, ${mo[$i]}Mo, ${ko[$i]}Ko et ${o[$i]} octets\"" >> $path
	fi
done