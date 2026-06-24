#!/bin/bash
#SBATCH --job-name=connectivity_original_locations
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=80G
#SBATCH --time=4:00:00
#SBATCH --partition=base



# make sure we have Singularity
module load gcc12-env/12.3.0
module load singularity/3.11.5

# to get the image (need to be on a partition which has internet access --> data), run
# $ singularity pull --disable-cache --dir "${PWD}" docker://quay.io/willirath/parcels-container:2024.10.07-7af7fd0

# make sure the output exists
mkdir -p notebooks_executed/

# run for single notebook and put into background
# for year in {2024}; do
year=2024
north_sea_locations='original'
for site in {1..27}; do
        mkdir -p notebooks_executed/connectivity_orignal/${year}/
        srun --ntasks=1 --nodes=1 --exclusive -c 2 singularity run -B /sfs -B /gxfs_work -B $PWD:/work --pwd /work parcels-container_2024.10.07-7af7fd0.sif bash -c \
        ". /opt/conda/etc/profile.d/conda.sh && conda activate base \
        && papermill --cwd notebooks/ \
                notebooks/SiteConnectivityVoronoi.ipynb \
                notebooks_executed/connectivity_orignal/${year}/connectivity_${north_sea_locations}_${year}_s${site}.ipynb \
                -p site ${site} \
                -p year ${year} \
                -p north_sea_locations ${north_sea_locations} \
                -p isPapermill True \
                -k python" &
done
    
# wait till background task is done
wait

# print resource infos
jobinfo
