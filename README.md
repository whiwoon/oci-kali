# OCI A1 · Kali Linux + Tailscale RDP

오라클 클라우드(OCI) A1(ARM64) 인스턴스에 Kali Linux 데스크톱 환경을 구축하고, Tailscale VPN을 통해서만 RDP로 접속할 수 있도록 구성합니다.  
공인 IP의 포트를 일절 개방하지 않으므로 (No Public Ports) 보안상 안전합니다.

## 구조

```
[클라이언트 PC] ──Tailscale VPN──▶ [tailscale-gateway 컨테이너]
                                          │ (네트워크 스택 공유)
                                          ▼
                                   [kali-machine 컨테이너]
                                     xrdp (3389)
```

`kali-machine`은 독립적인 네트워크 인터페이스를 갖지 않고 `tailscale-gateway`의 네트워크 스택을 공유합니다.  
따라서 kali로 향하는 모든 트래픽은 Tailscale을 통해서만 라우팅됩니다.

## 사전 준비

- OCI A1 인스턴스 (Ubuntu, ARM64)
- Docker, Docker Compose 설치 완료
- Tailscale 계정

## 설치 및 실행

### 1. Tailscale Auth Key 발급

[Tailscale Admin Console](https://login.tailscale.com/admin/settings/keys) → **Settings > Keys > Auth keys** → **Generate auth key**

### 2. 설치 스크립트 실행

```bash
chmod +x install.sh
./install.sh
```

스크립트가 Tailscale Auth Key와 Kali 비밀번호를 대화형으로 입력받아 `.env` 파일을 생성하고, 선택적으로 빌드까지 진행합니다.

> 수동으로 설정하려면 `.env.example`을 복사해 `.env`를 만들고 직접 편집하세요.

### 3. RDP 접속

1. 클라이언트 PC에도 Tailscale을 설치하고 동일 계정으로 로그인합니다.
2. [Tailscale Admin Console](https://login.tailscale.com/admin/machines)에서 `kali` 기기의 IP를 확인합니다.
3. RDP 클라이언트(Windows: `mstsc`, macOS: Microsoft Remote Desktop)로 해당 IP에 접속합니다.
4. 로그인 정보:
   - **Username**: `kali`
   - **Password**: 설치 시 입력한 비밀번호

## 삭제

컨테이너, 볼륨, 이미지를 포함한 모든 관련 리소스를 삭제합니다.

```bash
chmod +x uninstall.sh
./uninstall.sh
```
