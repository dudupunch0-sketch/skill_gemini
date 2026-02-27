# HLS Conversion Checklist

## Pre-conversion
1. Reference C model의 대상 알고리즘 블록을 명확히 지정했다.
2. 인터페이스 계약(`i_data*`, `o_data*`, valid semantics)을 확정했다.
3. bit-width/saturation 요구사항을 확정했다.
4. 경계 처리 위치(내부/외부)를 확정했다.

## Implementation
1. `SC_MODULE + SC_CTHREAD + reset_signal_is + #pragma hls_design top` 적용
2. `i_data_valid` 기준으로 cycle 동작이 결정됨
3. `o_data_valid`는 실제 `o_data` 출력 사이클에만 assert
4. reference core 수학식(예: median/threshold/clamp) 보존
5. 미사용 포트/상태/함수 제거

## Documentation
1. `docs/*.md`가 canonical baseline에서 시작했음을 인지하고, 프로젝트 특성으로 보정했다.
2. baseline 문서만으로 현재 cmodel 연관성이 설명되지 않는다는 점을 명시했다.
3. `tests/HLS_REFERENCE_MAPPING.md` 갱신
4. 아래 항목 명시:
- 1:1 로직 매핑
- 구조적 차이
- 시스템 동등성 전제
- I/O 및 타이밍 계약

## Verification
1. 가능하면 golden(ref C) vs HLS 비교 테스트 수행
2. 미수행 시 이유와 리스크를 명시
3. 경계값 케이스(최소/최대/임계값 근처) 점검

## Release readiness
1. 스펙 문서(`docs/hls_conversion_spec.md`)와 충돌 없음
2. 신규 규칙 필요 시 `docs/hls_conversion_update_policy.md` 절차로 업데이트
