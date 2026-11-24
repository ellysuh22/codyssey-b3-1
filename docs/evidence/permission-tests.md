# IAM 최소 권한 거부 테스트

> 정책 `b3-1-policy`가 정말로 막는지 **IAM 사용자 `b3-1-practice`로 로그인해** 직접 시도했다. 거부되면 정상이다.
> 일시: 2026-11-23 (KST) · 리전: 서울 `ap-northeast-2` · 계정 ID는 `<ACCOUNT_ID>`로 가렸다.

## 결과 요약

| # | 시도 | 정책상 이유 | 기대 | 실제 | 판정 | 근거 |
|---|---|---|---|---|---|---|
| 1 | S3 콘솔에서 범용 버킷 목록 보기 | 정책에 S3 권한이 **하나도 없음** | 거부 | "버킷을 표시할 권한 없음 … `s3:ListAllMyBuckets` 작업을 허용하면" | ✅ 거부됨 | [00-03-deny-s3.png](../screenshots/00-03-deny-s3.png) |
| 2 | VPC 생성 (VPC만, 이름 태그 없음, `10.99.0.0/16`, `Project`·`Owner` 태그 없음) | `ec2:CreateVpc`는 `Project=B3-1`, `Owner=b3-1-practice` 요청 태그가 **있을 때만** 허용 | 거부 | `UnauthorizedOperation` (아래 원문) | ✅ 거부됨, VPC 생성 안 됨 | [00-03-deny-vpc.png](../screenshots/00-03-deny-vpc.png) |

## 2번 오류 원문 (계정 ID 가림, 인코딩된 메시지 생략)

```text
VPC를 생성하는 동안 오류가 발생했습니다.
You are not authorized to perform this operation.
User: arn:aws:iam::<ACCOUNT_ID>:user/b3-1-practice is not authorized to perform:
ec2:CreateVpc on resource: arn:aws:ec2:ap-northeast-2:<ACCOUNT_ID>:vpc/*
because no identity-based policy allows the ec2:CreateVpc action.
Encoded authorization failure message: (생략)
```

## 읽는 법

| 문구 | 뜻 |
|---|---|
| `User: …:user/b3-1-practice` | 루트가 아니라 **실습용 IAM 사용자**가 시도했다 |
| `ec2:CreateVpc on resource …:vpc/*` | 막힌 작업은 **VPC 생성** 하나다 |
| `no identity-based policy allows` | 사용자에게 붙은 정책 중 **이 요청을 허용하는 문장이 없다** → 태그 조건을 만족하지 않아 `B31CreateVpcWithTags` 문장이 적용되지 않음 |

## 결론

- 실습과 무관한 서비스(S3)는 **조회조차** 안 된다 → 미션 §4 "S3/RDS 등 권한 부여하지 않음".
- 실습 서비스(EC2/VPC)라도 **소유 태그 없이는 만들 수 없다** → 누가 만든 리소스인지 항상 추적된다 (미션 §7 "생성 시점부터 정리 대상으로 추적").
- 다음 STEP부터는 모든 생성 화면에서 태그 2개를 넣어야 생성된다.
