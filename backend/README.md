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

.env.example 환경변수 설정

1. MySQL랑 MySQL Workbench 깔아야합니다
2. 그럼 MySQL Workbench가 편한 GUI버젼이라고 생각하시면 됩니다
3. 여기서 New Connection 설정할때 .env.example넣을 값이 나옵니다
4. Connection 맞춰주고 .env.example 에도 같은 값 넣으시면 됩니다.
5. .env.example -> .env로 이름까지 바꿔주시면 됩니다.
6. 그럼 DB 연결 완료...!
7. 서버 가동하고 테스트해보시면 됩니다
8. db연결 테스트 http://localhost:8000/db-check

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
