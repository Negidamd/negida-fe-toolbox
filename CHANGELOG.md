# Changelog

## 1.1.0

### New features
- **Individual alpha frequency (IAF)**: peak and centre-of-gravity frequency
  of the epoch-averaged spectrum (7–13 Hz).
- **Scripted interface**: `fe_extract` and `fe_write_results` run the full
  feature extraction without the GUI, for batch pipelines.
- **Summary workbook**: `EEG_Results_Summary.xlsx` lists the number of epochs,
  mean DF, DFV and IAF for every subject and channel.
- **Any montage**: output rows use the dataset's own channel labels, for any
  number of channels.
- **Continuous recordings**: non-epoched datasets are cut into 2-s epochs
  automatically.
- **Optional filtering**: the GUI asks whether to apply the 3–14 Hz
  band-pass filter, so pre-filtered data are not filtered twice.
- **Test suite**: `tests/test_fe_toolbox.m` checks every feature on synthetic
  EEG with known answers, plus an end-to-end GUI run through EEGLAB.
- `CITATION.cff` and a link to the associated publication.

### Improvements
- **Spectral estimation**: the whole epoch contributes to the spectrum.
  Epochs longer than 2 s are averaged over 2-s Hamming segments with 50%
  overlap (Welch). The 2-s spectrum and 0.5 Hz frequency grid are unchanged.
- **Relative power**: band power is integrated from the power spectral
  density and expressed as a percentage of total power across the analysed
  bands, so values sum to 100%.
- **DF search range**: the dominant frequency is searched within the filter
  passband (3–14 Hz), so epochs are not assigned to residual activity at the
  filter edges.
- **DFV**: an overall DFV (SD of DF across epochs) is reported alongside the
  band-wise values, and each subject is processed independently of the others
  in a batch.
- **DFP**: a new `Other` column counts epochs whose DF falls in no band, so
  each row sums to 100%.
- **Frequency bands**: bands outside the filter passband (Beta, Gamma when
  the 3–14 Hz filter is applied) are reported as NaN, with a warning.
- **Usability**: single-file selection, clearer messages when no input or
  output folder is chosen, band-limit validation, every output can be selected
  on its own, and re-running overwrites existing result sheets.
- **Dependencies**: the Signal Processing Toolbox is no longer required, and
  EEGLAB is loaded without opening its main window.
