#!/bin/bash
# Erik Wessels, Colin Davenport Jan 2020
# Check window coverage on Wochenende sorted dup.bam output
# Use for Python script to check coverage distribution

for i in *dup.bam; do
	input=$i
	sec_input=${input%%.bam}
	#sec_in_bam=${input%%.bam}

	window=100000
	overlap=50000
	covMax=999999999
	threads=8
	queue=short

	# Sort - coo means coordinate sorting
        #sambamba sort $input -o ${sec_input}_coo.bam

	# Get coverage depth in windows
	# 8 threads, Windows 100000, overlap 50000, -c minimum coverage. 
	# SLURM
	srun -c $threads -p $queue sambamba depth window -t $threads --max-coverage=$covMax --window-size=$window --overlap $overlap -c 0.00001 ${sec_input}.bam > ${sec_input}_cov_window.txt &

	# Direct submission, not SLURM
	#sambamba depth window -t $threads --max-coverage=$covMax --window-size=$window --overlap $overlap -c 0.00001 ${sec_input}.bam > ${sec_input}_cov_window.txt &

	# if using sorting step _coo from above
	#srun -c 8 sambamba depth window -t 8 -w 10000 --overlap=5000 -c 0.00001 ${sec_input}_coo.bam > ${sec_input}_cov_window.txt

done

sleep 1500

#sambamba sort Sample2_S2_R1_001.ndp.lc.trm.s.mq30.01mm.dup_Prevotella_jejuni_reads.bam -o Sample2_S2_R1_001.ndp.lc.trm.s.mq30.01mm.dup_Prevotella_jejuni_reads_coo.bam
#sambamba depth window -t 8 -w 100000 --overlap=5000 Sample2_S2_R1_001.ndp.lc.trm.s.mq30.01mm.dup_Prevotella_jejuni_reads_coo.bam > Sample2_S2_R1_001.ndp.lc.trm.s.mq30.01mm.dup_Prevotella_jejuni_reads_coo_window.bam
