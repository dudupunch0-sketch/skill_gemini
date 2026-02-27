# HLS Conversion Spec

## Purpose
이 문서는 reference C model -> Stratus HLS(SystemC) 변환 시 팀 공통 규약을 정의한다.

## Scope
- 알고리즘 코어 변환
- Stratus-friendly module 구조
- I/O 유효 신호 의미
- reference 대비 동등성 해석 기준

## Required module structure
1. `SC_MODULE`
2. `SC_CTHREAD(run, clk.pos())`
3. `reset_signal_is(rst, true)`
4. `#pragma hls_design top`

## Default signal contract
1. 입력:
- `clk`, `rst`
- `i_data_valid`
- algorithm-specific input data ports (예: `i_data[3][3]`)
- algorithm parameters (예: `threshold`)
2. 출력:
- algorithm-specific result data port (예: `o_data`)
- `o_data_valid`

## Validity semantics
1. `i_data_valid == 1`인 사이클에만 입력 샘플 유효로 간주한다.
2. 출력 픽셀/데이터가 실제로 계산되어 써지는 사이클에만 `o_data_valid`를 assert한다.
3. `o_data_valid == 1`이면 동일 사이클 `o_data`는 유효해야 한다.

## Algorithm mapping rules
1. 수학 연산은 reference C와 동등하게 유지한다.
2. 구조 분리는 허용한다:
- 프레임 스캔/윈도우 생성/경계 확장 로직을 외부로 분리 가능
- 코어 연산은 HLS 모듈로 집중
3. 분리한 항목은 반드시 매핑 문서에 명시한다.

## Data type rules
1. bit-width는 요구사항 기반으로 명시 (`sc_uint<N>`, `sc_int<N>`)
2. saturation/clamp 범위는 reference와 동일해야 한다.
3. signed/unsigned 해석 차이가 생기지 않게 캐스팅 지점을 명확히 둔다.

## Required documentation output
1. 변환마다 `tests/HLS_REFERENCE_MAPPING.md`를 생성/갱신한다.
2. 문서에는 최소 아래를 포함한다:
- reference 함수/블록 ↔ HLS 함수/블록 대응
- 동일한 점(수식/상수/범위)
- 달라진 점(인터페이스/파이프라인 분리/경계 처리 위치)
- 시스템 레벨 동등성 조건

## Version
- Spec version: `v1.0`

