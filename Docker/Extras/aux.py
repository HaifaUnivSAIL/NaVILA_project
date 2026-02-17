from PIL import Image
import numpy as np

def save_image(image, out_path):
    img = image.permute(1, 2, 0).cpu().numpy()
    img = ((img+1)/2 * 255).astype(np.uint8)
    Image.fromarray(img).save(out_path)
