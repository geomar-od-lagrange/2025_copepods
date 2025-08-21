#!/bin/bash
#SBATCH --job-name=Copepod_Pelagic
#SBATCH --ntasks=10
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=60G
#SBATCH --time=24:00:00
#SBATCH --partition=base


# make sure we have Singularity
module load gcc12-env/12.3.0
module load singularity/3.11.5

# to get the image (need to be on a partition which has internet access --> data), run
# $ singularity pull --disable-cache --dir "${PWD}" docker://quay.io/willirath/parcels-container:2024.10.07-7af7fd0

# make sure the output exists
mkdir -p notebooks_executed/

# run for single notebook and put into background
for site in {0..15}; do
        for year in {2016..2017}; do
        mkdir -p notebooks_executed/PelagicConnectivity/${year}/
        srun --ntasks=10 --exclusive singularity run -B /sfs -B /gxfs_work -B $PWD:/work --pwd /work parcels-container_2024.10.07-7af7fd0.sif bash -c \
        ". /opt/conda/etc/profile.d/conda.sh && conda activate base \
        && papermill --cwd notebooks/ \
                notebooks/SiteConnectivityPelagic.ipynb \
                notebooks_executed/PelagicConnectivity/${year}/Copepods_Comparison_Pelagic_${year}_s${site}.ipynb \
                        -p year ${year} \
                        -p start_site_counter ${site} \
                        -p isPapermill True \
                -k python" &
        done
done

    

# wait till background task is done
wait

# print resource infos
jobinfo
