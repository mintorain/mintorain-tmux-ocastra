"""
docs/ 폴더의 OG 이미지와 favicon PNG 생성기.
한 번 생성한 후 결과 PNG만 커밋하면 됩니다 (이 스크립트도 함께 보존).

실행:
    python docs/_generate-images.py
"""
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

OUT = Path(__file__).parent

# ---- 색상 / 폰트 ----
PURPLE_LIGHT = (167, 139, 250)   # #A78BFA
PURPLE = (124, 58, 237)          # #7C3AED
INDIGO = (79, 70, 229)            # #4F46E5
INK = (30, 27, 75)                # #1E1B4B
INK_DARK = (15, 14, 26)           # #0F0E1A
WHITE = (255, 255, 255)
GRAY = (203, 213, 225)            # slate-300

FONT_BOLD = "C:/Windows/Fonts/malgunbd.ttf"
FONT_REG = "C:/Windows/Fonts/malgun.ttf"


def gradient_bg(w: int, h: int, top_color, bottom_color) -> Image.Image:
    """단순 수직 그라디언트 배경."""
    base = Image.new("RGB", (w, h), top_color)
    draw = ImageDraw.Draw(base)
    for y in range(h):
        ratio = y / max(h - 1, 1)
        r = int(top_color[0] * (1 - ratio) + bottom_color[0] * ratio)
        g = int(top_color[1] * (1 - ratio) + bottom_color[1] * ratio)
        b = int(top_color[2] * (1 - ratio) + bottom_color[2] * ratio)
        draw.line([(0, y), (w, y)], fill=(r, g, b))
    return base


def make_og_image() -> None:
    """1200x630 OG 이미지 — 카카오톡 / 페북 / 트위터 공유용 (D-tier 리디자인)."""
    W, H = 1200, 630
    img = gradient_bg(W, H, INK, (49, 46, 129))  # ink → indigo-900
    draw = ImageDraw.Draw(img, "RGBA")

    # 1) 격자 (소프트)
    for x in range(0, W, 48):
        draw.line([(x, 0), (x, H)], fill=(124, 58, 237, 22))
    for y in range(0, H, 48):
        draw.line([(0, y), (W, y)], fill=(124, 58, 237, 22))

    # 2) 우측 5분할 미니어처 (먼저 그려서 좌측 텍스트와 겹침 방지)
    mw, mh = 380, 280
    mx = W - mw - 80
    my = (H - mh) // 2 - 10
    draw.rounded_rectangle([mx, my, mx + mw, my + mh], radius=16,
                           fill=(15, 14, 26, 240), outline=(167, 139, 250, 180), width=2)
    # 좌측 큰 Leader
    inset = 12
    leader_w = int((mw - inset * 2) * 0.56)
    leader_box = [mx + inset, my + inset, mx + inset + leader_w, my + mh - inset]
    draw.rounded_rectangle(leader_box, radius=8, fill=(251, 191, 36, 50), outline=(251, 191, 36, 180), width=1)
    # Leader 아이콘 (텍스트 라벨)
    label_font = ImageFont.truetype(FONT_BOLD, 18)
    draw.text((leader_box[0] + 12, leader_box[1] + 12), "👑 Leader", fill=(251, 191, 36), font=label_font)
    # 우측 4분할
    right_x = mx + inset + leader_w + 6
    right_w = mw - inset * 2 - leader_w - 6
    sub_h = (mh - inset * 2 - 9) // 4
    panes = [
        ("📋 Planner",  (253, 224, 71)),
        ("🎨 Frontend", (74, 222, 128)),
        ("⚙️ Backend",  (56, 189, 248)),
        ("🔍 QA",       (248, 113, 113)),
    ]
    for i, (text, color) in enumerate(panes):
        sy = my + inset + i * (sub_h + 3)
        box = [right_x, sy, right_x + right_w, sy + sub_h]
        draw.rounded_rectangle(box, radius=6, fill=(color[0], color[1], color[2], 60),
                               outline=(color[0], color[1], color[2], 200), width=1)
        draw.text((box[0] + 10, box[1] + 10), text, fill=(color[0], color[1], color[2]), font=label_font)

    # 3) 상단 배지 (좌측)
    badge_font = ImageFont.truetype(FONT_REG, 22)
    badge_text = "🚀  두온교육 바이브코딩 교육센터(by mintorain)"
    bbox = draw.textbbox((0, 0), badge_text, font=badge_font)
    bw, bh = bbox[2] - bbox[0], bbox[3] - bbox[1]
    bx, by = 80, 70
    pad_x, pad_y = 18, 10
    draw.rounded_rectangle(
        [bx - pad_x, by - pad_y, bx + bw + pad_x, by + bh + pad_y],
        radius=24,
        fill=(124, 58, 237, 70),
        outline=(167, 139, 250, 200),
        width=2,
    )
    draw.text((bx, by), badge_text, fill=(237, 233, 254), font=badge_font)

    # 4) 메인 헤드라인
    title_font = ImageFont.truetype(FONT_BOLD, 76)
    draw.text((80, 175), "5개의 Claude를,", fill=WHITE, font=title_font)
    draw.text((80, 268), "한 화면에서, 동시에", fill=PURPLE_LIGHT, font=title_font)

    # 5) 서브 카피
    sub_font = ImageFont.truetype(FONT_REG, 24)
    sub_text = "기획자 · 프론트엔드 · 백엔드 · QA · 리더가 자동 소환되는\nClaude Code 팀 에이전트 키트"
    draw.multiline_text((80, 388), sub_text, fill=GRAY, font=sub_font, spacing=8)

    # 6) 하단 OS 배지 + URL 워터마크
    os_font = ImageFont.truetype(FONT_REG, 22)
    os_line = "🍎 macOS    🐧 Linux    🪟 Windows Native    🇰🇷 한국어"
    draw.text((80, 500), os_line, fill=(167, 139, 250), font=os_font)
    # URL 워터마크 (재공유 시 출처 식별)
    url_font = ImageFont.truetype(FONT_REG, 18)
    draw.text((80, 555), "github.com/mintorain/mintorain-tmux-ocastra", fill=(148, 163, 184), font=url_font)

    out = OUT / "og-image.png"
    img.save(out, "PNG", optimize=True)
    print(f"[OK] {out} ({W}x{H})")


def make_favicon_ico() -> None:
    """favicon.ico — 다중 사이즈(16/32/48) ICO. 구형 IE / 일부 RSS 리더 호환."""
    sizes = [16, 32, 48]
    images = []
    for size in sizes:
        img = gradient_bg(size, size, PURPLE, INDIGO).convert("RGBA")
        draw = ImageDraw.Draw(img, "RGBA")
        margin = max(1, size // 8)
        x0, y0 = margin, margin
        x1, y1 = size - margin, size - margin
        leader_w = int((x1 - x0) * 0.55)
        # Leader (white)
        draw.rectangle([x0, y0, x0 + leader_w - 1, y1], fill=(255, 255, 255, 235))
        # 4 sub panes
        right_x = x0 + leader_w + max(1, size // 32)
        right_w = x1 - right_x
        sub_h = (y1 - y0) / 4
        colors = [
            (253, 224, 71, 235),
            (74, 222, 128, 235),
            (56, 189, 248, 235),
            (248, 113, 113, 235),
        ]
        for i, color in enumerate(colors):
            sy = y0 + i * sub_h
            draw.rectangle([right_x, sy, x1, sy + sub_h - max(1, size // 32)], fill=color)
        images.append(img)

    out = OUT / "favicon.ico"
    images[0].save(out, format="ICO", sizes=[(s, s) for s in sizes], append_images=images[1:])
    print(f"[OK] {out} (multi-size ICO: {sizes})")


def make_favicon() -> None:
    """favicon: 32x32 / 180x180 (apple-touch-icon)."""
    for size in (32, 180):
        img = gradient_bg(size, size, PURPLE, INDIGO)
        draw = ImageDraw.Draw(img, "RGBA")

        # 외곽 둥근 처리: 큰 사이즈에서만 마스크 적용
        if size >= 180:
            mask = Image.new("L", (size, size), 0)
            md = ImageDraw.Draw(mask)
            md.rounded_rectangle([0, 0, size, size], radius=int(size * 0.22), fill=255)
            img.putalpha(mask)

        # 5분할 격자 (mintorain 키트의 핵심 시각 요소)
        margin = max(2, size // 8)
        x0, y0 = margin, margin
        x1, y1 = size - margin, size - margin
        # 좌측 큰 칸 (Leader)
        leader_w = int((x1 - x0) * 0.55)
        draw.rectangle([x0, y0, x0 + leader_w - 1, y1], fill=(255, 255, 255, 230))
        # 우측 4분할
        right_x = x0 + leader_w + max(1, size // 32)
        right_w = x1 - right_x
        sub_h = (y1 - y0) / 4
        colors = [
            (253, 224, 71, 230),   # planner yellow
            (74, 222, 128, 230),   # frontend green
            (56, 189, 248, 230),   # backend blue
            (248, 113, 113, 230),  # qa red
        ]
        for i, color in enumerate(colors):
            sy = y0 + i * sub_h
            draw.rectangle([right_x, sy, x1, sy + sub_h - max(1, size // 32)], fill=color)

        out = OUT / (f"favicon-{size}.png" if size != 32 else "favicon.png")
        img.save(out, "PNG", optimize=True)
        print(f"[OK] {out} ({size}x{size})")


if __name__ == "__main__":
    make_og_image()
    make_favicon()
    make_favicon_ico()
    print("\n생성 완료. docs/og-image.png, docs/favicon.{svg,png,ico}, docs/favicon-180.png 확인.")
