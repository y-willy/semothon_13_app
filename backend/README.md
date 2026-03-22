## 백엔드 적용 순서

python이랑 pip는 이미 설치되어있다는 가정하에 하겠습니다

가상 환경 생성 및 적용(windows cmd 기준)

```
cd ./backend
python -v venv venv
venv\Scripts\activate.bat
```

호환 라이브러리 및 프레임워크 설치

```
pip install -r requirments.txt
```

서버 가동

```
fastapi dev app/main.py
```

% 개발 끝난 경우 가상 환경 나가기 %

```
venv\Scripts\deactivate.bat
```

## 파일 설명

SQL 폴더: 적용한 sql 명령어 모아두는 곳
