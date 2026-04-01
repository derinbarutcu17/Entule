#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import subprocess
import shutil

ROOT = Path(__file__).resolve().parent.parent
RESOURCES = ROOT / "Resources"
ICONSET = RESOURCES / "AppIcon.iconset"
ICNS = RESOURCES / "AppIcon.icns"

SIZES = [16, 32, 64, 128, 256, 512, 1024]


def lerp(a: int, b: int, t: float) -> int:
    return int(round(a + (b - a) * t))


def vertical_gradient(size: int, top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    img = Image.new("RGBA", (size, size))
    px = img.load()
    for y in range(size):
        t = y / max(size - 1, 1)
        color = (
            lerp(top[0], bottom[0], t),
            lerp(top[1], bottom[1], t),
            lerp(top[2], bottom[2], t),
            255,
        )
        for x in range(size):
            px[x, y] = color
    return img


def rounded_mask(size: int, radius: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return mask


def create_icon(size: int) -> Image.Image:
    base = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    radius = int(size * 0.23)

    background = vertical_gradient(size, (17, 19, 26), (8, 10, 14))
    mask = rounded_mask(size, radius)
    base.paste(background, (0, 0), mask)

    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.ellipse(
        (int(size * 0.10), int(size * 0.08), int(size * 0.62), int(size * 0.60)),
        fill=(206, 176, 123, 54),
    )
    glow = glow.filter(ImageFilter.GaussianBlur(radius=max(4, size // 18)))
    base.alpha_composite(glow)

    draw = ImageDraw.Draw(base)
    inset = int(size * 0.03)
    draw.rounded_rectangle(
        (inset, inset, size - inset - 1, size - inset - 1),
        radius=max(1, radius - inset),
        outline=(255, 255, 255, 28),
        width=max(1, size // 64),
    )

    center = (size * 0.5, size * 0.5)
    ring_radius = size * 0.22
    ring_width = max(2, size // 28)
    bbox = (
        center[0] - ring_radius,
        center[1] - ring_radius,
        center[0] + ring_radius,
        center[1] + ring_radius,
    )
    draw.ellipse(bbox, outline=(211, 178, 127, 235), width=ring_width)

    inner_radius = size * 0.055
    draw.ellipse(
        (
            center[0] - inner_radius,
            center[1] - inner_radius,
            center[0] + inner_radius,
            center[1] + inner_radius,
        ),
        fill=(204, 212, 232, 220),
    )

    needle = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    nd = ImageDraw.Draw(needle)
    nd.polygon(
        [
            (size * 0.5, size * 0.16),
            (size * 0.585, size * 0.53),
            (size * 0.5, size * 0.45),
            (size * 0.415, size * 0.53),
        ],
        fill=(214, 182, 131, 245),
    )
    nd.polygon(
        [
            (size * 0.5, size * 0.84),
            (size * 0.585, size * 0.47),
            (size * 0.5, size * 0.55),
            (size * 0.415, size * 0.47),
        ],
        fill=(111, 122, 146, 235),
    )
    needle = needle.rotate(18, resample=Image.Resampling.BICUBIC, center=center)
    base.alpha_composite(needle)

    slash = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sd = ImageDraw.Draw(slash)
    sd.rounded_rectangle(
        (size * 0.28, size * 0.47, size * 0.72, size * 0.53),
        radius=size * 0.03,
        fill=(204, 212, 232, 36),
    )
    slash = slash.rotate(-28, resample=Image.Resampling.BICUBIC, center=center)
    base.alpha_composite(slash)

    return base


def main() -> None:
    ICONSET.mkdir(parents=True, exist_ok=True)

    for size in SIZES:
        image = create_icon(size)
        image.save(ICONSET / f"icon_{size}x{size}.png")
        if size <= 512:
            image.resize((size * 2, size * 2), Image.Resampling.LANCZOS).save(
                ICONSET / f"icon_{size}x{size}@2x.png"
            )

    if shutil.which("iconutil") is None:
        raise SystemExit("iconutil is required to build AppIcon.icns")

    if ICNS.exists():
        ICNS.unlink()

    subprocess.run([
        "iconutil",
        "-c",
        "icns",
        str(ICONSET),
        "-o",
        str(ICNS),
    ], check=True)


if __name__ == "__main__":
    main()
