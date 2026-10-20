# Depth estimation with correlation filters and VCR

[![tests](https://github.com/zoocasso/depth-estimation-using-vcr-algorithm-matlab/actions/workflows/ci.yml/badge.svg)](https://github.com/zoocasso/depth-estimation-using-vcr-algorithm-matlab/actions/workflows/ci.yml)

[English](#english) · [한국어](#한국어)

## English

A 2022 course project in MATLAB: find how far an object is from an integral-imaging camera array, using only the images. The scene is reconstructed at many depths with volumetric computational reconstruction (VCR); the object is sharp only at its own depth, so the depth where a reference image of the object correlates best is its estimated depth. This is where my master's research on VCR started ([origin point optimization](https://github.com/zoocasso/origin-point-optimization-vcr)).

The code was cleaned up and rewritten in October 2026; the reconstructions in [`results/`](results/) are from the 2022 runs.

### How it works

| File | Step |
|---|---|
| [`vcr_shifts.m`](vcr_shifts.m) | Pixel offset of every elemental image at a depth $z$. The ideal shift between neighbours is $S = N f p / (c z)$, but images sit on whole pixels: **fixed** VCR reuses one rounded step, $k \cdot \mathrm{round}(S)$, so the error grows with $k$; **nonuniform** VCR rounds each image, $\mathrm{round}(kS)$. |
| [`vcr_reconstruct.m`](vcr_reconstruct.m) | Places the images at those offsets and averages the overlaps. Images are read one at a time, so a 10 × 10 set of 3008 × 2000 images never has to fit in memory. |
| [`correlation_peaks.m`](correlation_peaks.m) | Correlation peak of a reference target in a reconstruction, by FFT: linear (matched) filter, phase-only filter and nonlinear filter, each divided by the reference's autocorrelation peak. |
| [`estimate_depth.m`](estimate_depth.m) | Reconstructs at every candidate depth and returns the depth with the highest peak. |

### Run

```matlab
example_three_characters   % needs the data set in data/Three_Characters (not in the repository)
```

Tests run in MATLAB or GNU Octave on synthetic scenes, including a target whose true depth the estimate has to recover:

```bash
octave --eval "addpath(pwd); addpath(fullfile(pwd, 'tests')); run_tests"
```

### Results

[`results/fixed/`](results/fixed/) and [`results/nonuniform/`](results/nonuniform/) hold the 2022 reconstruction sweeps as videos: the Three Characters scene (3008 × 2000 px per image, 400–1000 mm) and a car scene at two resolutions (3072 × 2048 and 1536 × 1024 px, 200–500 mm). The slides are in [`docs/slides.pdf`](docs/slides.pdf).

## 한국어

2022년 수업 프로젝트(MATLAB)입니다. 집적 영상 카메라 배열로 찍은 영상만으로 물체까지의 거리를 구합니다. 체적 컴퓨터 재생(VCR)으로 여러 깊이에서 장면을 재구성하면 물체는 자기 깊이에서만 선명해지므로, 물체의 기준 영상과 상관이 가장 높은 깊이를 추정 깊이로 정합니다. 지금 석사 연구([원점 최적화](https://github.com/zoocasso/origin-point-optimization-vcr))의 출발점입니다.

코드는 2026년 10월에 정리해 다시 썼고, [`results/`](results/)의 재구성 결과는 2022년에 돌린 것입니다.

- **`vcr_shifts.m`**: 깊이별 요소 영상 이동량. fixed VCR은 반올림한 한 걸음을 반복하고(오차가 k에 비례해 커짐), nonuniform VCR은 영상마다 따로 반올림합니다.
- **`vcr_reconstruct.m`**: 이동한 영상을 겹쳐 평균합니다. 영상을 한 장씩 읽어서 3008 × 2000 영상 100장도 메모리에 한꺼번에 올리지 않습니다.
- **`correlation_peaks.m`**: FFT로 선형·위상 전용·비선형 상관 필터의 피크를 구하고, 기준 영상의 자기상관 피크로 나눕니다.
- **`estimate_depth.m`**: 후보 깊이마다 재구성해 피크가 가장 높은 깊이를 돌려줍니다.
- **테스트**: MATLAB과 GNU Octave 모두에서 돌고, 참 깊이를 아는 합성 장면에서 그 깊이를 찾는지 확인합니다.
