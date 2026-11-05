"""Run Lua 5.1 syntax checks and deterministic addon tests (no WoW required)."""
from pathlib import Path
import sys
import re

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.tools' / 'python'))
try:
    from lupa.lua51 import LuaRuntime
except ImportError:
    raise SystemExit('Install test runtime: uv pip install --target .tools/python lupa==2.6')

def runtime(locale=None):
    vm = LuaRuntime(unpack_returned_tuples=True)
    vm.globals().PROJECT_ROOT = ROOT.as_posix()
    if locale is not None:
        vm.globals().TEST_LOCALE = locale
    return vm

lua = runtime()
english_keys = set(re.findall(r'\bL\.([A-Z][A-Z0-9_]+)\s*=',
                             (ROOT / 'ForeverXPOptimizer/Locales/enUS.lua').read_text(encoding='utf-8')))
for source in (ROOT / 'ForeverXPOptimizer').glob('*.lua'):
    references = set(re.findall(r'\bL\.([A-Z][A-Z0-9_]+)', source.read_text(encoding='utf-8')))
    assert references <= english_keys, f'{source.name}: undefined translation keys {references - english_keys}'
for path in sorted((ROOT / 'ForeverXPOptimizer').rglob('*.lua')):
    lua.execute('assert(loadstring(...))', path.read_text(encoding='utf-8'))
    print('Syntax OK:', path.name)
lua.execute((ROOT / 'tests' / 'model_test.lua').read_text(encoding='utf-8'))
lua.execute((ROOT / 'tests' / 'locale_test.lua').read_text(encoding='utf-8'))
for locale in ['enUS', 'enGB', 'deDE', 'frFR', 'esES', 'esMX', 'itIT', 'ptBR', 'ptPT',
               'ruRU', 'koKR', 'zhCN', 'zhTW', 'xxXX']:
    runtime(locale).execute((ROOT / 'tests' / 'client_test.lua').read_text(encoding='utf-8'))
