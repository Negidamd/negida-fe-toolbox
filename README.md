# negida-fe-toolbox
MATLAB toolbox for dominant frequency-based EEG feature extraction in Lewy body disease patients.

**Frequency Extraction (FE) Toolbox for EEG Analysis**

## Overview
FE-Toolbox is a MATLAB-based toolbox for extracting the dominant-frequency EEG
features, including:
- Dominant Frequency (DF)
- Dominant Frequency Variability (DFV)
- Dominant Frequency Prevalence (DFP)
- Individual Alpha Frequency (IAF)

The toolbox is optimized for EEG slowing and pre-alpha analysis in
neurodegenerative disorders.

## Frequency Bands
The power spectrum is divided into the following bands:
- Delta: 3.0–3.5 Hz
- Theta: 4.0–5.5 Hz
- Pre-alpha: 6.0–7.5 Hz
- Alpha: 8.0–12.0 Hz

EEG data should be preprocessed before using this toolbox for feature extraction.
It is recommnded that EEG data are band-pass filtered at 3–14 Hz before feature extraction.

## Requirements
- MATLAB R2020a or later
- EEGLAB (for preprocessing)

## License
© 2026 Ahmed Negida  
Released under CC BY-NC-ND 4.0 (see LICENSE)

## Citation
If you use this toolbox, please cite the associated manuscript and the
software DOI (see CITATION.cff).
