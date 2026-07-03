from PIL import Image, ImageDraw, ImageFont
import os, math

SIZE = 1024
R = 180

def draw_user_icon():
    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([(0, 0), (SIZE, SIZE)], radius=R, fill=(0, 74, 128))
    for i in range(SIZE):
        r = int(0 + (0) * i / SIZE)
        g = int(74 + (128) * i / SIZE)
        b = int(128 + (200) * i / SIZE)
        a = int(160 * i / SIZE)
        draw.line([(0, i), (SIZE, i)], fill=(r, g, b, a))
    cx, cy = SIZE // 2, SIZE // 2 - 20
    hull = [(cx - 200, cy + 40), (cx + 200, cy + 40), (cx + 260, cy + 160), (cx - 260, cy + 160)]
    draw.polygon(hull, fill=(255, 255, 255, 240))
    draw.rectangle([(cx - 8, cy - 180), (cx + 8, cy + 40)], fill=(255, 255, 255, 240))
    sail = [(cx + 8, cy - 160), (cx + 220, cy + 20), (cx + 8, cy + 20)]
    draw.polygon(sail, fill=(255, 255, 255, 200))
    flag = [(cx - 8, cy - 180), (cx + 60, cy - 200), (cx - 8, cy - 220)]
    draw.polygon(flag, fill=(100, 210, 255, 240))
    draw.arc([(cx - 240, cy + 120), (cx + 240, cy + 280)], 0, 180, fill=(255, 255, 255, 60), width=8)
    return img

def draw_driver_icon():
    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([(0, 0), (SIZE, SIZE)], radius=R, fill=(180, 60, 0))
    for i in range(SIZE):
        r = int(180 + (230) * i // SIZE)
        g = int(60 + (130) * i // SIZE)
        b = int(0 + (0) * i // SIZE)
        a = int(160 * i // SIZE)
        draw.line([(0, i), (SIZE, i)], fill=(r, g, b, a))
    cx, cy = SIZE // 2, SIZE // 2 - 10
    draw.ellipse([(cx - 220, cy - 220), (cx + 220, cy + 220)], fill=None, outline=(255, 255, 255, 240), width=28)
    draw.ellipse([(cx - 60, cy - 60), (cx + 60, cy + 60)], fill=(255, 255, 255, 240))
    for angle in [0, 120, 240]:
        rad = math.radians(angle - 90)
        x1 = cx + int(60 * math.cos(rad))
        y1 = cy + int(60 * math.sin(rad))
        x2 = cx + int(200 * math.cos(rad))
        y2 = cy + int(200 * math.sin(rad))
        draw.line([(x1, y1), (x2, y2)], fill=(255, 255, 255, 240), width=26)
    arrow = [(cx, cy - 280), (cx - 50, cy - 200), (cx + 50, cy - 200)]
    draw.polygon(arrow, fill=(255, 220, 50, 230))
    return img

def resize_for_android(base_path, img, sizes):
    for density, size in sizes.items():
        d = os.path.join(base_path, f'mipmap-{density}')
        os.makedirs(d, exist_ok=True)
        resized = img.resize((size, size), Image.LANCZOS)
        resized.save(os.path.join(d, 'ic_launcher.png'))

def main():
    user_img = draw_user_icon()
    driver_img = draw_driver_icon()
    android_base = os.path.join(os.path.dirname(__file__), '..', 'android', 'app', 'src')
    sizes = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}
    resize_for_android(os.path.join(android_base, 'user', 'res'), user_img, sizes)
    resize_for_android(os.path.join(android_base, 'driver', 'res'), driver_img, sizes)
    resize_for_android(os.path.join(android_base, 'main', 'res'), user_img, sizes)
    print("Android icons done: user/, driver/, main/")
    ios_base = os.path.join(os.path.dirname(__file__), '..', 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
    os.makedirs(ios_base, exist_ok=True)
    ios_sizes = [
        ('Icon-App-20x20@1x.png', 20), ('Icon-App-20x20@2x.png', 40), ('Icon-App-20x20@3x.png', 60),
        ('Icon-App-29x29@1x.png', 29), ('Icon-App-29x29@2x.png', 58), ('Icon-App-29x29@3x.png', 87),
        ('Icon-App-40x40@1x.png', 40), ('Icon-App-40x40@2x.png', 80), ('Icon-App-40x40@3x.png', 120),
        ('Icon-App-60x60@2x.png', 120), ('Icon-App-60x60@3x.png', 180),
        ('Icon-App-76x76@1x.png', 76), ('Icon-App-76x76@2x.png', 152),
        ('Icon-App-83.5x83.5@2x.png', 167), ('Icon-App-1024x1024@1x.png', 1024),
    ]
    for fname, sz in ios_sizes:
        u = user_img.resize((sz, sz), Image.LANCZOS)
        u.save(os.path.join(ios_base, fname))
    print("iOS icons done")

if __name__ == '__main__':
    main()
