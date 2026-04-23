#!/bin/bash

echo "==================================================================="
echo " OCI-Kali + Tailscale 설치 마법사"
echo "==================================================================="
echo ""

# Docker 설치 확인
if ! command -v docker &>/dev/null; then
    echo "오류: docker가 설치되어 있지 않습니다."
    exit 1
fi
if ! command -v docker-compose &>/dev/null; then
    echo "오류: docker-compose가 설치되어 있지 않습니다."
    exit 1
fi

# 기존 .env 파일 덮어쓰기 경고
if [ -f .env ]; then
    echo "경고: .env 파일이 이미 존재합니다. 덮어쓰면 기존 설정이 사라집니다."
    read -rp "계속 진행하시겠습니까? (y/N) " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        echo "취소합니다."
        exit 0
    fi
    echo ""
fi

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

# 빌드 및 실행 여부 확인
read -rp "지금 바로 빌드하고 실행하시겠습니까? (y/N) " RUN_NOW
if [[ "$RUN_NOW" =~ ^[Yy]$ ]]; then
    echo ""
    echo "빌드를 시작합니다. Kali 데스크톱 환경(약 2GB 이상) 다운로드로 시간이 다소 걸릴 수 있습니다..."
    echo ""
    if docker-compose up -d --build; then
        echo ""
        echo "==================================================================="
        echo " 완료! Tailscale Admin Console에서 'kali' 기기의 IP를 확인 후 RDP로 접속하세요."
        echo " Username: kali"
        echo " Password: 방금 설정한 비밀번호"
        echo "==================================================================="
    else
        echo ""
        echo "오류: 빌드 또는 실행에 실패했습니다. 위 로그를 확인하세요."
        exit 1
    fi
else
    echo ""
    echo "나중에 실행하려면 아래 명령어를 사용하세요:"
    echo "  docker-compose up -d --build"
fi
