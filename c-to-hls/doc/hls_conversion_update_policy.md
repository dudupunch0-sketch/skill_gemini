# HLS Conversion Update Policy

## Purpose
변환 규칙 변경을 일관되게 관리하기 위한 정책 문서.

## Ownership
1. 변환 규약 변경은 코드 변경과 분리하지 말고 같은 PR에서 처리한다.
2. 변경자는 spec/checklist/mapping 영향도를 함께 기록한다.

## Change process
1. 변경 사유 정의
- 어떤 reference C 패턴에서 기존 규칙이 부족했는지 명시
2. 영향 범위 평가
- 인터페이스 영향
- 연산 동등성 영향
- 기존 HLS 코드 호환성 영향
3. 문서 업데이트
- `docs/hls_conversion_spec.md` 수정
- 필요 시 `docs/hls_conversion_checklist.md` 수정
- 대상 케이스 `tests/HLS_REFERENCE_MAPPING.md` 반영
4. 코드 반영
- 문서 규약과 동일한 semantics로 구현
5. 검증/리스크 기록
- 수행한 검증
- 미수행 항목과 잔여 리스크

## Versioning rules
1. `docs/hls_conversion_spec.md`의 버전을 갱신한다.
2. 권장 규칙:
- Patch: 표현 개선/오탈자/의미 불변
- Minor: 하위호환 가능한 규약 확장
- Major: 호환성 깨짐 또는 기본 계약 변경

## PR checklist items (required)
1. "Spec version before/after" 기재
2. "Why changed" 기재
3. "Backward compatibility" 기재
4. "Mapping docs updated" 체크

