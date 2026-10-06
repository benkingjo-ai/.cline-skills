import argparse
from PIL import Image
from tray_anim import load_base_icon, render


def main():
    p = argparse.ArgumentParser(description="Render tray icon states at 64, 32 and 16 px for a visual check")
    p.add_argument("--icon", default=None, help="base icon image (PNG); a plain circle is used if omitted")
    p.add_argument("--out", default="tray_preview.png")
    a = p.parse_args()
    base = load_base_icon(a.icon)
    tiles = [render(base, k) for k in ("idle", "ok", "error")] + [render(base, "busy", ang) for ang in range(0, 360, 60)]
    cell, pad = 72, 8
    sheet = Image.new("RGBA", (pad + cell * len(tiles), pad + 3 * cell), (30, 30, 46, 255))
    for row, px in enumerate((64, 32, 16)):
        for col, t in enumerate(tiles):
            img = t if px == 64 else t.resize((px, px), Image.LANCZOS).resize((64, 64), Image.NEAREST)
            sheet.alpha_composite(img, (pad + col * cell, pad + row * cell))
    sheet.save(a.out)
    print(a.out, sheet.size)


if __name__ == "__main__":
    main()
