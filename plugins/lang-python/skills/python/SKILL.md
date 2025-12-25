---
name: python-dev
description: |
  Python開発支援（FastAPI/Pydantic/uv）。
  型ヒント、ruff、mypyでモダンPython開発をガイド。
allowed-tools: Read, Grep, Glob, Bash
---

# Python開発固有設定

このファイルはPython開発に特化した設定を定義します。

## Python開発固有のルール

### バージョン要件
- Python 3.10以降（推奨: Python 3.11+）
- 型ヒントを積極的に使用する
- f-stringsを使用する
- PEP 8に準拠する

### コーディング標準
- **ruff**（統合フォーマッター・リンター - Black + isort + flake8統合）
- **mypy strict mode**（厳格な型チェック）
- **PEP 8**（Pythonコーディング規約準拠）
- **型ヒント必須**（すべての関数・変数）
- **docstring**（Google/NumPy形式）

### フレームワーク・ツール
- **FastAPI**（高速API開発）
- **Pydantic**（データバリデーション）
- **SQLAlchemy**（ORM）
- **uv**（高速依存関係管理・Python版管理）
- **ruff**（統合フォーマッター・リンター）
- **mypy**（静的型チェック）
- **pytest**（テストフレームワーク）
- **pytest-asyncio**（非同期テスト）
- **pre-commit**（コミット前品質チェック）

### プロジェクト構成（src/レイアウト）
```
my-project/
├── src/
│   └── myproject/           # パッケージ名
│       ├── __init__.py
│       ├── main.py          # FastAPIアプリケーション
│       ├── config/          # 設定
│       │   ├── __init__.py
│       │   └── settings.py
│       ├── api/             # APIエンドポイント
│       │   ├── __init__.py
│       │   ├── deps.py      # 依存性注入
│       │   └── v1/
│       │       ├── __init__.py
│       │       └── endpoints/
│       ├── core/            # コアロジック
│       │   ├── __init__.py
│       │   ├── security.py  # セキュリティ
│       │   └── database.py  # データベース設定
│       ├── models/          # SQLAlchemyモデル
│       │   ├── __init__.py
│       │   └── user.py
│       ├── schemas/         # Pydanticスキーマ
│       │   ├── __init__.py
│       │   └── user.py
│       ├── services/        # ビジネスロジック
│       │   ├── __init__.py
│       │   └── user_service.py
│       └── utils/           # ユーティリティ
│           ├── __init__.py
│           └── helpers.py
├── tests/                   # テストコード
│   ├── __init__.py
│   ├── conftest.py         # pytest設定
│   ├── test_api/
│   └── test_services/
├── notebooks/               # Jupyter Notebook
│   ├── 01_eda.ipynb        # 探索的データ分析
│   ├── 02_modeling.ipynb   # モデリング
│   └── 03_evaluation.ipynb # 評価
├── docs/                    # ドキュメント
├── scripts/                 # スクリプト
├── .pre-commit-config.yaml  # pre-commit設定
├── pyproject.toml          # プロジェクト設定
├── uv.lock                 # 依存関係ロック
└── README.md
```

### 依存関係管理（pyproject.toml + uv）
```toml
[project]
name = "my-project"
version = "0.1.0"
description = "Modern Python project with FastAPI"
authors = [{name = "Your Name", email = "you@example.com"}]
readme = "README.md"
license = {text = "MIT"}
requires-python = ">=3.10"
keywords = ["fastapi", "python", "api"]
classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]

dependencies = [
    "fastapi>=0.104.0",
    "uvicorn[standard]>=0.24.0",
    "pydantic>=2.5.0",
    "sqlalchemy>=2.0.0",
    "alembic>=1.13.0",
    "passlib[bcrypt]>=1.7.4",
    "python-jose[cryptography]>=3.3.0",
    "httpx>=0.25.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "pytest-asyncio>=0.21.0",
    "pytest-cov>=4.1.0",
    "ruff>=0.1.0",
    "mypy>=1.7.0",
    "pre-commit>=3.5.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

# ruff設定（Black + isort + flake8を統合）
[tool.ruff]
line-length = 88
target-version = "py310"
src = ["src"]

[tool.ruff.lint]
select = [
    "E",      # pycodestyle errors
    "W",      # pycodestyle warnings
    "F",      # pyflakes
    "I",      # isort
    "B",      # flake8-bugbear
    "C4",     # flake8-comprehensions
    "UP",     # pyupgrade
    "ARG001", # unused-function-args
    "SIM",    # flake8-simplify
]
ignore = [
    "E501",   # line too long, handled by black
    "B008",   # do not perform function calls in argument defaults
]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
skip-magic-trailing-comma = false
line-ending = "auto"

[tool.mypy]
python_version = "3.10"
strict = true
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_any_generics = true
no_implicit_optional = true
show_error_codes = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = [
    "--strict-markers",
    "--strict-config",
    "--cov=src",
    "--cov-report=term-missing",
    "--cov-report=html",
    "--cov-fail-under=95",
]
```

### pre-commit設定（.pre-commit-config.yaml）
```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.9
    hooks:
      - id: ruff
        args: [--fix, --exit-non-zero-on-fix]
      - id: ruff-format

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.7.1
    hooks:
      - id: mypy
        additional_dependencies: [types-all]

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict

  - repo: https://github.com/python-security/bandit
    rev: 1.7.5
    hooks:
      - id: bandit
        args: ["-c", "pyproject.toml"]
```

### uv使用例
```bash
# Python バージョン管理
uv python install 3.11
uv python pin 3.11

# プロジェクト初期化
uv init my-project
cd my-project

# 依存関係追加
uv add fastapi uvicorn[standard]
uv add --dev pytest ruff mypy

# 仮想環境でコマンド実行
uv run python main.py
uv run pytest
uv run ruff check .
uv run mypy src/

# pre-commitセットアップ
uv run pre-commit install
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

def get_db():
    """データベースセッション取得"""
    # 実装は省略
    pass

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
        # User モデルは models/user.py で定義されている想定
        from app.models.user import User
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
async def database_transaction(db):
    """データベーストランザクション管理（非同期セッション用）"""
    try:
        yield db
        await db.commit()
    except Exception as e:
        await db.rollback()
        logger.error(f"トランザクションエラー: {e}")
        raise
    finally:
        await db.close()

# 同期セッション用のコンテキストマネージャー
from contextlib import contextmanager

@contextmanager
def sync_database_transaction(db: Session):
    """データベーストランザクション管理（同期セッション用）"""
    try:
        yield db
        db.commit()
    except Exception as e:
        db.rollback()
        logger.error(f"トランザクションエラー: {e}")
        raise
    finally:
        db.close()

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

### 非同期処理
```python
import asyncio
import logging
from typing import List, Dict, Any, Optional
from httpx import AsyncClient

logger = logging.getLogger(__name__)

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

### セキュリティベストプラクティス
```python
import os
import secrets
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
from typing import Dict, Any, Optional

from pydantic_settings import BaseSettings
from pydantic import field_validator

class SecuritySettings(BaseSettings):
    """セキュリティ設定（環境変数から取得）"""
    secret_key: str = secrets.token_urlsafe(32)
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30

    @field_validator("secret_key")
    def validate_secret_key(cls, v: str) -> str:
        if len(v) < 32:
            raise ValueError("Secret key must be at least 32 characters")
        return v

    class Config:
        env_file = ".env"

# セキュリティ設定インスタンス
security_settings = SecuritySettings()
# パスワードハッシュ化設定
pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto",
    bcrypt__rounds=12  # セキュリティ強化
)

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
    encoded_jwt = jwt.encode(
        to_encode,
        security_settings.secret_key,
        algorithm=security_settings.algorithm,
    )
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

## モダンPythonベストプラクティス

### 1. 開発環境の最適化
- **uv**: 高速な依存関係管理とPythonバージョン管理
- **src/レイアウト**: パッケージの適切な分離
- **pre-commit**: コミット前の自動品質チェック
- **ruff**: 統合フォーマッター・リンター（Black + isort + flake8）

### 2. 型安全性の徹底
- **完全な型ヒント**: すべての関数・変数に型注釈
- **mypy strict mode**: 厳格な型チェック
- **Pydantic**: ランタイム型検証
- **typing extensions**: 最新の型機能活用

### 3. コード品質の自動化
- **ruff**: 高速リンティング・フォーマット
- **mypy**: 静的型チェック
- **pytest**: 包括的テスト（カバレッジ95%以上）
- **bandit**: セキュリティ脆弱性検出

### 4. セキュリティファースト
- **環境変数**: 機密情報の適切な管理
- **入力検証**: Pydanticによる厳格な検証
- **パスワードハッシュ**: bcryptの適切な設定
- **依存関係監査**: 定期的な脆弱性チェック

### 5. プロジェクト構造の標準化
- **src/レイアウト**: テスト可能な構造
- **notebooks分離**: EDA・モデリング・評価の分離
- **設定管理**: 環境別設定の適切な分離
- **ドキュメント**: 自動生成可能な構造

### 6. パフォーマンス最適化
- **非同期処理**: FastAPI + asyncio活用
- **型ヒント**: JITコンパイル最適化
- **プロファイリング**: 定期的な性能測定
- **キャッシュ戦略**: 適切なキャッシュ実装

### 7. 継続的品質改善
- **自動テスト**: CI/CDパイプライン
- **コードレビュー**: 品質ゲート
- **メトリクス監視**: コード品質指標
- **リファクタリング**: 定期的な技術的負債解消

### 参考資料
- [CyberAgent AI Lab Python Best Practices](https://cyberagentailab.github.io/BestPracticesForPythonCoding/)
- [Python Security Best Practices](https://www.blackduck.com/ja-jp/blog/python-security-best-practices.html)
- [Advanced Python Tips (Reddit)](https://www.reddit.com/r/Python/comments/1g5xswk/advanced_python_tips_libraries_or_best_practices/)
