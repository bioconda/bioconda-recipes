#!/bin/bash
#PBS -l select=1:ncpus=2:mem=10gb:ngpus=2:accelerator_model=gtx1080ti
#PBS -l walltime=20:59:00
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
pip3 install --user terminaltables

module load TensorFlow/1.10.0
module load Keras/2.2.4_python

##Daten vom Arbeitsverzeichnis auf das Scratch-Laufwerk kopieren
cp -r $PBS_O_WORKDIR/* $SCRATCHDIR/.
cd $SCRATCHDIR
rm $PBS_JOBNAME"."$PBS_JOBID".log"

##Aufruf
/home/festi100/git/HelixerPrep/helixerprep/prediction/LSTMModel.py -v -p 2 -e 10 -u 64 -bs 64 -lr 0.001 --bidirectional -fp float64 -d /scratch/festi100/four_genomes/h5_data_5k --gpus 2

##Daten zurück kopieren
cp -r "$SCRATCHDIR"/* $PBS_O_WORKDIR/.
cd $PBS_O_WORKDIR

##Verfügbare Informationen zum Auftrag in das Log-File schreiben
echo >> $LOGFILE
qstat -f $PBS_JOBID >> $LOGFILE

echo "$PBS_JOBID ($PBS_JOBNAME) @ `hostname` at `date` in "$RUNDIR" END" >> $LOGFILE
echo "`date +"%d.%m.%Y-%T"`" >> $LOGFILE
