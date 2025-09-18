# Python開発固有設定

このファイルはPython開発に特化した設定を定義します。

## Python開発固有のルール

### バージョン要件
- Python 3.9以降（推奨: Python 3.11+）
- 型ヒントを積極的に使用する
- f-stringsを使用する
- PEP 8に準拠する

### コーディング標準
- Black（コードフォーマッター）
- isort（インポート整理）
- mypy（型チェック）
- ruff（高速リンター）

### フレームワーク・ツール
- FastAPI（高速API開発）
- Pydantic（データバリデーション）
- SQLAlchemy（ORM）
- Poetry（依存関係管理）
- pytest（テストフレームワーク）
- pytest-asyncio（非同期テスト）

### プロジェクト構成
```
src/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPIアプリケーション
│   ├── config/              # 設定
│   │   ├── __init__.py
│   │   └── settings.py
│   ├── api/                 # APIエンドポイント
│   │   ├── __init__.py
│   │   ├── deps.py          # 依存性注入
│   │   └── v1/
│   │       ├── __init__.py
│   │       └── endpoints/
│   ├── core/                # コアロジック
│   │   ├── __init__.py
│   │   ├── security.py      # セキュリティ
│   │   └── database.py      # データベース設定
│   ├── models/              # SQLAlchemyモデル
│   │   ├── __init__.py
│   │   └── user.py
│   ├── schemas/             # Pydanticスキーマ
│   │   ├── __init__.py
│   │   └── user.py
│   ├── services/            # ビジネスロジック
│   │   ├── __init__.py
│   │   └── user_service.py
│   └── utils/               # ユーティリティ
│       ├── __init__.py
│       └── helpers.py
tests/                       # テストコード
├── __init__.py
├── conftest.py             # pytest設定
├── test_api/
└── test_services/
```

### 依存関係管理（pyproject.toml）
```toml
[tool.poetry]
name = "my-project"
version = "0.1.0"
description = ""
authors = ["Your Name <you@example.com>"]

[tool.poetry.dependencies]
python = "^3.9"
fastapi = "^0.104.0"
uvicorn = {extras = ["standard"], version = "^0.24.0"}
pydantic = "^2.5.0"
sqlalchemy = "^2.0.0"
alembic = "^1.13.0"

[tool.poetry.group.dev.dependencies]
pytest = "^7.4.0"
pytest-asyncio = "^0.21.0"
black = "^23.0.0"
isort = "^5.12.0"
mypy = "^1.7.0"
ruff = "^0.1.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"

[tool.black]
line-length = 88
target-version = ['py39']

[tool.isort]
profile = "black"
line_length = 88

[tool.mypy]
python_version = "3.9"
strict = true
warn_return_any = true
warn_unused_configs = true

[tool.ruff]
line-length = 88
target-version = "py39"
```

### コードスタイル例
```python
"""モジュールのドキュメント文字列"""
from __future__ import annotations

from typing import Optional, List, Dict, Any
import logging

from fastapi import FastAPI, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

logger = logging.getLogger(__name__)

class UserCreate(BaseModel):
    """ユーザー作成用スキーマ"""
    name: str = Field(..., min_length=1, max_length=100)
    email: str = Field(..., regex=r'^[^@]+@[^@]+\.[^@]+$')
    age: Optional[int] = Field(None, ge=0, le=150)

class UserResponse(BaseModel):
    """ユーザー応答用スキーマ"""
    id: int
    name: str
    email: str
    age: Optional[int] = None
    
    class Config:
        from_attributes = True

def create_user(
    user_data: UserCreate,
    db: Session = Depends(get_db)
) -> UserResponse:
    """ユーザーを作成する
    
    Args:
        user_data: ユーザー作成データ
        db: データベースセッション
        
    Returns:
        作成されたユーザー情報
        
    Raises:
        HTTPException: ユーザー作成に失敗した場合
    """
    try:
        # ビジネスロジックの実装
        user = User(**user_data.model_dump())
        db.add(user)
        db.commit()
        db.refresh(user)
        
        logger.info(f"ユーザーを作成しました: {user.id}")
        return UserResponse.model_validate(user)
        
    except Exception as e:
        logger.error(f"ユーザー作成エラー: {e}")
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="ユーザーの作成に失敗しました"
        )
```

### 型ヒント
```python
from typing import Optional, List, Dict, Union, Callable, Any
from collections.abc import Sequence, Mapping

# 基本的な型ヒント
def calculate_total(
    items: List[Dict[str, float]], 
    tax_rate: float = 0.1
) -> float:
    """合計金額を計算する"""
    return sum(item["price"] for item in items) * (1 + tax_rate)

# 複雑な型ヒント
UserData = Dict[str, Union[str, int, bool]]
ProcessorFunc = Callable[[str], Optional[str]]

def process_users(
    users: Sequence[UserData],
    processor: ProcessorFunc
) -> List[Optional[str]]:
    """ユーザーデータを処理する"""
    return [processor(user.get("name", "")) for user in users]
```

### エラーハンドリング
```python
import logging
from typing import Optional
from contextlib import asynccontextmanager

logger = logging.getLogger(__name__)

class CustomError(Exception):
    """カスタム例外クラス"""
    def __init__(self, message: str, code: Optional[str] = None):
        self.message = message
        self.code = code
        super().__init__(self.message)

@asynccontextmanager
async def database_transaction(db: Session):
    """データベーストランザクション管理"""
    try:
        yield db
        await db.commit()
    except Exception as e:
        await db.rollback()
        logger.error(f"トランザクションエラー: {e}")
        raise
    finally:
        await db.close()

def safe_divide(a: float, b: float) -> Optional[float]:
    """安全な除算"""
    try:
        if b == 0:
            logger.warning("ゼロ除算が発生しました")
            return None
        return a / b
    except (TypeError, ValueError) as e:
        logger.error(f"計算エラー: {e}")
        return None
```

### テスト
```python
import pytest
from httpx import AsyncClient
from fastapi.testclient import TestClient

from app.main import app
from app.core.database import get_db
from tests.utils import override_get_db

@pytest.fixture
def client():
    """テストクライアント"""
    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()

@pytest.mark.asyncio
async def test_create_user(client: TestClient):
    """ユーザー作成テスト"""
    user_data = {
        "name": "テストユーザー",
        "email": "test@example.com",
        "age": 25
    }
    
    response = client.post("/api/v1/users/", json=user_data)
    
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == user_data["name"]
    assert data["email"] == user_data["email"]
    assert "id" in data

def test_calculate_total():
    """計算テスト"""
    items = [
        {"price": 100.0},
        {"price": 200.0}
    ]
    
    result = calculate_total(items, tax_rate=0.1)
    assert result == 330.0
```

### 非同期処理
```python
import asyncio
from typing import List
from httpx import AsyncClient

async def fetch_data(url: str) -> Optional[Dict[str, Any]]:
    """非同期でデータを取得"""
    async with AsyncClient() as client:
        try:
            response = await client.get(url)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            logger.error(f"データ取得エラー: {e}")
            return None

async def process_multiple_urls(urls: List[str]) -> List[Optional[Dict[str, Any]]]:
    """複数のURLを並行処理"""
    tasks = [fetch_data(url) for url in urls]
    return await asyncio.gather(*tasks, return_exceptions=True)
```

### セキュリティ
```python
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """パスワード検証"""
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """パスワードハッシュ化"""
    return pwd_context.hash(password)

def create_access_token(data: Dict[str, Any], expires_delta: Optional[timedelta] = None) -> str:
    """アクセストークン作成"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt
```

### ロギング設定
```python
import logging
from logging.handlers import RotatingFileHandler
import sys

def setup_logging(log_level: str = "INFO") -> None:
    """ロギング設定"""
    logging.basicConfig(
        level=getattr(logging, log_level.upper()),
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        handlers=[
            logging.StreamHandler(sys.stdout),
            RotatingFileHandler(
                "app.log",
                maxBytes=10485760,  # 10MB
                backupCount=5
            )
        ]
    )
```

## ベストプラクティス

### 1. 型ヒントの活用
- すべての関数に型ヒントを付ける
- `mypy`で型チェックを行う
- `typing`モジュールを活用する

### 2. エラーハンドリング
- 適切な例外処理を実装する
- ログを適切に出力する
- カスタム例外クラスを定義する

### 3. テスト駆動開発
- `pytest`を使用する
- 非同期コードは`pytest-asyncio`でテスト
- カバレッジ95%以上を目指す

### 4. コード品質
- `black`でフォーマット
- `ruff`でリント
- `isort`でインポート整理

### 5. セキュリティ
- 入力値の検証を徹底する
- パスワードは適切にハッシュ化
- JWTトークンで認証を実装
