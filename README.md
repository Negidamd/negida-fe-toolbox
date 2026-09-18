# negida-fe-toolbox
[![Version](https://img.shields.io/badge/version-1.1.0-blue)](CHANGELOG.md)

MATLAB toolbox for dominant frequency-based EEG feature extraction in Lewy body disease patients.

**Frequency Extraction (FE) Toolbox for EEG Analysis**

## Overview
FE-Toolbox is a MATLAB-based toolbox for extracting the dominant-frequency EEG
features, including:
- Dominant Frequency (DF)
- Dominant Frequency Variability (DFV)
- Dominant Frequency Prevalence (DFP)
- Individual Alpha Frequency (IAF)
- Absolute and relative band power

The toolbox is optimized for EEG slowing and pre-alpha analysis in
neurodegenerative disorders.

## Frequency Bands
The power spectrum is divided into the following bands:
- Delta: 3.0–3.5 Hz
- Theta: 4.0–5.5 Hz
- Pre-alpha: 6.0–7.5 Hz
- Alpha: 8.0–12.0 Hz

Band limits are editable in the GUI. The GUI also offers Beta (13–30 Hz) and
Gamma (30–45 Hz); these lie outside the 3–14 Hz filter and are reported as NaN
whenever that filter is applied.

## Method
- Spectra are computed per channel and epoch with a Hamming window on a
  0.5 Hz frequency grid (2-s segments). Epochs longer than 2 s are split into
  2-s segments with 50% overlap and averaged (Welch), so the whole epoch is
  used. Shorter epochs are zero-padded to the same grid.
- **DF**: frequency of maximum power in each epoch, searched within the filter
  passband (3–14 Hz when the GUI filter is applied).
- **DFV**: standard deviation of DF across epochs (`Overall` column), and of
  the within-band peak frequency for each band.
- **DFP**: percentage of epochs whose DF falls in each band. Epochs whose DF
  falls in no band (for example 12.5–14 Hz) are counted in an `Other` column,
  so each row sums to 100%.
- **Relative power**: band power as a percentage of the total power summed
  over all valid bands, from the epoch-averaged spectrum.
- **IAF**: peak and centre-of-gravity frequency of the epoch-averaged spectrum
  within 7–13 Hz.
- Continuous (non-epoched) datasets are cut into non-overlapping 2-s epochs.

## Usage
### GUI
Run `FE_Toolbox`, load one or more EEGLAB `.set` files, choose an output
folder, tick the outputs you want, and press Run. You will be asked whether to
apply a 3–14 Hz band-pass filter; choose **No** if your data are already
filtered, so they are not filtered twice.

Each ticked output is written to its own workbook with one sheet per subject.
`EEG_Results_Summary.xlsx` (always written) lists, for every subject and
channel, the number of epochs, mean DF, DFV and IAF.

### Scripted
```matlab
EEG = pop_loadset('S001.set');
EEG = pop_eegfiltnew(EEG, 'locutoff', 3, 'hicutoff', 14);
R = fe_extract(EEG, 'Passband', [3 14]);
R.DF          % channels x epochs
R.RelPow      % channels x bands (%)
fe_write_results(R, 'S001', outDir, struct('DF', true, 'DFV', true));
```
`fe_extract` also accepts a numeric `[channels x samples x epochs]` array:
`fe_extract(data, Fs, ...)`. See `help fe_extract` for all options.

## Preprocessing
EEG data should be preprocessed before using this toolbox for feature extraction.
It is recommended that EEG data are band-pass filtered at 3–14 Hz before feature extraction.

## Requirements
- MATLAB R2020a or later
- EEGLAB (for loading `.set` files and filtering; the firfilt plugin provides
  `pop_eegfiltnew`)

## Testing
```matlab
addpath(pwd); results = runtests('tests/test_fe_toolbox.m')
```
The tests use synthetic EEG with known answers. The end-to-end GUI test runs
when EEGLAB is on the path or its folder is set in the `EEGLAB_PATH`
environment variable.

## License
© 2026 Ahmed Negida  
Released under CC BY-NC-ND 4.0 (see LICENSE)

## Publication
This toolbox was used to extract the EEG features reported in:

Negida A, Lageman SK, Ono K, Ahsan M, Mukhopadhyay N, Barrett MJ.
**Resting-state EEG features of cognitive fluctuations across the Lewy body
disease spectrum.** *Alzheimer's Research & Therapy*. 2026.
[doi:10.1186/s13195-026-02148-8](https://doi.org/10.1186/s13195-026-02148-8)

## Citation
If you use this toolbox, please cite the publication above and the software
(see CITATION.cff).
