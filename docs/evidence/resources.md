# 리소스 목록 (정리 대상 추적)

> 만들 때마다 한 줄씩 추가하고, 정리할 때 이 표를 하나씩 대조한다.
> 계정 ID · 이메일 · 비밀번호 · 키 내용은 적지 않는다.

## STEP 0 · 계정 준비 (루트 계정, 2026-11-23)

| 항목 | 이름 / 값 | 리전 | 요금 | 정리 | 근거 |
|---|---|---|---|---|---|
| 계정 플랜 | Free plan (크레딧 US$100 → 예산 생성 후 US$120, 182일, 만료 2027-05-23) | 글로벌 | 청구 없음 | 해당 없음 | [00-01-free-plan.png](../screenshots/00-01-free-plan.png) |
| 리전 | 아시아 태평양(서울) `ap-northeast-2` | — | — | — | [00-01-seoul-home.png](../screenshots/00-01-seoul-home.png) |
| 루트 MFA | `b3-1-root-phone` (가상, 인증 앱) | 글로벌 | 없음 | 유지 | [00-02-mfa.png](../screenshots/00-02-mfa.png) |
| 예산 | `b3-1-zero-spend` (제로 지출, 실제 비용 > US$0.01 알림, 메일 인증 1/1) | 글로벌 | 없음 | 유지 또는 평가 후 결정 | [00-02-budget.png](../screenshots/00-02-budget.png) |

## STEP 0-3 · IAM (루트로 생성, 2026-11-23)

| 항목 | 이름 / 값 | 리전 | 요금 | 정리 | 근거 |
|---|---|---|---|---|---|
| IAM 정책 | `b3-1-policy` (고객 관리형, 21:21 KST 생성, 허용 서비스 EC2 1개) | 글로벌 | 없음 | 평가 후 루트로 정리 여부 결정 | [00-03-policy.png](../screenshots/00-03-policy.png) |
| IAM 사용자 | `b3-1-practice` (콘솔 접근, 정책 `b3-1-policy`만 직접 연결, 권한 경계 없음) | 글로벌 | 없음 | 평가 후 루트로 정리 여부 결정 | [00-03-user.png](../screenshots/00-03-user.png), [00-03-iam-login.png](../screenshots/00-03-iam-login.png) |
| 거부 테스트 | S3 목록 거부 ✅, 태그 없는 VPC 생성 거부 ✅ (VPC 생성 안 됨) | 서울 | — | — | [permission-tests.md](permission-tests.md) |

## STEP 1 · 네트워크 (IAM 사용자 `b3-1-practice`, 서울)

| 리소스 | 이름 | ID | 주요 값 | 상태 | 정리 순서 | 근거 |
|---|---|---|---|---|---|---|
| VPC | `b3-1-vpc` | `vpc-0510d8b165db77c1c` | `10.0.0.0/16`, 테넌시 default, 기본 VPC 아님 | Available | 7 (마지막 근처) | [01-vpc.png](../screenshots/01-vpc.png) |
| 기본 라우팅 테이블 (VPC와 함께 자동 생성) | — | `rtb-03c531dfd394b0cab` | local만 | — | VPC 삭제 시 함께 삭제 | [01-vpc.png](../screenshots/01-vpc.png) |
| 기본 네트워크 ACL (자동 생성) | — | `acl-099b445d9a2a58e2f` | 기본 전체 허용 | — | VPC 삭제 시 함께 삭제 | [01-vpc.png](../screenshots/01-vpc.png) |
| 서브넷 | `b3-1-subnet-public` | `subnet-006ec6df5bf1c7b2e` | `10.0.1.0/24` (256 IPs), `ap-northeast-2a` (`apne2-az1`), VPC `b3-1-vpc` | 생성됨 | 6 | [01-subnet-created.png](../screenshots/01-subnet-created.png) |

## STEP 2 · 인터넷 길

| 리소스 | 이름 | ID | 주요 값 | 상태 | 정리 순서 | 근거 |
|---|---|---|---|---|---|---|
| 인터넷 게이트웨이 | `b3-1-igw` | `igw-0c1652057dab7b750` | 태그 3개 (Name, Project, Owner) | Detached → **Attached** (`vpc-0510d8b165db77c1c`) | 5 (분리 후 삭제) | [02-igw-detached.png](../screenshots/02-igw-detached.png), [02-igw-attached.png](../screenshots/02-igw-attached.png) |
| 라우팅 테이블 | `b3-1-rtb-public` | `rtb-033c2174194a9bc48` | 기본 아님, VPC `b3-1-vpc`. 라우팅 `10.0.0.0/16 → local` + **`0.0.0.0/0 → igw-0c1652057dab7b750`** (둘 다 활성). **명시적 서브넷 연결** `subnet-006ec6df5bf1c7b2e` | 활성 | 6 (서브넷 연결 해제 후 삭제) | [02-rtb-local.png](../screenshots/02-rtb-local.png), [02-rtb-routes.png](../screenshots/02-rtb-routes.png), [02-rtb-subnet.png](../screenshots/02-rtb-subnet.png) |

## STEP 3 · 보안 그룹

| 리소스 | 이름 | ID | 주요 값 | 상태 | 정리 순서 | 근거 |
|---|---|---|---|---|---|---|
| 보안 그룹 | `b3-1-web-sg` | `sg-00c3b629679064cd6` | VPC `b3-1-vpc`. 인바운드: SSH TCP 22 ← 내 IP `/32` (`sgr-0eee5237d6573ecbe`), HTTP TCP 80 ← `0.0.0.0/0` (`sgr-03291db5dddb95478`). 아웃바운드: 모든 트래픽 → `0.0.0.0/0` (`sgr-0ea13a55f81eba1c1`, 기본값) | 생성됨 | 4 (EC2 종료 후 삭제) | [03-sg-detail.png](../screenshots/03-sg-detail.png), [03-sg-inbound.png](../screenshots/03-sg-inbound.png), [03-sg-outbound.png](../screenshots/03-sg-outbound.png) |
| (자동) 기본 보안 그룹 | default | `sg-0db45a58edd520632` | `b3-1-vpc`의 기본 보안 그룹 | — | VPC 삭제 시 함께 삭제 | 같은 화면 |

## STEP 4 · 키와 EC2

| 리소스 | 이름 | ID | 주요 값 | 상태 | 정리 순서 | 근거 |
|---|---|---|---|---|---|---|
| 키 페어 | `b3-1-key` | — | ed25519, 공개 키만 가져오기, 지문 `SHA256:rFYGnYN6N9whfrKTIeUYd6S2YvIIxkzNcO8Z6LCudEM`. 개인 키 `~/.ssh/b3-1-ed25519` (Mac에만, 권한 600) | 등록됨 (ID `key-05d49e6b084800e6e`) | 8 | [04-key.png](../screenshots/04-key.png) |
| EC2 인스턴스 | `b3-1-web` | `i-0b2265faed73df750` | t3.micro, AL2023 `ami-00f4e1d08499d41c3`, `ap-northeast-2a`, 서브넷 `b3-1-subnet-public`, SG `b3-1-web-sg`, 키 `b3-1-key`, 크레딧 표준, IMDSv2만, **퍼블릭 IPv4 `13.124.137.81`** (EIP 아님), **프라이빗 IPv4 `10.0.1.122`**, 탄력적 IP `–`, 상태 검사 3/3 통과 | 실행 중 | 1 (종료) | [04-ec2-summary.png](../screenshots/04-ec2-summary.png), [04-ec2-launched.png](../screenshots/04-ec2-launched.png), [04-ec2-list.png](../screenshots/04-ec2-list.png), [04-ec2-running.png](../screenshots/04-ec2-running.png) |
| EBS 볼륨 (EC2와 함께 생성) | `b3-1-web` 태그 | `vol-0761089ffdc87b3bf` | gp3 8GiB, 3000 IOPS/125 MiB/s, 암호화(aws/ebs), 종료 시 삭제, `apne2-az1`(2a), 2026-11-24 10:18 생성 | 사용 중 | 2 (EC2 종료 시 자동 삭제 확인) | [04-ec2-storage.png](../screenshots/04-ec2-storage.png), [06-ebs-volume.png](../screenshots/06-ebs-volume.png) |

## STEP 6-2 · 과금 위험 리소스 추적 (조회만, 2026-11-24)

| 대상 (미션 §7) | 확인 결과 | 근거 |
|---|---|---|
| Elastic IP | **0개** — "이 리전에서 탄력적 IP 주소를 찾을 수 없음" | [06-eip-empty.png](../screenshots/06-eip-empty.png) |
| NAT Gateway | **0개** — "NAT 게이트웨이를 찾을 수 없음" | [06-nat-empty.png](../screenshots/06-nat-empty.png) |
| EBS Volumes | **1개** (`vol-0761089ffdc87b3bf`, EC2 루트, 종료 시 삭제) — 미사용 볼륨 없음 | [06-ebs-volume.png](../screenshots/06-ebs-volume.png) |
| ELB/ALB | 만들지 않음 — 실습 IAM 정책에 ELB 권한 없음 | [infra/iam-policy.json](../../infra/iam-policy.json) |
| RDS | 만들지 않음 — 실습 IAM 정책에 RDS 권한 없음 | [infra/iam-policy.json](../../infra/iam-policy.json) |
