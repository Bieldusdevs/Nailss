from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageOps
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
import requests, re, json
root = Path(__file__).resolve().parents[1]
working = root / '.cache/artwork-fonts'
working.mkdir(parents=True, exist_ok=True)
for name, weight in [('syne', 600), ('jakarta', 400)]:
    source = TTFont(root / f'public/fonts/{name}.woff2')
    source.flavor = None
    source = instantiateVariableFont(source, {'wght': weight}, inplace=True)
    source.save(working / f'{name}.ttf')
cream, forest, rose = '#F8F4EE', '#283F35', '#A84F65'
def font(name, size):
    return ImageFont.truetype(str(working / f'{name}.ttf'), size)
def centered(draw, y, text, face, fill, width):
    draw.text(((width - draw.textlength(text, font=face)) / 2, y), text, font=face, fill=fill)
brand = Image.open(root / 'public/icons/icon-512.png').convert('RGB')
screens = [(375,667,2),(375,812,3),(390,844,3),(393,852,3),(414,896,3),(428,926,3),(430,932,3),(768,1024,2),(834,1194,2),(1024,1366,2)]
links = []
(root / 'public/splash').mkdir(exist_ok=True)
for width, height, ratio in screens:
    w, h = width * ratio, height * ratio
    image = Image.new('RGB', (w, h), cream)
    draw = ImageDraw.Draw(image)
    size = 96 * ratio
    icon = brand.resize((size, size), Image.Resampling.LANCZOS)
    image.paste(icon, ((w - size) // 2, h // 2 - 100 * ratio))
    centered(draw, h // 2 + 12 * ratio, 'LUMIÈRE', font('syne', 35 * ratio), forest, w)
    centered(draw, h // 2 + 61 * ratio, 'NAIL ATELIER', font('jakarta', 9 * ratio), rose, w)
    filename = f'splash-{w}x{h}.png'
    image.save(root / 'public/splash' / filename, optimize=True)
    links.append({'url': '/splash/' + filename, 'media': f'(device-width: {width}px) and (device-height: {height}px) and (-webkit-device-pixel-ratio: {ratio}) and (orientation: portrait)'})
(root / 'src/core/lib/atelier-splash.ts').write_text('export const atelierSplashScreens = ' + json.dumps(links, indent=2) + ';\n')
image = Image.new('RGB', (1200, 630), cream)
draw = ImageDraw.Draw(image)
draw.line((54, 97, 1146, 97), fill='#E1D6C8', width=1)
draw.text((62, 39), 'LUMIÈRE', font=font('syne', 32), fill=forest)
draw.text((65, 156), 'ARTE MANUAL. CUIDADO ARTESANAL.', font=font('jakarta', 12), fill=rose)
draw.text((62, 210), 'O seu brilho.', font=font('syne', 62), fill=forest)
draw.text((62, 281), 'A nossa arte.', font=font('syne', 62), fill=rose)
draw.text((65, 389), 'Um momento só seu. No coração de Lisboa.', font=font('jakarta', 17), fill='#757D71')
draw.rounded_rectangle((64, 456, 342, 504), radius=24, fill=rose)
draw.text((91, 470), 'Marcar o meu momento', font=font('jakarta', 14), fill='white')
draw.text((65, 555), 'LUMIERE-NAIL.PT', font=font('jakarta', 11), fill=forest)
photo = ImageOps.fit(Image.open(root / 'public/images/hero-editorial.jpg'), (435, 500))
mask = Image.new('L', (435, 500))
shape = ImageDraw.Draw(mask)
shape.rounded_rectangle((0, 190, 434, 499), radius=15, fill=255)
shape.rectangle((0, 210, 434, 475), fill=255)
shape.ellipse((0, 0, 434, 420), fill=255)
image.paste(photo, (701, 111), mask)
image.save(root / 'public/images/social-card.jpg', quality=91, optimize=True)
names = set((root / 'docs/material-symbols-subset.txt').read_text().split())
for path in (root / 'src').rglob('*'):
    if path.suffix not in ('.ts', '.tsx'):
        continue
    text = path.read_text()
    names.update(re.findall(r'(?:icon|name):\s*[\'"]([a-z_]+)[\'"]', text))
    names.update(re.findall(r'name="([a-z_]+)"', text))
names.update(['hand_gesture', 'water_drop', 'auto_awesome'])
url = 'https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&icon_names=' + ','.join(sorted(names)) + '&display=block'
css = requests.get(url, headers={'User-Agent': 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'}, timeout=30)
css.raise_for_status()
font_url = re.findall(r'url\((https[^)]+)\)', css.text)[-1]
data = requests.get(font_url, timeout=30)
data.raise_for_status()
(root / 'public/fonts/symbols.woff2').write_bytes(data.content)
(root / 'docs/material-symbols-subset.txt').write_text('\n'.join(sorted(names)) + '\n')
print('Created 10 Apple startup images, an Open Graph card and the used icon subset.')
