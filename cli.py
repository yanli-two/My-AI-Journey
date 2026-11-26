"""语言进化的命令行工具（不依赖 astrbot，可单独运行）。

用法：
    python cli.py --rollback      # 回滚到上一代
    python cli.py --status        # 查看当前代次与条目
    python cli.py --list-history  # 查看历史代次
"""

import argparse
import json
import os
import sys
import time
import uuid
from pathlib import Path

STATE_FILE = Path(__file__).resolve().parent / "state.json"

DEFAULT_STATE = {
    "gen": 0,
    "extra": [],
    "insight": "",
    "note": "",
    "lastRun": 0,
    "lastCheck": 0,
    "history": [],
}


def load() -> dict:
    if not STATE_FILE.exists():
        state = dict(DEFAULT_STATE)
        save(state)
        return state
    try:
        data = json.loads(STATE_FILE.read_text(encoding="utf-8"))
    except Exception as e:
        print(f"状态文件损坏：{e}", file=sys.stderr)
        sys.exit(2)
    state = dict(DEFAULT_STATE)
    state.update({k: data.get(k, DEFAULT_STATE[k]) for k in DEFAULT_STATE})
    return state


def save(state: dict) -> None:
    tmp = STATE_FILE.with_name(f".state.{uuid.uuid4().hex[:8]}.tmp")
    tmp.write_text(json.dumps(state, ensure_ascii=False, indent=2), encoding="utf-8")
    os.replace(tmp, STATE_FILE)


def cmd_rollback() -> int:
    state = load()
    history = state.get("history") or []
    if len(history) < 2:
        print("历史已用尽：没有可回滚的上一代。", file=sys.stderr)
        return 1

    target = history[1]
    old_gen = int(state.get("gen", 0))
    state["extra"] = list(target.get("extra") or [])
    state["gen"] = int(target.get("gen", max(0, old_gen - 1)))
    state["insight"] = str(target.get("insight", "")) or ""
    state["note"] = f"已回滚到第 {state['gen']} 代（原第 {old_gen} 代）"
    state["history"] = history[1:]
    save(state)
    print(f"已回滚：第 {old_gen} 代 → 第 {state['gen']} 代，当前 {len(state['extra'])} 条")
    return 0


def cmd_status() -> int:
    state = load()
    print(f"代次：{state['gen']}")
    print(f"条目数：{len(state['extra'])}")
    for i, item in enumerate(state["extra"], 1):
        print(f"  {i}. {item}")
    print(f"上次运行：{time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(state['lastRun'])) if state.get('lastRun') else '从未'}")
    print(f"历史代次：{len(state.get('history') or [])}")
    return 0


def cmd_list_history() -> int:
    state = load()
    history = state.get("history") or []
    if not history:
        print("还没有历史记录。")
        return 0
    for i, h in enumerate(history):
        print(f"[{i}] 第 {h.get('gen')} 代（{h.get('ts', '')}），{len(h.get('extra') or [])} 条")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="语言进化状态管理")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--rollback", action="store_true", help="回滚到上一代")
    group.add_argument("--status", action="store_true", help="查看当前状态")
    group.add_argument("--list-history", action="store_true", help="查看历史代次")
    args = parser.parse_args()

    if args.rollback:
        return cmd_rollback()
    if args.status:
        return cmd_status()
    return cmd_list_history()


if __name__ == "__main__":
    sys.exit(main())
