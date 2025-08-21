#!/bin/bash
#SBATCH --job-name=Copepod_dispersal
#SBATCH --ntasks=16
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=30G
#SBATCH --time=48:00:00
#SBATCH --partition=base


# make sure we have Singularity
module load gcc12-env/12.3.0
module load singularity/3.11.5

# to get the image (need to be on a partition which has internet access --> data), run
# $ singularity pull --disable-cache --dir "${PWD}" docker://quay.io/willirath/parcels-container:2024.10.07-7af7fd0

# make sure the output exists
mkdir -p notebooks_executed/

# run for single notebook and put into background
for year in {2016..2017}; do
    mkdir -p notebooks_executed/TrajectoryCalc/${year}/
    mkdir -p output/Trajectories/${year}/
    for site_counter in {0..15}; do
        srun --ntasks=1 --exclusive singularity run -B /sfs -B /gxfs_work -B $PWD:/work --pwd /work parcels-container_2024.10.07-7af7fd0.sif bash -c \
        ". /opt/conda/etc/profile.d/conda.sh && conda activate base \
        && papermill --cwd notebooks/ \
            notebooks/Copepods.ipynb \
            notebooks_executed/TrajectoryCalc/${year}/Copepods_${year}_site${site_counter}.ipynb \
            -p year ${year} \
            -p start_month 6 \
            -p start_day 1 \
            -p end_month 11 \
            -p end_day 1 \
            -p max_age_d 28 \
            -p dt_in_minutes 15 \
            -p output_dt_in_minutes 15 \
            -p site_counter ${site_counter} \
            -p number_particles 1000 \
            -p repeated_release True \
            -p repeatdt_d 1 \
            -p isPapermill True \
            -k python" &
    done
done
    

# wait till background task is done
wait

# print resource infos
jobinfo
