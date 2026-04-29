# Experiment Report

## Scope

This report summarizes the current local run of the tracking project on the `Football` sequence using two trackers:

- `KCF`
- `Improved CAMShift` based on grayscale `NCC + Kalman`

## Runtime Environment

- MATLAB `R2024b`
- Image Processing Toolbox
- Computer Vision Toolbox

## Evaluation Metrics

- `CLE`: center location error
- `IoU`: overlap ratio
- `Precision@20`: fraction of frames with center error within 20 pixels
- `AUC`: area under the success curve
- `FPS`: average runtime throughput estimated from per-frame timing

## Current Result Summary

| Method | Precision@20 | AUC | Mean CLE | Mean IoU | FPS |
|---|---:|---:|---:|---:|---:|
| KCF | 0.7983 | 0.6082 | 12.5876 | 0.6083 | 250.99 |
| Improved CAMShift | 0.2873 | 0.1810 | 169.1677 | 0.1647 | 306.34 |

## Observations

- `KCF` is clearly stronger on this sequence in both location accuracy and overlap stability.
- The improved `CAMShift` pipeline runs successfully and maintains the intended grayscale `NCC + Kalman` structure, but its tracking quality is much lower on this benchmark.
- The comparison trend is aligned with the expected outcome for this repository: `KCF` should outperform the improved `CAMShift` variant on the default sequence.

## Tracked Preview Figures

### KCF Precision

![KCF Precision](../assets/figures/comparison_kcf_precision.png)

### KCF Success

![KCF Success](../assets/figures/comparison_kcf_success.png)

### Improved CAMShift Precision

![Improved CAMShift Precision](../assets/figures/comparison_improved_camshift_precision.png)

### Improved CAMShift Success

![Improved CAMShift Success](../assets/figures/comparison_improved_camshift_success.png)

## Reproducibility

Run the following from the repository root in MATLAB:

```matlab
main_KCF_tracking
main_improved_CAMshift_tracking
main_algorithm_comparison
```

Generated local outputs are written under `results/`, which is ignored by Git by default.

