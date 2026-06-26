# docs/

Two PDFs covering the homelab end-to-end.

| File | Read this when… |
|---|---|
| **`architecture.pdf`** | You want the high-level picture: system layers, network topology, IP plan, security model, design decisions. |
| **`runbook.pdf`** | You're rebuilding from scratch, adding/changing a piece, or troubleshooting. Prerequisites, env vars, commands, and "what owns what". |
| **`ip-plan.md`** | You're laying out your own network. Explains the allocation pattern (`.10N` for hosts, `.1N0–.1N9` for VMs) with example values. |

Both PDFs are committed pre-rendered so you can read them directly from GitHub or with any PDF viewer — no toolchain required.

## Regenerate

The HTML sources live alongside the PDFs. To re-render after edits:

```bash
cd docs

# Each command writes the corresponding PDF in place.
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf=runbook.pdf runbook.html

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf=architecture.pdf architecture.html
```

(Chrome's headless mode is good enough; no need for pandoc / weasyprint / TeX.)

## Images

The diagrams referenced by `architecture.html` / `runbook.html` (stack, network, security, bootstrap) are embedded in the pre-rendered PDFs but the source PNGs are not in this repo — they show network specifics that are personal. To re-render the HTML or replace them, supply your own PNGs in a local `images/` directory:

- `stack.png` — system stack (hardware → workloads)
- `network.png` — home + lab + Tailscale overlay
- `security.png` — access boundaries: public internet / edge / interior
- `bootstrap.png` — bootstrap flow from bare metal to running apps

The originals were generated with Google's Nano Banana 2 (Gemini 3 Pro Image, paid tier).
