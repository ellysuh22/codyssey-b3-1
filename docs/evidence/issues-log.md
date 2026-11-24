# 실습 중 실제로 생긴 오류 메모

> 트러블슈팅 보고서([../troubleshooting.md](../troubleshooting.md))에 옮길 후보. 실제로 겪은 것만 적는다.

## 1. [실제 발생] IAM 정책 설명에 허용되지 않는 문자 (2026-11-23, STEP 0-3)

| 단계 | 내용 |
|---|---|
| 증상 | 정책 생성 시 "정책 b3-1-policy을(를) 생성하지 못했습니다. 잘못된 문자가 있습니다. 영숫자 및 '+=,.@-' 문자를 사용하세요" |
| 가설 | 정책 JSON이 아니라 **설명 칸**의 문자 문제 (빨간 표시가 설명 칸에만 있음) |
| 검증 | 설명 문구 `B3-1 lab least privilege:Seoul, ...`에서 허용 목록에 없는 문자 = `:` (콜론) |
| 조치 1 | 콜론을 하이픈으로 바꿈 → `B3-1 lab least privilege - Seoul, tagged resources, t3.micro only` → **같은 오류 다시 발생** ([00-03-policy-error.png](../screenshots/00-03-policy-error.png)). 오류 문구의 허용 목록 `'+=,.@-'`에 **띄어쓰기도 없음** |
| 조치 2 | `<사용자 확인 후 기록: 설명을 비웠는지 / 띄어쓰기 없는 문구로 바꿨는지>` |
| 결과 | 정책 `b3-1-policy` 생성 성공 (2026-11-23 21:21 KST, [00-03-policy.png](../screenshots/00-03-policy.png)) |
| 재발 방지 | 콘솔 입력 칸 아래의 허용 문자 안내를 먼저 확인한다. 설명 문구는 영숫자와 `+=,.@-_`만 쓰고 띄어쓰기도 피한다 |

## 2. [실제 발생] VPC 생성 거부 — 태그 키 오타 `Projec` (2026-11-23, STEP 1)

| 단계 | 내용 |
|---|---|
| 증상 | `b3-1-vpc` 생성 시 "You are not authorized to perform this operation … not authorized to perform: ec2:CreateVpc … because no identity-based policy allows the ec2:CreateVpc action" ([01-vpc-error-tag-typo.png](../screenshots/01-vpc-error-tag-typo.png)) |
| 가설 | 권한 자체는 있으므로(정책 `B31CreateVpcWithTags`), **요청 태그가 정책 조건과 다르다** — 거부 테스트 ②와 같은 메시지 |
| 검증 | 같은 화면의 태그 칸 확인: `Name=b3-1-vpc`, **`Projec=B3-1`** (끝의 `t` 누락), `Owner=b3-1-practice`. 정책 조건은 `aws:RequestTag/Project = B3-1` → 키 이름이 달라 조건 불일치 |
| 조치 | 태그 키를 `Project`로 고쳐 다시 생성 |
| 결과 | 태그 3줄 수정 확인([01-vpc-tag-fixed.png](../screenshots/01-vpc-tag-fixed.png)) 후 재시도 → `vpc-0510d8b165db77c1c / b3-1-vpc 생성됨`, 상태 Available ([01-vpc.png](../screenshots/01-vpc.png)) |
| 재발 방지 | 태그 키·값은 정책 JSON에서 복사해 붙여 넣는다. 생성 전 태그 3줄(Name/Project/Owner) 철자를 소리 내어 확인한다 |

## 3. [실제 발생] 보안 그룹 생성 중 "아웃바운드 규칙 설명 업데이트" 권한 거부 (2026-11-24, STEP 3)

| 단계 | 내용 |
|---|---|
| 증상 | 보안 그룹 생성 화면: ✅ 보안 그룹 생성 / ✅ 2 인바운드 규칙 생성 / ❌ **아웃바운드 규칙 설명 업데이트** — "not authorized to perform: ec2:UpdateSecurityGroupRuleDescriptionsEgress on resource: …:security-group/sg-00c3b629679064cd6" ([03-sg-error-egress-desc.png](../screenshots/03-sg-error-egress-desc.png)) |
| 가설 | 보안 그룹과 인바운드 규칙은 이미 만들어졌고, **아웃바운드 규칙에 설명을 적어서** 콘솔이 추가로 부른 '아웃바운드 규칙 설명 수정' 작업만 정책에 없어서 실패했다 |
| 검증 | ⓪ 생성 화면에서 아웃바운드 규칙 1의 설명 칸에 `all outbound`를 입력했음 ([03-sg-form-outbound-desc.png](../screenshots/03-sg-form-outbound-desc.png)) ① 오류 속 작업 이름 `UpdateSecurityGroupRuleDescriptionsEgress`가 `b3-1-policy`의 허용 목록에 없음 ② 같은 화면에서 생성·인바운드 2개는 성공 표시 ③ 보안 그룹 상세: 인바운드 2개(SSH 22 ← 내 IP/32, HTTP 80 ← 0.0.0.0/0), 아웃바운드 1개(모든 트래픽 → 0.0.0.0/0, 설명 `–`) |
| 조치 | **권한을 늘리지 않음.** 실패한 작업은 규칙 '설명' 메모일 뿐 통신 허용 여부와 무관 → 재시도하지 않고 상세 화면에서 실제 규칙만 확인 |
| 결과 | 보안 그룹 `b3-1-web-sg`(`sg-00c3b629679064cd6`)는 정상. 실패한 것은 아웃바운드 **설명 메모**뿐이며 규칙은 기본값대로 존재 ([03-sg-inbound.png](../screenshots/03-sg-inbound.png), [03-sg-outbound.png](../screenshots/03-sg-outbound.png)). 권한은 추가하지 않음 |
| 재발 방지 | 정책에 없는 부가 작업(설명 수정 등)은 입력하지 않는다. 오류가 나면 **실패한 작업 이름**과 **실제로 만들어진 것**을 구분해서 본다 (최소 권한 원칙: 필요한 작업만 추가 검토) |

## 4. [실제 발생] 인스턴스 시작 실패 — 기본 VPC에 새 보안 그룹 생성 시도 거부 (2026-11-24, STEP 4)

| 단계 | 내용 |
|---|---|
| 증상 | 인스턴스 시작 → "인스턴스 시작 실패 … not authorized to perform: **ec2:CreateSecurityGroup** on resource: …:vpc/**vpc-06bd8039727c75e6b**". 로그: 요청 초기화 ✅ / 보안 그룹 생성 ❌ ([04-ec2-error-default-vpc-sg.png](../screenshots/04-ec2-error-default-vpc-sg.png)) |
| 가설 | 실패한 작업이 **인스턴스 생성이 아니라 보안 그룹 생성**이고, 대상 VPC가 우리 VPC(`vpc-0510…`)가 아니라 **기본 VPC(`vpc-06bd…`)** → 시작 마법사의 네트워크 설정이 기본값(기본 VPC + "보안 그룹 생성" `launch-wizard`)으로 되돌아간 상태로 요청됨 |
| 검증 | 오류 속 리소스 ID가 기본 VPC임. 키 페어 확인 창이 뜬 직후 시작했으며, 그 전에도 스토리지 암호화 표시가 한 번 풀려 보였음(마법사 값이 바뀌는 현상) |
| 조치 | '실패한 작업 재시도' 대신 **인스턴스 구성 편집** → 초기화된 태그 3줄(리소스 유형 3종) 재입력 → 네트워크 설정에서 VPC가 여전히 `vpc-06bd…`(기본)이고 서브넷이 '기본 설정 없음'인 것 확인 → VPC `b3-1-vpc`, 서브넷 `b3-1-subnet-public`, 퍼블릭 IP 활성화, 기존 SG `b3-1-web-sg`로 수정 → 스토리지 암호화·개수 1 재확인 후 시작 |
| 결과 | **성공** — `인스턴스를 시작했습니다. (i-0b2265faed73df750)` ([04-ec2-launched.png](../screenshots/04-ec2-launched.png)) |
| 재발 방지 | **시작 버튼 직전에 요약의 방화벽이 b3-1-web-sg인지, 네트워크 설정을 한 번 더 확인**한다. 정책이 "내 태그가 있는 VPC 안에서만 SG 생성"을 강제했기 때문에 22번이 전 세계에 열리는 `launch-wizard` 보안 그룹이 **만들어지지 않았다** — 최소 권한이 실수를 막은 사례 |

## 5. [실제 발생] `nginx -t` 경고 + Nginx 미실행 (2026-11-24, STEP 5)

| 단계 | 내용 |
|---|---|
| 증상 | ① `sudo nginx -t` → `[warn] could not build optimal types_hash, you should increase either types_hash_max_size: 1024 or types_hash_bucket_size: 64` (syntax ok / test successful은 나옴) ② `systemctl is-active nginx` → **`inactive`** ③ `sudo systemctl reload nginx` → `nginx.service is not active, cannot reload.` |
| 가설 | ① 직접 작성한 `nginx.conf`에 `types_hash_max_size`가 없어 기본값(1024)이 `mime.types` 크기보다 작다 ② `systemctl enable --now nginx`(시작) 단계를 건너뛰어 서비스가 한 번도 켜지지 않았다 — reload는 **이미 켜진** 서비스에만 가능 |
| 검증 | ① 경고 문구가 정확히 `types_hash_max_size`를 늘리라고 지목 ② 입력 순서 확인: install → nginx -t → is-active → reload (enable --now 없음) |
| 조치 | ① `config/nginx.conf`의 http 블록에 `types_hash_max_size 4096;` 추가 → 재전송·재설치 ② `sudo systemctl enable --now nginx` 실행 |
| 결과 | 재검사 시 **경고 0개** (`syntax is ok` / `test is successful`만 출력), `enable --now` → `active`, `curl -i http://localhost/health` → **`HTTP/1.1 200 OK`, `Content-Type: text/plain`, 본문 `OK`** ([05-deploy.log](05-deploy.log)) |
| 재발 방지 | 설정 변경 후 `nginx -t`는 **경고까지 0개**를 목표로 한다. 서비스 순서는 `enable --now`(처음 켜기) → 설정 바꿀 때만 `reload` |
