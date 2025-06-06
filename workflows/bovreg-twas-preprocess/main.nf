#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { preprocess } from './bovreg_preprocess_main.nf'

workflow {
  preprocess()
}

