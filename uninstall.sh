#!/bin/bash
# OCI-Kali + Tailscale 삭제 스크립트

echo "==================================================================="
echo "⚠️ OCI-Kali 및 Tailscale 도커 환경을 삭제합니다."
echo "주의: 이 작업은 컨테이너, 네트워크 및 데이터 볼륨(인증 정보, 홈 디렉토리)을 모두 영구적으로 삭제합니다."
echo "==================================================================="

read -p "계속 진행하시겠습니까? (y/N) " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "작업을 취소합니다."
    exit 1
fi

echo "[1/3] 실행 중인 도커 컨테이너 중지 및 삭제 (볼륨 포함)..."
docker compose down -v

echo "[2/3] 더 이상 사용하지 않는 로컬 빌드 이미지 삭제..."
PROJECT_NAME=$(basename "$PWD")
docker rmi "${PROJECT_NAME}-kali-machine:latest" 2>/dev/null || true
docker rmi "${PROJECT_NAME}_kali-machine:latest" 2>/dev/null || true

echo "[3/3] 시스템에 남겨진 불필요한 도커 리소스 정리 (dangling)..."
docker system prune -f

if [ -f .env ]; then
    read -rp ".env 파일도 삭제하시겠습니까? (Tailscale 인증 키 포함) (y/N) " DEL_ENV
    if [[ "$DEL_ENV" =~ ^[Yy]$ ]]; then
        rm -f .env
        echo "  .env 파일이 삭제되었습니다."
    fi
fi

echo "완료되었습니다. 관련 데이터와 컨테이너가 모두 정리되었습니다."
