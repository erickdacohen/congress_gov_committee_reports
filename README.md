# IARPC Congress.gov Committee Reports

Scripts to collect PDF committee reports from congress.gov relating to the arctic. Intended for use with [ktrain](https://github.com/amaiya/ktrain).

## Python Notebooks

1. acquire_comittee_reports_pdf.ipynb

This notebook takes an excel document downloaded from [Congress.gov](https://www.congress.gov/search?q={%22source%22:%22comreports%22}&searchResultViewType=expanded) and downloads the corresponding PDFs of the committee reports if available. The file is downloaded when pressing the _download results_ button. It may take hours to run.

It was intended to be used with ktrain's end-to-end question answering capability

2. arctic_eeqa.ipynb

This notebook takes the outputs from the _acquire_comittee_reports_pdf.ipynb_ to ask questions of the committee reports

## R Scripts

1. acquire.R

This file scrapes the 122 performance elements from iarpc's member site and outputs the data in csv formats.
