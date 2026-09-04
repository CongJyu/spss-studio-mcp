import base64
from pathlib import Path

import pytest

from spss_mcp.oms_image import (
    build_oms_image_block,
    extract_html_images,
    find_image_files,
    oms_image_end_block,
    validate_image,
)


def test_build_oms_image_block():
    block = build_oms_image_block(r"C:\temp\charts\hist_abc.html", image_format="PNG")
    assert "/TAG='IMG1' /SELECT CHARTS" in block
    assert "FORMAT=HTML" in block
    assert "IMAGES=YES" in block
    assert "IMAGEFORMAT=PNG" in block
    assert "OUTFILE='C:/temp/charts/hist_abc.html'" in block


def test_build_oms_image_block_tiff():
    block = build_oms_image_block("/tmp/charts/hist_abc.html", image_format="TIFF")
    assert "IMAGEFORMAT=TIFF" in block


def test_unsupported_format_raises():
    with pytest.raises(ValueError):
        build_oms_image_block("C:/tmp/root.html", image_format="GIF")


def test_oms_image_end_block():
    assert oms_image_end_block() == "OMSEND TAG='IMG1'.\n"


def test_extract_html_images(tmp_path):
    png = base64.b64encode(b"fake-png-bytes").decode()
    html = tmp_path / "chart.html"
    html.write_text(f'<img src="data:image/png;base64,{png}">', encoding="utf-8")
    files = extract_html_images(html, "hist")
    assert [f.name for f in files] == ["hist_001.png"]
    assert files[0].read_bytes() == b"fake-png-bytes"


def test_extract_html_images_missing_file(tmp_path):
    with pytest.raises(ValueError, match="not found"):
        extract_html_images(tmp_path / "nope.html", "hist")


def test_extract_html_images_no_image(tmp_path):
    html = tmp_path / "chart.html"
    html.write_text("<html></html>", encoding="utf-8")
    with pytest.raises(ValueError, match="No embedded chart image"):
        extract_html_images(html, "hist")


def test_find_image_files(tmp_path):
    (tmp_path / "scatter_001.png").write_bytes(b"x")
    (tmp_path / "scatter_002.png").write_bytes(b"x")
    (tmp_path / "other_001.png").write_bytes(b"x")
    files = find_image_files(tmp_path, "scatter")
    assert [f.name for f in files] == ["scatter_001.png", "scatter_002.png"]


def test_validate_image_ok(tmp_path):
    from PIL import Image

    png = tmp_path / "chart.png"
    Image.new("RGB", (200, 150), "white").save(png)
    meta = validate_image(png, expected_format="PNG", dpi=300)
    assert meta["width"] == 200
    assert meta["height"] == 150
    assert meta["format"] == "PNG"
    assert meta["dpi"] == 300


def test_validate_image_resizes(tmp_path):
    from PIL import Image

    png = tmp_path / "chart.png"
    Image.new("RGB", (200, 150), "white").save(png)
    meta = validate_image(
        png, expected_format="PNG", dpi=300, target_width=400, target_height=300
    )
    assert meta["width"] == 400
    assert meta["height"] == 300


def test_validate_image_missing(tmp_path):
    with pytest.raises(ValueError, match="not found"):
        validate_image(tmp_path / "nope.png")


def test_validate_image_empty(tmp_path):
    empty = tmp_path / "empty.png"
    empty.write_bytes(b"")
    with pytest.raises(ValueError, match="empty"):
        validate_image(empty)


def test_validate_image_wrong_format(tmp_path):
    from PIL import Image

    jpg = tmp_path / "chart.jpg"
    Image.new("RGB", (200, 150), "white").save(jpg, format="JPEG")
    with pytest.raises(ValueError, match="Unexpected image format"):
        validate_image(jpg, expected_format="PNG")


