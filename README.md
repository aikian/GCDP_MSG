# GCDP_MSG

**온열질환 위험 감지 손목밴드**의 경고 SMS 수신 화면을 재현한 모바일 웹앱 데모입니다.

실제 장치는 [`geumbang1/gcdp-heat-risk-alert-wristband`](https://github.com/geumbang1/gcdp-heat-risk-alert-wristband)
— ESP32-C3 + TMP117(체온) + MAX30102(심박) + BE-220(GNSS) 조합으로,
LTE-M 망을 통해 보호자에게 SMS를 전송합니다. 이 저장소는 그 **수신 측 화면**을
발표·시연용으로 흉내 낸 것입니다. 실제 통신은 하지 않습니다.

## 데모 조작

**화면을 빠르게 두 번 터치하면 경고 메시지가 즉시 도착합니다.**

- 상단 상태바 시계는 항상 실시간입니다
- 메시지 시각은 실제 도착한 시각으로 찍힙니다
- 받은 메시지는 `localStorage`에 남아 새로고침해도 유지됩니다
- 메시지가 쌓이면 실제 메시지 앱처럼 위아래로 스크롤됩니다
- 기록을 지우려면 **상단 프로필 아이콘을 길게(0.8초) 누르세요**

## 메시지 형식

펌웨어 [`sendAlertSms()`](https://github.com/geumbang1/gcdp-heat-risk-alert-wristband/blob/HEAD/firmware/src/main.cpp#L1072-L1084)
가 실제로 보내는 본문을 그대로 따릅니다.

```
[국외발신]
SOS HELP REQUEST
HR: 128.4 bpm
TEMP: 39.12 C
LOC: 13.736717,100.523186
```

심박·체온·좌표는 온열질환 위험 구간 내에서 매번 새로 생성됩니다.
센서 값이 없을 때 펌웨어가 `N/A`를 넣는 동작도 동일합니다.

## UI

삼성 One UI 메시지 앱 화면을 기준으로 구성했습니다.
치수는 1080px 캡처 / DPR 2.75(= 393dp 논리폭) 기준으로 환산했습니다.

- 상태바 — 실시간 시계, 알림/밝기/날씨 아이콘, 무음·LTE·신호·배터리
- 앱바 — 뒤로가기, 프로필, 발신번호 `+82 10 3232 1976`, 더보기
- 스미싱 안내 배너 + `수신 차단` / `메시지 신고` 버튼
- 날짜 구분선 (`8월 13일 목요일` 형식, 날짜가 바뀌면 자동 삽입)
- 좌측 회색 수신 버블 + 우측 하단 정렬 시각 (`오전 3:27` 형식)
- 하단 입력바, 홈 인디케이터

## 구성

| 파일 | 설명 |
| --- | --- |
| `index.html` | 앱 전체 (의존성 없는 단일 파일) |
| `manifest.json`, `icon*.svg` | 홈 화면 추가 시 전체화면 실행 |
| `Dockerfile`, `nginx.conf` | 컨테이너 배포 |
| `DEPLOY.md` | Coolify → `msg.uxo.kr` 배포 절차 |

## 실행

```bash
python -m http.server 8080
# http://localhost:8080
```

컨테이너로:

```bash
docker build -t gcdp-msg .
docker run --rm -p 8080:80 gcdp-msg
```

## 배포

Coolify로 `msg.uxo.kr`에 올립니다. 절차는 [DEPLOY.md](DEPLOY.md)를 보세요.

## 참고

시연용 재현물입니다. 의료기기가 아니며, 표시되는 수치를 진단이나
치료 판단에 사용해서는 안 됩니다.
