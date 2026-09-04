"""OMS chart export and image post-processing (P1) — macOS SPSS.

SPSS Statistics 32 for macOS compatibility (verified on 32.0.0):

* ``OMS /DESTINATION FORMAT=IMAGE`` plus ``IMAGEROOT`` was removed from SPSS
  and is rejected with ``Unknown keyword or subcommand: IMAGE``.
* ``FORMAT=HTML IMAGES=YES OUTFILE=...`` is the supported export path: SPSS
  writes the HTML file verbatim and embeds every chart as a base64
  ``data:image/png`` URI.  ``IMAGEFORMAT`` is ignored for HTML (a TIFF request
  still comes back as PNG, which :mod:`spss_mcp.chart_service` then converts)
  and ``IMAGEWIDTH``/``IMAGEHEIGHT`` are rejected.

Vector EMF output is intentionally unsupported: SPSS for macOS does not emit
Windows EMF metafiles, so the exported formats are PNG and TIFF only.
"""

from __future__ import annotations

import base64
import re
from pathlib import Path
from typing import Optional

from spss_mcp.chart_spec import ImageFormat

IMAGE_FORMATS: tuple[str, ...] = ("PNG", "TIFF")

_EMBEDDED_IMAGE_RE = re.compile(r"data:image/(\w+);base64,([A-Za-z0-9+/=]+)")


def build_oms_image_block(
    html_outfile: str,
    image_format: ImageFormat = "PNG",
) -> str:
    """Return the OMS HTML block that captures charts into an HTML file.

    SPSS 32 embeds each chart as a base64 PNG inside the HTML file written to
    ``html_outfile`` (used verbatim, no extension is appended).  ``IMAGEFORMAT``
    is accepted but ignored - HTML always embeds PNG regardless of the value,
    so a TIFF request is post-processed from that PNG by the caller.
    """
    fmt = image_format.upper()
    if fmt not in IMAGE_FORMATS:
        raise ValueError(f"Unsupported image format: {image_format}")
    out_fwd = html_outfile.replace("\\", "/")
    return (
        "OMS /TAG='IMG1' /SELECT CHARTS\n"
        "  /DESTINATION FORMAT=HTML\n"
        "    IMAGES=YES\n"
        f"    IMAGEFORMAT={fmt}\n"
        f"    OUTFILE='{out_fwd}'.\n"
    )


def oms_image_end_block() -> str:
    """Return the OMSEND matching the IMG1 tag."""
    return "OMSEND TAG='IMG1'.\n"


def extract_html_images(html_path: Path, imageroot: str) -> list[Path]:
    """Decode charts embedded as base64 data URIs in an SPSS HTML export.

    Produces ``<imageroot>_001.png``, ``<imageroot>_002.png`` ... next to the
    HTML file and returns their paths.
    """
    if not html_path.exists():
        raise ValueError(f"HTML export not found: {html_path}")
    text = html_path.read_text(encoding="utf-8", errors="replace")
    uris = _EMBEDDED_IMAGE_RE.findall(text)
    if not uris:
        raise ValueError(f"No embedded chart image found in {html_path}")
    files: list[Path] = []
    for i, (fmt, b64) in enumerate(uris, start=1):
        ext = ".png" if fmt.lower() == "png" else f".{fmt.lower()}"
        out = html_path.parent / f"{imageroot}_{i:03d}{ext}"
        out.write_bytes(base64.b64decode(b64))
        files.append(out)
    return sorted(files)


def find_image_files(output_dir: Path, imageroot: str) -> list[Path]:
    """Return produced image files matching ``imageroot`` inside the dir."""
    pattern = f"{imageroot}*"
    return sorted(
        p
        for p in output_dir.glob(pattern)
        if p.suffix.lower() in {".png", ".tif", ".tiff"}
    )


def _resampling_lanczos():
    """Return Pillow's Lanczos resampling constant across versions."""
    from PIL import Image

    return getattr(Image, "Resampling", Image).LANCZOS


def validate_image(
    path: Path,
    expected_format: str = "PNG",
    min_width: int = 100,
    min_height: int = 100,
    dpi: int = 300,
    target_width: Optional[int] = None,
    target_height: Optional[int] = None,
) -> dict:
    """Validate an exported chart image with Pillow.

    Returns metadata; raises ``ValueError`` when the file is missing, empty,
    unreadable, or smaller than the minimum dimensions.  When ``target_width``
    and ``target_height`` are given the image is resized (Lanczos) to that size
    first.  For PNG the DPI metadata is rewritten to the requested value.
    """
    if not path.exists():
        raise ValueError(f"Image file not found: {path}")
    if path.stat().st_size == 0:
        raise ValueError(f"Image file is empty: {path}")

    try:
        from PIL import Image
    except ImportError as exc:  # pragma: no cover - dependency is declared
        raise ValueError("Pillow is required for image validation") from exc

    try:
        with Image.open(path) as img:
            width, height = img.size
            fmt = (img.format or "").upper()
        if width < min_width or height < min_height:
            raise ValueError(
                f"Image too small: {width}x{height} (min {min_width}x{min_height})"
            )
    except Exception as exc:
        if isinstance(exc, ValueError):
            raise
        raise ValueError(f"Unreadable image file {path}: {exc}") from exc

    if fmt != expected_format.upper():
        raise ValueError(f"Unexpected image format: {fmt} (expected {expected_format})")

    # Resize to the requested paper dimensions, then rewrite DPI metadata.
    if (
        target_width
        and target_height
        and (width != target_width or height != target_height)
    ):
        with Image.open(path) as img:
            img = img.convert("RGB") if img.mode != "RGB" else img
            img = img.resize((target_width, target_height), _resampling_lanczos())
            img.save(path, format="PNG", dpi=(dpi, dpi))
        width, height = target_width, target_height
    elif fmt == "PNG" and dpi:
        with Image.open(path) as img:
            img.save(path, format="PNG", dpi=(dpi, dpi))

    return {
        "path": str(path),
        "format": fmt,
        "width": width,
        "height": height,
        "bytes": path.stat().st_size,
        "dpi": dpi,
    }
