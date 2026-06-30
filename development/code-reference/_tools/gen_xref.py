#!/usr/bin/env python3
"""Generate development/code-reference/_xref.md — a caller cross-reference index.

For every A3E/drn/ace function it lists where its `*_fnc_<Name>` token appears
(direct calls AND string-based registrations/triggers, since both spell the name),
plus appendices for the indirect-invocation mechanisms (postInit, Chronos, triggers,
template arrays, event handlers).

Mechanical reference only; safe to re-run anytime (only writes _xref.md). Run:
    python development/code-reference/_tools/gen_xref.py
"""
import os, re, collections

# repo root = three levels up from this script (development/code-reference/_tools/)
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
FUNC_ROOT = os.path.join(ROOT, "Code", "functions")
OUT = os.path.join(ROOT, "development", "code-reference", "_xref.md")
SCAN_DIRS = [os.path.join(ROOT, "Code"), os.path.join(ROOT, "Islands"), os.path.join(ROOT, "Mods")]
EXTS = (".sqf", ".hpp", ".ext", ".cpp", ".h")

func_files = []
name_to_paths = collections.defaultdict(list)
for cat in sorted(os.listdir(FUNC_ROOT)):
    catdir = os.path.join(FUNC_ROOT, cat)
    if not os.path.isdir(catdir):
        continue
    for fn in sorted(os.listdir(catdir)):
        if fn.startswith("fn_") and fn.endswith(".sqf"):
            name = fn[3:-4]
            rel = os.path.relpath(os.path.join(catdir, fn), ROOT).replace("\\", "/")
            func_files.append((cat, name, rel, os.path.join(catdir, fn)))
            name_to_paths[name.lower()].append(rel)

corpus = []
all_lines = []
for base in SCAN_DIRS:
    if not os.path.isdir(base):
        continue
    for dirpath, dirs, files in os.walk(base):
        if os.sep + ".git" in dirpath:
            continue
        for f in files:
            if not f.lower().endswith(EXTS):
                continue
            ap = os.path.join(dirpath, f)
            rel = os.path.relpath(ap, ROOT).replace("\\", "/")
            try:
                with open(ap, "r", encoding="utf-8", errors="replace") as fh:
                    for i, line in enumerate(fh, 1):
                        t = line.rstrip("\n")
                        all_lines.append((rel, i, t))
                        if "fnc_" in t.lower():
                            corpus.append((rel, i, t))
            except Exception:
                pass

def callers_for(name, own_rel):
    pat = re.compile(r"fnc_" + re.escape(name) + r"\b", re.IGNORECASE)
    return [(rel, ln, t.strip()) for rel, ln, t in corpus if rel != own_rel and pat.search(t)]

def scan(regex):
    rx = re.compile(regex, re.IGNORECASE)
    return [(rel, ln, t.strip()) for rel, ln, t in all_lines if rx.search(t)]

postinit = scan(r"\b(pre|post)Init\s*=\s*1")
chronos  = scan(r"Chronos_Register")
triggers = scan(r"setTriggerStatements")
templates= scan(r"A3E_\w*Templates\b")
evhandl  = scan(r"addEventHandler|CBA_fnc_addEventHandler")
dupes = {n: p for n, p in name_to_paths.items() if len(p) > 1}

with open(OUT, "w", encoding="utf-8") as o:
    o.write("# Code Reference — Caller Cross-Reference Index (`_xref.md`)\n")
    o.write("_Last updated: 2026-06-30 (local)_ · _Status: generated (regenerable)_\n\n")
    o.write("> **Generated mechanical index** — for filling the **Called by** / **Calls** fields. For each\n")
    o.write("> function it lists every line where its `*_fnc_<Name>` token appears (direct calls *and*\n")
    o.write("> string registrations / trigger statements). Regenerate with `_tools/gen_xref.py`. Not hand-edited.\n\n")
    o.write("**How to read:** a function with **no references** is likely an entry point (auto-run via\n")
    o.write("postInit, scheduler, trigger, or event — see appendices) or dead code; verify. Names that map to\n")
    o.write("**multiple files** are flagged below — references can't be attributed to one file by this index.\n")
    o.write("Note: dynamic dispatch (`call compile format`, `call (missionNamespace getVariable ...)`) is\n")
    o.write("invisible here — see risks-tech-debt RD-006.\n\n")

    if dupes:
        o.write("## Duplicate function names (same name, multiple files)\n\n")
        for n in sorted(dupes):
            o.write(f"- `{n}` -> {', '.join('`'+p+'`' for p in sorted(dupes[n]))}\n")
        o.write("\n")

    by_cat = collections.defaultdict(list)
    for cat, name, rel, ap in func_files:
        by_cat[cat].append((name, rel))
    for cat in sorted(by_cat):
        o.write(f"## {cat}\n\n")
        for name, rel in sorted(by_cat[cat], key=lambda x: x[0].lower()):
            hits = callers_for(name, rel)
            o.write(f"### {name}  (`{rel}`)\n")
            if not hits:
                o.write("- _no `fnc_` references found - entry point or dead code; verify._\n\n")
                continue
            for hrel, hln, ht in hits:
                snippet = ht if len(ht) <= 160 else ht[:157] + "..."
                o.write(f"- `{hrel}:{hln}` - {snippet}\n")
            o.write("\n")

    def appendix(title, rows, note):
        o.write(f"## Appendix - {title}\n\n{note}\n\n")
        if not rows:
            o.write("_none found._\n\n"); return
        for rel, ln, t in rows:
            snippet = t if len(t) <= 180 else t[:177] + "..."
            o.write(f"- `{rel}:{ln}` - {snippet}\n")
        o.write("\n")

    o.write("---\n\n# Indirect-invocation appendices\n\n")
    appendix("CfgFunctions auto-run (preInit/postInit = 1)", postinit,
             "These functions run automatically at mission load - caller is the **engine/CBA**.")
    appendix("Chronos registrations", chronos,
             "Functions registered **by name string** for periodic execution - caller is the **Chronos scheduler**.")
    appendix("Trigger statements (setTriggerStatements)", triggers,
             "Code run on trigger activation; function names appear as **strings** here.")
    appendix("Template arrays (A3E_*Templates)", templates,
             "Functions selected at runtime from these arrays (via callRandomFunction / getVariable).")
    appendix("Event handlers (addEventHandler / CBA)", evhandl,
             "Functions invoked from **event-handler code blocks**.")

print("wrote", OUT)
print("functions:", len(func_files), "| corpus lines:", len(corpus), "| total lines:", len(all_lines))
