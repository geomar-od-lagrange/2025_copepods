#!/bin/bash
#SBATCH --job-name=Copepod_Pelagic
#SBATCH --ntasks=10
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=50G
#SBATCH --time=24:00:00
#SBATCH --partition=base



# make sure we have Singularity
module load gcc12-env/12.3.0
module load singularity/3.11.5

# to get the image (need to be on a partition which has internet access --> data), run
# $ singularity pull --disable-cache --dir "${PWD}" docker://quay.io/willirath/parcels-container:2024.10.07-7af7fd0

# make sure the output exists
mkdir -p notebooks_executed/

year=2020
# run for single notebook and put into background
# for year in {2017..2020}; do
for site in {0..15}; do
        mkdir -p output/dispersal/${year}/
        mkdir -p notebooks_executed/dispersal/${year}/
        srun --ntasks=10 --exclusive singularity run -B /sfs -B /gxfs_work -B $PWD:/work --pwd /work parcels-container_2024.10.07-7af7fd0.sif bash -c \
        ". /opt/conda/etc/profile.d/conda.sh && conda activate base \
        && papermill --cwd notebooks/ \
                notebooks/SiteConnectivityPelagic.ipynb \
                notebooks_executed/dispersal/${year}/Copepods_dispersal_${year}_s${site}.ipynb \
                -p site ${site} \
                -p year ${year} \
                -p isPapermill True \
                -k python" &
done
# done

    
# wait till background task is done
wait

# print resource infos
jobinfo
