---
name: c-to-hls
description: Convert a reference C model algorithm into a Stratus HLS SystemC module with SC_CTHREAD, valid-based I/O, and traceable mapping documentation. Use when users ask to transform C model code into HLS code, align interfaces, or maintain conversion rules.
---

# Reference C Model to Stratus HLS

Use this skill when a user wants to convert algorithmic reference C into Stratus-oriented SystemC HLS code and keep maintainable traceability.

## Inputs you must collect
- Reference C model file path(s)
- Target HLS interface contract (streaming, kernel input, frame input, valid semantics)
- Fixed-point/bit-width requirements
- Whether boundary handling is inside the HLS core or provided externally

If any of the above is missing, infer from repository docs in `docs/` and existing HLS files before asking.

## Canonical docs source
- Canonical source directory: `/home/dudupunch0/hls_skill_docs`
- Source files:
  - `hls_conversion_spec.md`
  - `hls_conversion_checklist.md`
  - `hls_conversion_update_policy.md`
  - `bootstrap_repo_docs.sh`

When working in a new repo:
1. Copy canonical docs into `<repo>/docs/` first.
2. Then adapt copied docs to project-specific constraints.
3. Keep canonical source generic; put project-specific details only in repo-local copies.

Important:
- Bootstrap으로 복사된 `docs/*.md`는 generic baseline이다.
- 해당 문서만으로 현재 reference C model과의 직접 연관성은 보장되지 않는다.
- 현재 변환 건의 연관성은 `tests/HLS_REFERENCE_MAPPING.md`(또는 요청 경로)에 반드시 기록해야 한다.

## Standard workflow
1. Identify algorithmic core in the reference C model.
2. Separate concerns:
- Core arithmetic/data transform to keep in HLS module
- System/frame concerns to move outside (scan order, window generation, border policy), unless explicitly requested inside
3. Implement Stratus-style module:
- `SC_MODULE`
- `SC_CTHREAD(run, clk.pos())`
- `reset_signal_is(rst, true)`
- `#pragma hls_design top`
4. Implement valid-based cycle behavior:
- No combinational ambiguity
- `o_data_valid` asserted only when `o_data` is freshly produced
5. Preserve arithmetic equivalence with reference core:
- Same median/threshold/clamp or equivalent math
6. Write/update mapping document in `tests/HLS_REFERENCE_MAPPING.md` (or requested path).
7. Run static checks available in repo (or explain why not run).

## Required output artifacts
- HLS header/source pair (or user-requested file names)
- Mapping documentation connecting reference C logic to HLS logic
- Brief contract summary: input assumptions, output validity, cycle semantics
- Note in output summary that copied repo docs started from generic baseline and were project-tailored.

## Quality gates (must pass)
- Interface semantics are explicit and internally consistent
- One-cycle behavior is deterministic under `i_data_valid`
- No dead/unused control signals left in port list
- Mapping doc clearly states what stayed equivalent and what was re-partitioned

## Where to read detailed standards
- Process and checklists: `docs/hls_conversion_checklist.md`
- Canonical contract/spec: `docs/hls_conversion_spec.md`
- Rule evolution policy: `docs/hls_conversion_update_policy.md`

## Bootstrap command
Use canonical script when `docs/` does not yet have conversion docs:
- From target repo root:
  - `bash /home/dudupunch0/hls_skill_docs/bootstrap_repo_docs.sh`
- Or with explicit target path:
  - `bash /home/dudupunch0/hls_skill_docs/bootstrap_repo_docs.sh /path/to/repo`
- Overwrite existing docs only when explicitly requested:
  - `bash /home/dudupunch0/hls_skill_docs/bootstrap_repo_docs.sh --force /path/to/repo`
