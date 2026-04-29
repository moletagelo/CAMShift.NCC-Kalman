# Data Setup

This repository expects an OTB-style directory layout, but does not track dataset files in Git.

## Expected Layout

```text
data/
  otb/
    Football/
      groundtruth_rect.txt
      img/
        0001.jpg
        0002.jpg
        ...
  raw/
```

## Defaults Used By The Project

- Dataset root: `data/otb`
- Sequence name: `Football`
- Image extension: `.jpg`
- Annotation file: `groundtruth_rect.txt`

## Local Workflow

- Put downloaded archives in `data/raw/`
- Extract the sequence into `data/otb/Football/`
- Keep `data/raw/` and `data/otb/` local only; both are ignored by Git

## Validation

The main scripts check that the sequence folder, image folder, and annotation file all exist before running.

