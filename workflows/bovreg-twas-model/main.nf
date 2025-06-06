#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { model } from './bovreg_model_main.nf'

workflow {
  model()
}

