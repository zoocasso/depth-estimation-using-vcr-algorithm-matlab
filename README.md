# 🔍 Object Depth Estimation: Correlation Filter & VCR
> **Estimate object depth using Correlation Filter and Volumetric Computational Reconstruction (VCR) algorithm.**

이 프로젝트는 영상 내 객체의 위치를 추적하는 **상관 필터(Correlation Filter)**와 3D 정보를 복원하는 **VCR(Volumetric Computational Reconstruction)** 알고리즘을 결합하여, 단일 혹은 다중 이미지로부터 객체의 정밀한 깊이 정보를 추정하는 MATLAB 기반 솔루션입니다.

---

## 📋 프로젝트 개요 (Project Overview)
기존의 단순 영상 처리를 넘어, 집적 영상(Integral Imaging) 또는 라이트 필드(Light Field) 기술의 핵심인 VCR 알고리즘을 활용했습니다. 이를 통해 공간 상의 객체를 재구성하고, 상관 필터를 통해 타겟 객체의 최적 초점 평면(Focal Plane)을 찾아내어 정확한 깊이 데이터를 산출합니다.

* **역할:** 알고리즘 설계 및 구현 (Sole Developer)
* **핵심 기술:** 상관 필터링을 통한 객체 국지화 및 VCR 기반의 깊이 맵 생성

## 🛠 기술 스택 (Tech Stack)
* **Language:** MATLAB
* **Key Algorithms:** * Correlation Filter
  * Volumetric Computational Reconstruction (VCR)

## ✨ 주요 구현 특징 (Key Implementations)

### 1. 상관 필터 기반 타겟 추적 (Correlation Filter)
* **Frequency Domain Analysis:** FFT(고속 푸리에 변환)를 활용하여 주파수 영역에서 상관 연산을 수행, 연산 효율성을 극대화했습니다.
* **Localization:** 배경 노이즈 사이에서 특정 객체의 패턴을 인식하고 중심 좌표를 정밀하게 추적합니다.

### 2. VCR (Volumetric Computational Reconstruction)
* **Depth Slicing:** 다양한 깊이 평면(z-plane)에서 영상을 재구성하여 객체의 선명도를 분석합니다.
* **3.D Reconstruction:** 픽셀 이동 및 중첩(Shift-and-Add) 원리를 이용하여 공간 상의 볼륨 데이터를 계산적으로 복원합니다.

### 3. 깊이 추정 알고리즘 (Depth Estimation Logic)
* **Peak-to-Sidelobe Ratio (PSR):** 재구성된 각 평면에서의 상관 필터 응답값을 분석합니다.
* **Focus Measure:** PSR 수치가 최대가 되는 지점을 해당 객체의 실제 깊이값으로 추정하는 최적화 로직을 구현했습니다.

## 💡 주요 성과 (Key Insights)
* **비접촉식 거리 측정:** 추가적인 센서 없이 연산만으로 객체와의 거리를 추정하는 기술적 기틀을 마련했습니다.
* **복합 알고리즘 설계:** 신호 처리(Correlation)와 광학 재구성(VCR)이라는 두 가지 서로 다른 영역을 결합하여 시스템의 정확도를 높였습니다.

---
