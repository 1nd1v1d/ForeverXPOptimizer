"""Run Lua 5.1 syntax checks and deterministic addon tests (no WoW required)."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.tools' / 'python'))
try:
    from lupa.lua51 import LuaRuntime
except ImportError:
    raise SystemExit('Install test runtime: uv pip install --target .tools/python lupa==2.6')

lua = LuaRuntime(unpack_returned_tuples=True)
lua.globals().PROJECT_ROOT = ROOT.as_posix()
for path in sorted((ROOT / 'ForeverXPOptimizer').glob('*.lua')):
    lua.execute('assert(loadstring(...))', path.read_text(encoding='utf-8'))
    print('Syntax OK:', path.name)
lua.execute((ROOT / 'tests' / 'model_test.lua').read_text(encoding='utf-8'))
lua.execute((ROOT / 'tests' / 'client_test.lua').read_text(encoding='utf-8'))
