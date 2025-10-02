#!/bin/bash
#SBATCH --job-name=Copepod_Voronoi
#SBATCH --ntasks=16
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

# year=2016
# run for single notebook and put into background
for year in {2016..2024}; do
        for site in {0..27}; do
                mkdir -p output/VoronoiConnectivity/${year}/
                mkdir -p notebooks_executed/VoronoiConnectivity/${year}/
                srun --ntasks=1 --exclusive -c 2 singularity run -B /sfs -B /gxfs_work -B $PWD:/work --pwd /work parcels-container_2024.10.07-7af7fd0.sif bash -c \
                ". /opt/conda/etc/profile.d/conda.sh && conda activate base \
                && papermill --cwd notebooks/ \
                        notebooks/SiteConnectivityVoronoi.ipynb \
                        notebooks_executed/VoronoiConnectivity/${year}/Copepods_VoronoiConnectivity_${year}_s${site}.ipynb \
                        -p site ${site} \
                        -p year ${year} \
                        -p isPapermill True \
                        -k python" &
        done
done

    
# wait till background task is done
wait

# print resource infos
jobinfo
