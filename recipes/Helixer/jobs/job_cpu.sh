#!/bin/bash
#PBS -l select=1:ncpus=1:mem=30gb:arch=skylake
#PBS -l walltime=12:59:00
#PBS -A "HelixerOpt"
set -e

## Log-File definieren
export LOGFILE=$PBS_O_WORKDIR/$PBS_JOBNAME"."$PBS_JOBID".log"

##Scratch-Laufwerk definieren und erzeugen
SCRATCHDIR=/scratch_gs/$USER/$PBS_JOBID
mkdir -p "$SCRATCHDIR"

##Information zum Start in das Log-File schreiben
cd $PBS_O_WORKDIR
echo "$PBS_JOBID ($PBS_JOBNAME) @ `hostname` at `date` in "$RUNDIR" START" > $LOGFILE
echo "`date +"%d.%m.%Y-%T"`" >> $LOGFILE

##Software-Umgebung laden
module load Python/3.6.5

##Daten vom Arbeitsverzeichnis auf das Scratch-Laufwerk kopieren
cp -r $PBS_O_WORKDIR/* $SCRATCHDIR/.
cd $SCRATCHDIR
rm $PBS_JOBNAME"."$PBS_JOBID".log"

##Aufruf
rm -r /scratch_gs/festi100/data/all_genomes_full/h5_data_10k/*; /home/festi100/git/HelixerPrep/export.py --db-path-in /scratch_gs/festi100/full_geenuff.sqlite3 --out-dir /scratch_gs/festi100/data/all_genomes_full/h5_data_10k --chunk-size 10000 --exclude-genomes Dsalina

##Daten zurück kopieren
cp -r "$SCRATCHDIR"/* $PBS_O_WORKDIR/.
cd $PBS_O_WORKDIR

##Verfügbare Informationen zum Auftrag in das Log-File schreiben
echo >> $LOGFILE
qstat -f $PBS_JOBID >> $LOGFILE

echo "$PBS_JOBID ($PBS_JOBNAME) @ `hostname` at `date` in "$RUNDIR" END" >> $LOGFILE
echo "`date +"%d.%m.%Y-%T"`" >> $LOGFILE
