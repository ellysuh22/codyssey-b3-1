# 장면별 진행 기록 (walkthrough)

> 실제로 진행한 순서대로 콘솔 · 터미널 화면을 모았다. 계정 ID · 내 IP는 가렸다.
> 표기: **[실제 발생]** = 진행 중 실제로 생긴 오류 (자세한 분석은 [troubleshooting.md](troubleshooting.md))

## STEP 0 · 계정 준비 (루트: 가입 · MFA · 예산 · IAM만)

**Free plan 확인 — 크레딧 범위 안에서만 사용, 청구 없음**

![Free plan 확인 — 크레딧 범위 안에서만 사용, 청구 없음](screenshots/00-01-free-plan.png)

**콘솔 리전 서울(ap-northeast-2)**

![콘솔 리전 서울(ap-northeast-2)](screenshots/00-01-seoul-home.png)

**루트 계정 MFA 등록 (b3-1-root-phone)**

![루트 계정 MFA 등록 (b3-1-root-phone)](screenshots/00-02-mfa.png)

**제로 지출 예산 b3-1-zero-spend · 메일 인증 1/1**

![제로 지출 예산 b3-1-zero-spend · 메일 인증 1/1](screenshots/00-02-budget.png)

**[실제 발생] 정책 설명 칸 '잘못된 문자' 오류**

![[실제 발생] 정책 설명 칸 '잘못된 문자' 오류](screenshots/00-03-policy-error.png)

**정책 b3-1-policy — 허용 서비스 EC2 1개(484개 중)**

![정책 b3-1-policy — 허용 서비스 EC2 1개(484개 중)](screenshots/00-03-policy.png)

**사용자 b3-1-practice — 정책 1개만 직접 연결**

![사용자 b3-1-practice — 정책 1개만 직접 연결](screenshots/00-03-user.png)

**IAM 사용자로 재로그인 (이후 루트 미사용)**

![IAM 사용자로 재로그인 (이후 루트 미사용)](screenshots/00-03-iam-login.png)

**거부 테스트 ① S3 버킷 목록 → 거부 = 정상**

![거부 테스트 ① S3 버킷 목록 → 거부 = 정상](screenshots/00-03-deny-s3.png)

**거부 테스트 ② 태그 없이 VPC 생성 → 거부 = 정상**

![거부 테스트 ② 태그 없이 VPC 생성 → 거부 = 정상](screenshots/00-03-deny-vpc.png)

## STEP 1 · VPC와 서브넷

**[실제 발생] 태그 키 오타 Projec → 생성 거부**

![[실제 발생] 태그 키 오타 Projec → 생성 거부](screenshots/01-vpc-error-tag-typo.png)

**태그 3줄 수정 (Name · Project · Owner)**

![태그 3줄 수정 (Name · Project · Owner)](screenshots/01-vpc-tag-fixed.png)

**b3-1-vpc 10.0.0.0/16 Available**

![b3-1-vpc 10.0.0.0/16 Available](screenshots/01-vpc.png)

**b3-1-subnet-public 생성**

![b3-1-subnet-public 생성](screenshots/01-subnet-created.png)

**10.0.1.0/24 · ap-northeast-2a · 사용 가능 IP 251**

![10.0.1.0/24 · ap-northeast-2a · 사용 가능 IP 251](screenshots/01-subnet.png)

## STEP 2 · 인터넷 길 (IGW · 라우팅 테이블)

**b3-1-igw 생성 직후 Detached**

![b3-1-igw 생성 직후 Detached](screenshots/02-igw-detached.png)

**b3-1-vpc에 연결 → Attached**

![b3-1-vpc에 연결 → Attached](screenshots/02-igw-attached.png)

**b3-1-rtb-public 생성 — local 경로만**

![b3-1-rtb-public 생성 — local 경로만](screenshots/02-rtb-local.png)

**0.0.0.0/0 → IGW 추가 (활성)**

![0.0.0.0/0 → IGW 추가 (활성)](screenshots/02-rtb-routes.png)

**b3-1-subnet-public 명시적 연결**

![b3-1-subnet-public 명시적 연결](screenshots/02-rtb-subnet.png)

## STEP 3 · 보안 그룹

**생성 화면 (아웃바운드 설명 입력)**

![생성 화면 (아웃바운드 설명 입력)](screenshots/03-sg-form-outbound-desc.png)

**[실제 발생] 아웃바운드 설명 업데이트만 권한 거부**

![[실제 발생] 아웃바운드 설명 업데이트만 권한 거부](screenshots/03-sg-error-egress-desc.png)

**b3-1-web-sg 생성 확인 (VPC b3-1-vpc)**

![b3-1-web-sg 생성 확인 (VPC b3-1-vpc)](screenshots/03-sg-detail.png)

**인바운드: SSH 22 ← 내 IP/32, HTTP 80 ← 0.0.0.0/0**

![인바운드: SSH 22 ← 내 IP/32, HTTP 80 ← 0.0.0.0/0](screenshots/03-sg-inbound.png)

**아웃바운드: 모든 트래픽 → 0.0.0.0/0 (기본값)**

![아웃바운드: 모든 트래픽 → 0.0.0.0/0 (기본값)](screenshots/03-sg-outbound.png)

## STEP 4 · 키 페어와 EC2

**b3-1-key ed25519 (공개 키만 가져오기)**

![b3-1-key ed25519 (공개 키만 가져오기)](screenshots/04-key.png)

**gp3 8GiB · 3000/125 · 암호화 · 종료 시 삭제**

![gp3 8GiB · 3000/125 · 암호화 · 종료 시 삭제](screenshots/04-ec2-storage.png)

**메타데이터 V2만(토큰 필수)**

![메타데이터 V2만(토큰 필수)](screenshots/04-ec2-metadata.png)

**시작 요약 — t3.micro · b3-1-web-sg · 8GiB**

![시작 요약 — t3.micro · b3-1-web-sg · 8GiB](screenshots/04-ec2-summary.png)

**[실제 발생] 기본 VPC로 되돌아가 보안 그룹 생성 거부**

![[실제 발생] 기본 VPC로 되돌아가 보안 그룹 생성 거부](screenshots/04-ec2-error-default-vpc-sg.png)

**재시작 성공 i-0b2265faed73df750**

![재시작 성공 i-0b2265faed73df750](screenshots/04-ec2-launched.png)

**실행 중 · 퍼블릭 IPv4 13.124.137.81**

![실행 중 · 퍼블릭 IPv4 13.124.137.81](screenshots/04-ec2-list.png)

**상태 검사 3/3 통과 · 프라이빗 10.0.1.122**

![상태 검사 3/3 통과 · 프라이빗 10.0.1.122](screenshots/04-ec2-running.png)

## STEP 5 · SSH · Nginx · 검증

**SSH 접속 → dnf로 Nginx 설치**

![SSH 접속 → dnf로 Nginx 설치](screenshots/05-ssh-login.png)

**nginx -t 통과 · active**

![nginx -t 통과 · active](screenshots/05-nginx-test.png)

**서버 안: localhost/ 200 · /health 200 · example.com 200**

![서버 안: localhost/ 200 · /health 200 · example.com 200](screenshots/05-server-checks.png)

**서버 → 인터넷 아웃바운드 HTTP/2 200**

![서버 → 인터넷 아웃바운드 HTTP/2 200](screenshots/05-example-com.png)

**[방식 B] 내 Mac에서 /health → 200 OK**

![[방식 B] 내 Mac에서 /health → 200 OK](screenshots/05-external-health.png)

**[방식 A] 브라우저 홈 — 정상 동작 중**

![[방식 A] 브라우저 홈 — 정상 동작 중](screenshots/05-browser.png)

**브라우저 /health → OK**

![브라우저 /health → OK](screenshots/05-browser-health.png)

## STEP 6 · 트러블슈팅 재현 · 정리 준비

**[재현 실험] https 시간 초과 vs http 200**

![[재현 실험] https 시간 초과 vs http 200](screenshots/06-repro-https.png)

**탄력적 IP 0개**

![탄력적 IP 0개](screenshots/06-eip-empty.png)

**NAT 게이트웨이 0개**

![NAT 게이트웨이 0개](screenshots/06-nat-empty.png)

**EBS 볼륨 1개 (EC2 루트)**

![EBS 볼륨 1개 (EC2 루트)](screenshots/06-ebs-volume.png)
