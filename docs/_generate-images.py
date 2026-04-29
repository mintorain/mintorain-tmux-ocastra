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
    """1200x630 OG 이미지 — 카카오톡 / 페북 / 트위터 공유용."""
    W, H = 1200, 630
    img = gradient_bg(W, H, INK, INDIGO)
    draw = ImageDraw.Draw(img, "RGBA")

    # 격자 패턴 (배경 텍스처)
    for x in range(0, W, 40):
        draw.line([(x, 0), (x, H)], fill=(124, 58, 237, 30))
    for y in range(0, H, 40):
        draw.line([(0, y), (W, y)], fill=(124, 58, 237, 30))

    # 상단 배지
    badge_font = ImageFont.truetype(FONT_REG, 22)
    badge_text = "🚀  두온교육 바이브코딩 교육센터(by mintorain)"
    bbox = draw.textbbox((0, 0), badge_text, font=badge_font)
    bw, bh = bbox[2] - bbox[0], bbox[3] - bbox[1]
    bx, by = 80, 70
    pad = 16
    draw.rounded_rectangle(
        [bx - pad, by - pad, bx + bw + pad, by + bh + pad],
        radius=22,
        fill=(124, 58, 237, 80),
        outline=(167, 139, 250, 200),
        width=2,
    )
    draw.text((bx, by), badge_text, fill=(237, 233, 254), font=badge_font)

    # 메인 헤드라인 (큰 글자)
    title_font = ImageFont.truetype(FONT_BOLD, 88)
    line1 = "5개의 Claude를,"
    line2 = "한 화면에서, 동시에"
    draw.text((80, 170), line1, fill=WHITE, font=title_font)
    # line2 두 번째 줄에 그라디언트 강조 효과 — 단색으로 대체 (간단화)
    draw.text((80, 280), line2, fill=PURPLE_LIGHT, font=title_font)

    # 서브 카피
    sub_font = ImageFont.truetype(FONT_REG, 30)
    sub = "터미널 한 번 띄우면 기획자 · 프론트엔드 · 백엔드 · QA · 리더가\n자동 소환되는 Claude Code 팀 에이전트 키트"
    draw.multiline_text((80, 410), sub, fill=GRAY, font=sub_font, spacing=10)

    # 하단 OS 배지 라인
    os_font = ImageFont.truetype(FONT_REG, 24)
    os_line = "🍎 macOS    🐧 Linux    🪟 Windows Native    🇰🇷 한국어 우선"
    draw.text((80, 545), os_line, fill=(167, 139, 250), font=os_font)

    # 우측 하단 5분할 미니어처
    mw, mh = 280, 200
    mx, my = W - mw - 60, H - mh - 60
    draw.rounded_rectangle([mx, my, mx + mw, my + mh], radius=12, fill=(15, 14, 26, 230), outline=(124, 58, 237, 180), width=2)
    # 좌측 큰 칸 (Leader)
    leader_w = int(mw * 0.55)
    draw.rounded_rectangle([mx + 10, my + 10, mx + leader_w, my + mh - 10], radius=6, fill=(251, 191, 36, 60))
    # 우측 4분할
    right_x = mx + leader_w + 6
    right_w = mw - leader_w - 16
    sub_h = (mh - 20 - 12) // 4
    colors = [(253, 224, 71, 60), (74, 222, 128, 60), (56, 189, 248, 60), (248, 113, 113, 60)]
    for i, color in enumerate(colors):
        sy = my + 10 + i * (sub_h + 4)
        draw.rounded_rectangle([right_x, sy, right_x + right_w, sy + sub_h], radius=6, fill=color)

    out = OUT / "og-image.png"
    img.save(out, "PNG", optimize=True)
    print(f"[OK] {out} ({W}x{H})")


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
    print("\n생성 완료. docs/og-image.png, docs/favicon.png, docs/favicon-180.png 확인.")
