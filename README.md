<div align="center">

# 🔍 Object Depth Estimation via Correlation Filter & VCR

**Sensor-Free 3D Depth Recovery from 2D Imagery — MATLAB**

[![EN](https://img.shields.io/badge/Language-English-blue?style=flat-square)](#-english)
[![KR](https://img.shields.io/badge/언어-한국어-red?style=flat-square)](#-한국어)

</div>

---

## 🇺🇸 English

A MATLAB-based solution that estimates precise object depth from 2D imagery by combining a **Correlation Filter** for target localization with **Volumetric Computational Reconstruction (VCR)** for 3D scene recovery — no additional depth sensors required.

### 📋 Project Overview

Moving beyond conventional 2D image processing, this project applies **VCR** — a core algorithm in integral-imaging and light-field systems — to computationally reconstruct 3D volumes from multi-view input, then uses correlation filtering to identify the optimal focal plane for each target. The intersection of these two techniques yields reliable depth estimates purely from imagery.

- **Role:** Sole developer — algorithm design and implementation
- **Core Contribution:** Fusion of correlation-based object localization and VCR-based depth map generation
- **Publication Context:** Part of the author's broader 3D reconstruction research line (ITC-CSCC 2025, accepted)

### 🛠 Tech Stack

| Layer | Technology |
|---|---|
| **Language** | MATLAB |
| **Key Algorithms** | Correlation Filter, Volumetric Computational Reconstruction (VCR) |
| **Signal Processing** | FFT-based frequency-domain correlation |

### ✨ Key Implementations

#### 1. Correlation-Filter-Based Target Tracking
- **Frequency-Domain Analysis** — Performed correlation operations in the frequency domain via FFT, dramatically reducing computational cost compared to spatial-domain convolution.
- **Robust Localization** — Implemented pattern recognition logic that isolates the target from background noise and tracks its centroid with sub-pixel precision.

#### 2. Volumetric Computational Reconstruction (VCR)
- **Depth Slicing** — Reconstructed imagery at multiple z-plane depths to enable per-plane sharpness analysis of candidate object locations.
- **3D Reconstruction** — Applied the shift-and-add principle to pixel-level data from multi-view input, computationally recovering the full volumetric representation of the scene.

#### 3. Depth Estimation Logic
- **Peak-to-Sidelobe Ratio (PSR)** — Analyzed the correlation filter's response strength at every reconstructed depth plane to quantify focus confidence.
- **Focus-Measure Optimization** — Identified the depth plane at which PSR peaks and assigned it as the object's estimated true depth, yielding a principled optimization criterion.

### 💡 Technical Achievements

- **Sensor-Free Depth Estimation** — Established a computational foundation for estimating object distance without LiDAR, stereo rigs, or structured-light hardware.
- **Cross-Domain Algorithm Design** — Successfully fused two distinct fields — signal processing (correlation) and optical reconstruction (VCR) — into a single coherent pipeline that improved overall accuracy.
- **Research Pipeline Foundation** — Served as the algorithmic groundwork for subsequent 3D reconstruction research, including the ITC-CSCC 2025 accepted paper.

<div align="right"><a href="#-한국어">🇰🇷 한국어로 보기 ↓</a></div>

---

## 🇰🇷 한국어

영상 내 객체의 위치를 추적하는 **상관 필터(Correlation Filter)**와 3D 정보를 복원하는 **VCR(Volumetric Computational Reconstruction)** 알고리즘을 결합하여, 추가 깊이 센서 없이 2D 이미지만으로 객체의 정밀 깊이 정보를 추정하는 MATLAB 기반 솔루션입니다.

### 📋 프로젝트 개요

단순 2D 영상 처리를 넘어, 집적 영상(Integral Imaging) 및 라이트 필드(Light Field) 기술의 핵심 알고리즘인 **VCR**을 활용해 다중 시점 입력으로부터 3D 볼륨을 계산적으로 재구성합니다. 이후 상관 필터링으로 각 타겟의 최적 초점 평면을 식별하여, 영상 정보만으로 신뢰도 있는 깊이값을 산출합니다.

- **역할:** 1인 개발 — 알고리즘 설계 및 구현
- **핵심 기여:** 상관 기반 객체 국지화와 VCR 기반 깊이 맵 생성의 결합
- **연구 연속성:** 저자의 3D Reconstruction 연구 라인의 일부 (ITC-CSCC 2025 Accepted)

### 🛠 기술 스택

| 계층 | 기술 |
|---|---|
| **언어** | MATLAB |
| **핵심 알고리즘** | Correlation Filter, Volumetric Computational Reconstruction (VCR) |
| **신호 처리** | FFT 기반 주파수 영역 상관 연산 |

### ✨ 주요 구현

#### 1. 상관 필터 기반 타겟 추적
- **주파수 영역 분석** — FFT(고속 푸리에 변환)를 활용해 상관 연산을 주파수 영역에서 수행함으로써, 공간 영역 컨볼루션 대비 연산 비용을 크게 절감했습니다.
- **강건한 국지화** — 배경 노이즈 속에서 타겟 패턴을 식별하고 중심 좌표를 sub-pixel 정밀도로 추적하는 로직을 구현했습니다.

#### 2. VCR (Volumetric Computational Reconstruction)
- **Depth Slicing** — 다양한 깊이 평면(z-plane)에서 영상을 재구성하여, 후보 객체 위치별 선명도를 분석할 수 있도록 했습니다.
- **3D 재구성** — 다중 시점 입력의 픽셀 데이터에 Shift-and-Add 원리를 적용하여 공간 상의 볼륨 데이터를 계산적으로 복원했습니다.

#### 3. 깊이 추정 알고리즘
- **Peak-to-Sidelobe Ratio (PSR)** — 재구성된 각 깊이 평면에서 상관 필터의 응답 강도를 분석하여 초점 신뢰도를 정량화했습니다.
- **Focus-Measure 최적화** — PSR이 최대가 되는 지점을 해당 객체의 실제 깊이값으로 결정하는 원리 기반 최적화 기준을 구현했습니다.

### 💡 주요 성과

- **비접촉·비센서 깊이 추정** — LiDAR, 스테레오 리그, 구조광 같은 추가 하드웨어 없이 연산만으로 객체 거리를 추정하는 기술적 기반을 마련했습니다.
- **분야 간 알고리즘 설계** — 신호 처리(Correlation)와 광학 재구성(VCR)이라는 서로 다른 두 영역을 하나의 일관된 파이프라인으로 결합하여 시스템 정확도를 향상시켰습니다.
- **연구 파이프라인의 기반** — 이후 3D Reconstruction 연구 — ITC-CSCC 2025 Accepted 논문을 포함 — 의 알고리즘적 토대가 되었습니다.

<div align="right"><a href="#-english">🇺🇸 View in English ↑</a></div>
