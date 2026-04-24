#!/bin/bash

echo "==================================================================="
echo " OCI-Kali + Tailscale 설치 마법사"
echo "==================================================================="
echo ""

REPO_URL="https://github.com/whiwoon/oci-kali.git"
INSTALL_DIR="$HOME/oci-kali"

# 스크립트가 curl 파이프로 실행되거나 다른 디렉토리에서 실행된 경우 처리
if [ ! -f "docker-compose.yml" ]; then
    echo "프로젝트 파일이 현재 디렉토리에 없습니다."
    if [ ! -d "$INSTALL_DIR" ]; then
        echo "Git 저장소를 $INSTALL_DIR 에 다운로드합니다..."
        git clone "$REPO_URL" "$INSTALL_DIR"
    else
        echo "기존 $INSTALL_DIR 디렉토리를 최신 버전으로 업데이트합니다..."
        cd "$INSTALL_DIR" && git pull origin master
    fi
    # 다운로드 받은 디렉토리로 이동
    cd "$INSTALL_DIR" || exit 1
    echo "작업 디렉토리를 $INSTALL_DIR 로 변경했습니다."
    echo ""
fi

# Docker 설치 확인
if ! command -v docker &>/dev/null; then
    echo "오류: docker가 설치되어 있지 않습니다."
    exit 1
fi
if ! docker compose version &>/dev/null; then
    echo "오류: Docker Compose 플러그인이 설치되어 있지 않습니다. (Docker Desktop 또는 docker-compose-plugin 설치 필요)"
    exit 1
fi

# 기존 .env 파일 처리 로직
SKIP_ENV_INPUT=false
if [ -f .env ]; then
    echo "경고: .env 파일이 이미 존재합니다."
    echo "  1) 기존 .env 설정을 그대로 사용하여 바로 빌드 진행"
    echo "  2) 기존 설정 무시하고 새로 입력하여 덮어쓰기"
    echo "  3) 스크립트 종료 (취소)"
    read -rp "선택 (1/2/3): " ENV_CHOICE
    
    case "$ENV_CHOICE" in
        1)
            echo ""
            echo "기존 .env 파일을 사용하여 진행합니다."
            SKIP_ENV_INPUT=true
            ;;
        2)
            echo ""
            echo "새로운 설정을 입력받습니다. (기존 .env 파일은 덮어씌워집니다)"
            ;;
        *)
            echo ""
            echo "취소합니다."
            exit 0
            ;;
    esac
fi

if [ "$SKIP_ENV_INPUT" != true ]; then
    # TS_AUTHKEY: 필수 입력
    while true; do
        read -rp "Tailscale Auth Key (tskey-auth-...): " TS_AUTHKEY
        if [[ "$TS_AUTHKEY" == tskey-auth-?* ]]; then
            break
        fi
        echo "  오류: 올바른 Auth Key 형식이 아닙니다. (tskey-auth-... 형식으로 입력하세요)"
    done

    echo ""

    # KALI_PASSWORD: 비어있으면 기본값 사용
    while true; do
        read -rsp "Kali 사용자 비밀번호 (Enter = 기본값 'kali' 사용): " KALI_PASSWORD
        echo ""
        if [ -z "$KALI_PASSWORD" ]; then
            KALI_PASSWORD="kali"
            echo "  기본값 'kali'로 설정됩니다. 접속 후 반드시 변경하세요."
            break
        elif [ ${#KALI_PASSWORD} -lt 8 ]; then
            echo "  경고: 비밀번호가 너무 짧습니다 (8자 이상 권장)."
            read -rsp "  다시 입력하거나 Enter로 이 비밀번호를 그대로 사용: " CONFIRM
            echo ""
            if [ -z "$CONFIRM" ]; then
                # 짧은 비밀번호 그대로 사용
                break
            fi
            # 새 비밀번호 입력 시 재확인
            KALI_PASSWORD="$CONFIRM"
            read -rsp "  비밀번호 확인: " KALI_PASSWORD_CONFIRM
            echo ""
            if [ "$KALI_PASSWORD" = "$KALI_PASSWORD_CONFIRM" ]; then
                break
            fi
            echo "  오류: 비밀번호가 일치하지 않습니다. 다시 입력하세요."
        else
            read -rsp "  비밀번호 확인: " KALI_PASSWORD_CONFIRM
            echo ""
            if [ "$KALI_PASSWORD" = "$KALI_PASSWORD_CONFIRM" ]; then
                break
            fi
            echo "  오류: 비밀번호가 일치하지 않습니다. 다시 입력하세요."
        fi
    done

    echo ""

    # .env 파일 생성
    cat > .env <<EOF
TS_AUTHKEY=${TS_AUTHKEY}
KALI_PASSWORD=${KALI_PASSWORD}
EOF

    echo ".env 파일이 생성되었습니다."
    echo ""
fi

# 빌드 및 실행 여부 확인
read -rp "지금 바로 빌드하고 실행하시겠습니까? (y/N) " RUN_NOW
if [[ "$RUN_NOW" =~ ^[Yy]$ ]]; then
    echo ""
    echo "빌드를 시작합니다. 빌드 에러 원인 파악을 위해 상세 로그(--progress=plain)를 출력합니다..."
    echo "시간이 다소 걸릴 수 있습니다..."
    echo ""
    # 상세 로그 출력을 위해 build를 먼저 실행
    if docker compose build --progress=plain; then
        docker compose up -d
        echo ""
        echo "==================================================================="
        echo " 완료! Tailscale Admin Console에서 'kali' 기기의 IP를 확인 후 RDP로 접속하세요."
        echo " Username: kali"
        echo " Password: 방금 설정한 비밀번호"
        echo "==================================================================="
    else
        echo ""
        echo "==================================================================="
        echo "오류: 이미지 빌드에 실패했습니다."
        echo "위의 상세 로그를 확인하여 어떤 과정에서 에러가 발생했는지 확인해주세요."
        echo "==================================================================="
        exit 1
    fi
else
    echo ""
    echo "나중에 실행하려면 아래 명령어를 사용하세요:"
    echo "  docker compose build --progress=plain && docker compose up -d"
fi
