"""Image preprocessing before AI model inference."""
import io
import logging

from PIL import Image, ImageOps

logger = logging.getLogger(__name__)

TARGET_SIZE = (224, 224)


def preprocess_image(raw_bytes: bytes) -> Image.Image:
    """Loads raw image bytes, normalizes orientation, converts to RGB,
    and resizes to the model's expected input dimensions.
    """
    image = Image.open(io.BytesIO(raw_bytes))
    image = ImageOps.exif_transpose(image)  # fix camera rotation
    image = image.convert("RGB")
    image = ImageOps.fit(image, TARGET_SIZE, method=Image.LANCZOS)
    return image


def image_to_bytes(image: Image.Image, fmt: str = "JPEG") -> bytes:
    buffer = io.BytesIO()
    image.save(buffer, format=fmt, quality=90)
    return buffer.getvalue()
