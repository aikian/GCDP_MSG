# 배포 가이드 — msg.uxo.kr (Coolify)

정적 사이트 1개를 nginx 컨테이너로 서빙합니다. 빌드 단계가 없어서
Coolify에서 **Dockerfile** 빌드팩만 지정하면 끝납니다.

---

## 1. 사전 확인 (완료된 항목)

| 항목 | 값 | 상태 |
| --- | --- | --- |
| Coolify | `https://cool.girinic.com` | API 응답 확인 |
| 서버 | `localhost` (`192.168.0.13`), uuid `q14lm6jydgkbhybh10ir8hg6` | reachable / usable |
| 프로젝트 | `uxo`, uuid `ygnzpi10umdshf5g2h73cb3i` | 존재 |
| 저장소 | `https://github.com/aikian/GCDP_MSG` (public) | 배포키 불필요 |
| DNS / SSL | `msg.uxo.kr` → `104.21.28.179`, `172.67.147.14` (Cloudflare) | 설정 완료됨 |

DNS와 인증서는 이미 준비되어 있습니다. Coolify에는 도메인을
**`http://msg.uxo.kr`** 로 넣으면 HTTPS는 자동으로 붙습니다.
`https://`로 적지 마세요.

---

## 2. Coolify 리소스 생성

Coolify UI 기준:

1. **Project `uxo` → + New Resource → Public Repository**
2. Repository URL: `https://github.com/aikian/GCDP_MSG`
3. Branch: `main`
4. **Build Pack: `Dockerfile`**  ← Nixpacks 아님
5. Dockerfile Location: `/Dockerfile`
6. **Ports Exposes: `80`**
7. **Domains: `http://msg.uxo.kr`**  ← `http://`로 입력. HTTPS는 자동으로 붙습니다
8. Health Check Path: `/health` (Dockerfile의 `HEALTHCHECK`와 동일 경로)
9. Deploy

빌드 인자·환경변수는 필요 없습니다. 순수 정적 파일입니다.

---

## 3. API로 만들 경우

토큰은 저장소에 넣지 말고 셸 환경변수로만 넘깁니다.

```bash
export COOLIFY_URL="https://cool.girinic.com"
export COOLIFY_TOKEN="<쿨리파이 토큰>"

curl -X POST "$COOLIFY_URL/api/v1/applications/public" \
  -H "Authorization: Bearer $COOLIFY_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "project_uuid":      "ygnzpi10umdshf5g2h73cb3i",
    "server_uuid":       "q14lm6jydgkbhybh10ir8hg6",
    "environment_name":  "production",
    "git_repository":    "https://github.com/aikian/GCDP_MSG",
    "git_branch":        "main",
    "build_pack":        "dockerfile",
    "dockerfile_location": "/Dockerfile",
    "ports_exposes":     "80",
    "domains":           "http://msg.uxo.kr",
    "health_check_path": "/health",
    "health_check_enabled": true,
    "name":              "gcdp-msg-demo",
    "description":       "GCDP Heat Risk Alert Wristband - SMS 수신 데모",
    "instant_deploy":    true
  }'
```

---

## 4. 로컬에서 먼저 확인

```bash
docker build -t gcdp-msg .
docker run --rm -p 8080:80 gcdp-msg
# http://localhost:8080
```

빌드 없이 그냥 볼 때:

```bash
python -m http.server 8080
```

---

## 5. 재배포

`main`에 push하면 됩니다. Coolify에서 **Webhook(자동 배포)** 을 켜두면
push마다 자동으로 다시 빌드됩니다. 켜지 않았다면 UI에서 Redeploy를 누릅니다.

`index.html`은 nginx에서 `no-cache`로 내려가므로 재배포 후 새로고침하면
바로 최신본이 보입니다.

## 6. 아이콘을 바꿨다면

아이콘(`icon*.svg`, `*.png`)은 `max-age=86400`으로 내려가고 Cloudflare가
하루 동안 캐시합니다. 파일만 바꾸면 옛날 아이콘이 계속 나오므로,
`index.html`과 `manifest.json`의 아이콘 URL에 붙은 `?v=` 숫자를 함께
올려야 합니다.

```bash
grep -n "?v=" index.html manifest.json
```
