
// https://gencore.bio.nyu.edu/three-useful-nextflow-patterns-every-computational-biologist-should-know/

params.dev = false
params.number_of_inputs = 2
Channel
    .from(1..300)
    .take( params.dev ? params.number_of_inputs : -1 )
    .view() 