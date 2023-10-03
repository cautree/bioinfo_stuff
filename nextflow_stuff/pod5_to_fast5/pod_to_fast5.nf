
params.dev = true
params.run = "20230926"
params.analysis = "pod5-to-fast5"

if(params.dev) { 
   path_s3 = "seqwell-dev/analysis"
} else { 
   path_s3 = "seqwell-analysis"
}



process pod5_to_fast5 {


publishDir path: "s3://$path_s3/$params.run/$params.analysis/fast5"
//publishDir path: "fast5", mode: "copy"



input:
tuple val(sample_id), path(pod5)

output:
tuple val(sample_id), path("*.fast5")

"""
pod5 convert to_fast5 $pod5 --output ${sample_id}.fast5  --file-read-count 100000
cp */*.fast5  . 
rm -r */
"""


}

workflow {

pod_files = Channel
            .fromPath("s3://seqwell-ont/20230926/pod5_pass/*/*pod5")
            .map{ it -> tuple( it.baseName.tokenize(".")[0], it)}

pod5_to_fast5(pod_files)
}
