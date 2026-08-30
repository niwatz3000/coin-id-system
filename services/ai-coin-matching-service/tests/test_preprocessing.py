import io

from PIL import Image

from app.preprocessing import preprocess_image, TARGET_SIZE


def _sample_png_bytes() -> bytes:
    img = Image.new("RGB", (800, 600), color=(120, 60, 20))
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return buf.getvalue()


def test_preprocess_image_resizes_and_converts_to_rgb():
    raw = _sample_png_bytes()
    result = preprocess_image(raw)

    assert result.size == TARGET_SIZE
    assert result.mode == "RGB"
