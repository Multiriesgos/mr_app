"""
Generador de Screenshots de Google Play para Multiriesgos
1080x1920px (9:16) — 6 pantallas
"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os, math

# ─── Rutas ──────────────────────────────────────────────────
BASE    = r'C:\tools\mr_app'
ASSETS  = os.path.join(BASE, 'assets')
IMGS    = os.path.join(ASSETS, 'images')
FONTS   = os.path.join(ASSETS, 'fonts')
RES     = os.path.join(BASE, 'android', 'app', 'src', 'main', 'res')
OUT     = os.path.join(RES, 'screenshots')
os.makedirs(OUT, exist_ok=True)

# ─── Dimensiones ────────────────────────────────────────────
W, H        = 1080, 1920
PAD         = 64          # padding lateral
STATUS_H    = 90          # altura barra estado
HEADER_H    = 200         # altura total header azul
NAV_H       = 150         # altura nav bar inferior
CONTENT_TOP = HEADER_H    # primera pantalla sin header usa STATUS_H

# ─── Colores ────────────────────────────────────────────────
BLUE        = (19,  99,  223)
BLUE_DARK   = (10,  58,  160)
BLUE_LIGHT  = (235, 242, 255)
BLUE_ACCENT = (77,  148, 255)
ORANGE      = (245, 124,  0 )
WHITE       = (255, 255, 255)
OFF_WHITE   = (248, 249, 252)
DARK        = ( 18,  18,  36)
GRAY        = (107, 114, 128)
LIGHT_GRAY  = (229, 231, 235)
DIVIDER     = (241, 242, 244)
GREEN       = ( 16, 185, 129)
RED_COLOR   = (239,  68,  68)
CARD_SHADOW = (200, 210, 230)

# ─── Fuentes ────────────────────────────────────────────────
def F(weight, size):
    files = {
        'bold':    'WorkSans-Bold.ttf',
        'semi':    'WorkSans-SemiBold.ttf',
        'medium':  'WorkSans-Medium.ttf',
        'regular': 'WorkSans-Regular.ttf',
    }
    return ImageFont.truetype(os.path.join(FONTS, files[weight]), size)

# ─── Helpers ────────────────────────────────────────────────
def new_screen(bg=OFF_WHITE):
    return Image.new('RGB', (W, H), bg)

def draw_status(img, dark_fg=False):
    d = ImageDraw.Draw(img)
    fg = DARK if dark_fg else WHITE
    f = F('semi', 38)
    d.text((PAD, 25), '9:41', fill=fg, font=f)
    # Batería
    bx = W - PAD - 4
    d.rounded_rectangle([bx-60, 28, bx, 62], radius=5, outline=fg, width=3)
    d.rectangle([bx, 38, bx+8, 52], fill=fg)
    d.rounded_rectangle([bx-56, 32, bx-14, 58], radius=3, fill=fg)
    # WiFi (3 arcos simplificados con rectángulos)
    wx = bx - 80
    for i, (bh, bw2) in enumerate([(10,4),(18,8),(26,12)]):
        d.rectangle([wx-bw2, 58-bh, wx+bw2, 58], fill=fg)
        wx -= 22

def text_c(draw, txt, y, fnt, color=DARK, x0=0, x1=W):
    bb = draw.textbbox((0,0), txt, font=fnt)
    tw = bb[2]-bb[0]
    draw.text((x0 + (x1-x0-tw)//2, y), txt, fill=color, font=fnt)

def card(img, x, y, w, h, r=28, fill=WHITE, border=None):
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([x+4, y+4, x+w+4, y+h+4], radius=r, fill=CARD_SHADOW)
    d.rounded_rectangle([x, y, x+w, y+h], radius=r, fill=fill,
                        outline=border, width=2 if border else 0)
    return d

def pill_button(draw, x, y, w, h, label, fnt, bg, fg, r=None):
    r = r or h//2
    draw.rounded_rectangle([x, y, x+w, y+h], radius=r, fill=bg)
    bb = draw.textbbox((0,0), label, font=fnt)
    tw, th = bb[2]-bb[0], bb[3]-bb[1]
    draw.text((x+(w-tw)//2, y+(h-th)//2 - 4), label, fill=fg, font=fnt)

def divider(draw, y):
    draw.rectangle([PAD, y, W-PAD, y+1], fill=DIVIDER)

def blue_header(img, title, subtitle=None, show_back=True, active_tab=None):
    """Cabecera azul con status bar"""
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, W, HEADER_H], fill=BLUE)
    draw_status(img)
    # Flecha atrás
    if show_back:
        bx, by = PAD+6, STATUS_H + 36
        d.line([(bx+22, by-18), (bx, by+2), (bx+22, by+22)], fill=WHITE, width=6)
    tx = PAD + (42 if show_back else 0)
    d.text((tx, STATUS_H + 20), title, fill=WHITE, font=F('bold', 56))
    if subtitle:
        d.text((tx, STATUS_H + 82), subtitle, fill=BLUE_ACCENT, font=F('regular', 34))

def nav_bar(img, active=0):
    """Barra de navegación inferior"""
    d = ImageDraw.Draw(img)
    y0 = H - NAV_H
    d.rectangle([0, y0, W, H], fill=WHITE)
    d.rectangle([0, y0, W, y0+2], fill=LIGHT_GRAY)
    tabs = [
        ('⌂', 'Inicio'),
        ('◆', 'Beneficios'),
        ('↕', 'Movimientos'),
        ('☰', 'Más'),
    ]
    iw = W // len(tabs)
    for i, (ico, lbl) in enumerate(tabs):
        cx = i*iw + iw//2
        color = BLUE if i==active else GRAY
        # Ícono (círculo simple)
        ir = 28
        if i == active:
            d.ellipse([cx-ir, y0+16, cx+ir, y0+16+2*ir], fill=BLUE_LIGHT)
        ico_f = F('bold', 44)
        bb = d.textbbox((0,0), ico, font=ico_f)
        d.text((cx-(bb[2]-bb[0])//2, y0+12), ico, fill=color, font=ico_f)
        lbl_f = F('medium', 28)
        bb2 = d.textbbox((0,0), lbl, font=lbl_f)
        d.text((cx-(bb2[2]-bb2[0])//2, y0+80), lbl, fill=color, font=lbl_f)

# ────────────────────────────────────────────────────────────
# PANTALLA 1 — LOGIN
# ────────────────────────────────────────────────────────────
def screen_login():
    img = new_screen(WHITE)
    d = ImageDraw.Draw(img)

    # Fondo superior azul
    d.rectangle([0, 0, W, 520], fill=BLUE)
    draw_status(img)

    # Logo
    logo = Image.open(os.path.join(IMGS, '5_fit.png')).convert('RGBA')
    lw, lh = logo.size
    scale = min(740/lw, 280/lh)
    logo = logo.resize((int(lw*scale), int(lh*scale)), Image.LANCZOS)
    lx = (W - logo.width)//2
    ly = STATUS_H + 30
    img.paste(logo, (lx, ly), logo)

    # Tarjeta blanca
    cy = 480
    card(img, PAD-10, cy, W-2*PAD+20, 1100, r=36, fill=WHITE)
    d = ImageDraw.Draw(img)

    # Textos bienvenida
    d.text((PAD+30, cy+50), 'Bienvenido', fill=DARK, font=F('bold', 62))
    d.text((PAD+30, cy+120), 'Ingresa tus datos para continuar', fill=GRAY, font=F('regular', 36))

    # Campo: Número de Documento
    f1y = cy + 220
    d.rounded_rectangle([PAD+20, f1y, W-PAD-20, f1y+100], radius=16,
                        outline=LIGHT_GRAY, fill=OFF_WHITE, width=2)
    d.text((PAD+50, f1y+12), 'Número de Documento', fill=GRAY, font=F('regular', 30))
    d.text((PAD+50, f1y+52), '01234567-8', fill=DARK, font=F('medium', 38))

    # Campo: Fecha de Nacimiento
    f2y = f1y + 136
    d.rounded_rectangle([PAD+20, f2y, W-PAD-20, f2y+100], radius=16,
                        outline=BLUE, fill=WHITE, width=2)
    d.text((PAD+50, f2y+12), 'Fecha de Nacimiento', fill=BLUE, font=F('regular', 30))
    d.text((PAD+50, f2y+52), 'DD/MM/AAAA', fill=GRAY, font=F('medium', 38))

    # Checkbox "Recordar cliente"
    cby = f2y + 136
    d.rounded_rectangle([PAD+20, cby+4, PAD+56, cby+40], radius=6,
                        fill=BLUE, outline=BLUE, width=2)
    d.text((PAD+24, cby+2), '✓', fill=WHITE, font=F('bold', 36))
    d.text((PAD+70, cby), 'Recordar mis datos', fill=GRAY, font=F('regular', 36))

    # Botón INGRESAR
    btn1y = cby + 90
    pill_button(d, PAD+20, btn1y, W-2*PAD-40, 108, 'INGRESAR', F('bold', 44), BLUE, WHITE)

    # Botón COTIZAR
    btn2y = btn1y + 140
    pill_button(d, PAD+20, btn2y, W-2*PAD-40, 108, 'COTIZAR', F('bold', 44), ORANGE, WHITE)

    # Versión
    text_c(d, 'Versión 2.1.0', H-60, F('regular', 30), GRAY)

    img.save(os.path.join(OUT, 'ss1_login.png'), 'PNG')
    print('✓ ss1_login.png')

# ────────────────────────────────────────────────────────────
# PANTALLA 2 — HOME / DASHBOARD
# ────────────────────────────────────────────────────────────
def screen_home():
    img = new_screen(OFF_WHITE)
    d = ImageDraw.Draw(img)

    # Header extendido
    d.rounded_rectangle([0, 0, W, 380], radius=0, fill=BLUE)
    d.rounded_rectangle([0, 280, W, 420], radius=40, fill=BLUE)
    draw_status(img)

    # Saludo
    d.text((PAD, STATUS_H+20), 'Hola, Carlos', fill=WHITE, font=F('bold', 58))
    d.text((PAD, STATUS_H+84), 'Bienvenido a tu portal', fill=BLUE_ACCENT, font=F('regular', 36))

    # Avatar (círculo)
    av_r = 52
    av_x, av_y = W-PAD-av_r, STATUS_H+60
    d.ellipse([av_x-av_r, av_y-av_r, av_x+av_r, av_y+av_r], fill=WHITE)
    d.text((av_x-28, av_y-30), 'CM', fill=BLUE, font=F('bold', 48))

    # Tarjeta de pólizas activas
    c1y = 330
    card(img, PAD, c1y, W-2*PAD, 300, r=32, fill=BLUE_DARK)
    d = ImageDraw.Draw(img)
    # Decoración interna de la tarjeta
    d.ellipse([W-PAD-220, c1y-40, W-PAD+80, c1y+260], fill=(30,80,190))
    d.ellipse([W-PAD-160, c1y+100, W-PAD+40, c1y+340], fill=(25,70,175))

    d.text((PAD+36, c1y+28), 'Pólizas activas', fill=(180,210,255), font=F('regular', 34))
    d.text((PAD+36, c1y+72), '3', fill=WHITE, font=F('bold', 110))
    d.text((PAD+36, c1y+190), 'Última actualización: hoy', fill=(160,200,255), font=F('regular', 30))

    badge_x = W - PAD - 240
    d.rounded_rectangle([badge_x, c1y+220, badge_x+200, c1y+265], radius=20, fill=GREEN)
    text_c(d, 'AL DÍA', c1y+226, F('bold', 32), WHITE, badge_x, badge_x+200)

    # Botones de acción rápida
    by = c1y + 360
    actions = [('Enviar', BLUE), ('Recibir', GREEN), ('QR Pago', ORANGE)]
    aw = (W - 2*PAD - 30) // 3
    for i, (lbl, col) in enumerate(actions):
        ax = PAD + i*(aw+15)
        card(img, ax, by, aw, 130, r=22, fill=WHITE)
        d = ImageDraw.Draw(img)
        d.ellipse([ax+aw//2-28, by+14, ax+aw//2+28, by+70], fill=col)
        lf = F('medium', 30)
        bb = d.textbbox((0,0), lbl, font=lf)
        d.text((ax+(aw-(bb[2]-bb[0]))//2, by+82), lbl, fill=DARK, font=lf)

    # Menú circular
    my = by + 196
    d.text((PAD, my), 'Servicios', fill=DARK, font=F('semi', 42))
    services = [
        ('◉', 'Mis\nSeguros'),
        ('⊕', 'Gestionar\nPólizas'),
        ('✉', 'Notifi-\ncaciones'),
        ('☎', 'Contac-\ntarnos'),
    ]
    sw = (W-2*PAD-30)//4
    sy = my + 64
    for i, (ico, lbl) in enumerate(services):
        sx = PAD + i*(sw+10)
        card(img, sx, sy, sw, 170, r=22, fill=WHITE)
        d = ImageDraw.Draw(img)
        d.ellipse([sx+sw//2-36, sy+14, sx+sw//2+36, sy+86], fill=BLUE_LIGHT)
        if_ico = F('bold', 46)
        bb = d.textbbox((0,0), ico, font=if_ico)
        d.text((sx+sw//2-(bb[2]-bb[0])//2, sy+22), ico, fill=BLUE, font=if_ico)
        lf = F('regular', 26)
        lines = lbl.split('\n')
        for li, line in enumerate(lines):
            bb2 = d.textbbox((0,0), line, font=lf)
            d.text((sx+sw//2-(bb2[2]-bb2[0])//2, sy+100+li*32), line, fill=DARK, font=lf)

    # Promociones
    py = sy + 230
    d.text((PAD, py), 'Promociones', fill=DARK, font=F('semi', 42))
    promo = Image.open(os.path.join(IMGS, 'Promo_card.png')).convert('RGB')
    pw = W - 2*PAD
    ph = int(promo.height * pw / promo.width)
    promo = promo.resize((pw, min(ph, 180)), Image.LANCZOS)
    img.paste(promo, (PAD, py+60))

    nav_bar(img, active=0)
    img.save(os.path.join(OUT, 'ss2_home.png'), 'PNG')
    print('✓ ss2_home.png')

# ────────────────────────────────────────────────────────────
# PANTALLA 3 — MIS BENEFICIOS
# ────────────────────────────────────────────────────────────
def screen_beneficios():
    img = new_screen(OFF_WHITE)
    blue_header(img, 'Mis Beneficios', 'Carnet Digital', show_back=False)
    d = ImageDraw.Draw(img)

    # Carnet (Card-bg-1)
    carnet = Image.open(os.path.join(IMGS, 'Card-bg-1.png')).convert('RGB')
    cw = W - 2*PAD
    ch = int(carnet.height * cw / carnet.width)
    carnet = carnet.resize((cw, ch), Image.LANCZOS)
    cy = HEADER_H + 40
    # Sombra
    shadow = Image.new('RGB', (cw+8, ch+8), CARD_SHADOW)
    img.paste(shadow, (PAD-4+4, cy+4))
    img.paste(carnet, (PAD-4, cy))
    d = ImageDraw.Draw(img)

    # Etiqueta nombre sobre el carnet
    d.text((PAD+20, cy+ch//2-20), 'Carlos Martínez', fill=DARK, font=F('bold', 40))
    d.text((PAD+20, cy+ch//2+30), 'DUI: 01234567-8', fill=GRAY, font=F('regular', 34))

    # Sección portales
    py = cy + ch + 50
    d.text((PAD, py), 'Accesos rápidos', fill=DARK, font=F('semi', 44))
    py += 60

    portals = [
        ('Red Médica', 'Consulta médicos\ny especialistas', BLUE, 'logo_medic.jpg'),
        ('Club Ahorro', 'Descuentos y\nbeneficios exclusivos', GREEN, 'logo_clubahorroblanco.png'),
    ]
    ph2 = 200
    pw2 = (W - 2*PAD - 20)//2
    for i, (title, desc, color, logo_file) in enumerate(portals):
        px = PAD + i*(pw2+20)
        card(img, px, py, pw2, ph2, r=24, fill=WHITE)
        d = ImageDraw.Draw(img)
        # Banda de color superior
        d.rounded_rectangle([px, py, px+pw2, py+8], radius=0, fill=color)
        d.rounded_rectangle([px, py, px+pw2, py+8], radius=24, fill=color)

        try:
            logo_img = Image.open(os.path.join(IMGS, logo_file)).convert('RGBA')
            lh2 = 56
            lw2 = int(logo_img.width * lh2 / logo_img.height)
            logo_img = logo_img.resize((lw2, lh2), Image.LANCZOS)
            lx2 = px + (pw2-lw2)//2
            if logo_img.mode == 'RGBA':
                img.paste(logo_img, (lx2, py+24), logo_img)
            else:
                img.paste(logo_img, (lx2, py+24))
        except Exception:
            pass
        d = ImageDraw.Draw(img)
        tf = F('semi', 34)
        bb = d.textbbox((0,0), title, font=tf)
        d.text((px+(pw2-(bb[2]-bb[0]))//2, py+92), title, fill=DARK, font=tf)
        for li, line in enumerate(desc.split('\n')):
            lff = F('regular', 28)
            bb2 = d.textbbox((0,0), line, font=lff)
            d.text((px+(pw2-(bb2[2]-bb2[0]))//2, py+136+li*34), line, fill=GRAY, font=lff)

    nav_bar(img, active=1)
    img.save(os.path.join(OUT, 'ss3_beneficios.png'), 'PNG')
    print('✓ ss3_beneficios.png')

# ────────────────────────────────────────────────────────────
# PANTALLA 4 — MIS MOVIMIENTOS (Transactions)
# ────────────────────────────────────────────────────────────
def screen_movimientos():
    img = new_screen(OFF_WHITE)
    blue_header(img, 'Mis Movimientos', show_back=False)
    d = ImageDraw.Draw(img)

    # Resumen de balance
    sy = HEADER_H + 20
    card(img, PAD, sy, W-2*PAD, 130, r=24, fill=WHITE)
    d = ImageDraw.Draw(img)
    d.text((PAD+30, sy+18), 'Saldo disponible', fill=GRAY, font=F('regular', 32))
    d.text((PAD+30, sy+60), '$1,297.50', fill=DARK, font=F('bold', 60))

    # Filtros
    fy = sy + 160
    filters = [('Todos', True), ('Ingresos', False), ('Egresos', False)]
    fx = PAD
    for lbl, active in filters:
        fw2 = 200 if lbl=='Todos' else 220
        fg_col = WHITE if active else GRAY
        bg_col = BLUE if active else WHITE
        d.rounded_rectangle([fx, fy, fx+fw2, fy+60], radius=30,
                            fill=bg_col, outline=LIGHT_GRAY, width=2)
        lf = F('semi', 30)
        bb = d.textbbox((0,0), lbl, font=lf)
        d.text((fx+(fw2-(bb[2]-bb[0]))//2, fy+12), lbl, fill=fg_col, font=lf)
        fx += fw2 + 16

    # Lista de transacciones
    tx_data = [
        ('Póliza Automóvil',    'Renovación anual',      '-$340.00', RED_COLOR,  '15 Abr'),
        ('Póliza Vida',         'Pago mensual',          '-$85.00',  RED_COLOR,  '12 Abr'),
        ('Devolución seguro',   'Ajuste de prima',       '+$120.00', GREEN,      '08 Abr'),
        ('Póliza Hogar',        'Pago semestral',        '-$210.00', RED_COLOR,  '01 Abr'),
        ('Comisión reembolso',  'Siniestro aprobado',    '+$450.00', GREEN,      '28 Mar'),
        ('Póliza Vida Plus',    'Cuota mensual',         '-$120.00', RED_COLOR,  '25 Mar'),
    ]
    ty = fy + 90
    for i, (title, sub, amt, col, date) in enumerate(tx_data):
        item_h = 116
        iy = ty + i*item_h
        if iy + item_h > H - NAV_H - 10:
            break
        card(img, PAD, iy, W-2*PAD, 104, r=20, fill=WHITE)
        d = ImageDraw.Draw(img)
        # Ícono circular
        ir = 34
        ix = PAD + 30 + ir
        ic = GREEN if '+' in amt else RED_COLOR
        d.ellipse([ix-ir, iy+18, ix+ir, iy+18+2*ir], fill=ic+(50,) if len(ic)==3 else ic)
        arrow = '↑' if '+' in amt else '↓'
        af = F('bold', 44)
        bb = d.textbbox((0,0), arrow, font=af)
        d.text((ix-(bb[2]-bb[0])//2, iy+22), arrow, fill=col, font=af)
        # Texto
        d.text((PAD+90, iy+16), title, fill=DARK, font=F('semi', 34))
        d.text((PAD+90, iy+58), sub,   fill=GRAY, font=F('regular', 28))
        # Monto y fecha
        af2 = F('bold', 36)
        bb2 = d.textbbox((0,0), amt, font=af2)
        d.text((W-PAD-20-(bb2[2]-bb2[0]), iy+16), amt, fill=col, font=af2)
        df = F('regular', 28)
        bb3 = d.textbbox((0,0), date, font=df)
        d.text((W-PAD-20-(bb3[2]-bb3[0]), iy+60), date, fill=GRAY, font=df)

    nav_bar(img, active=2)
    img.save(os.path.join(OUT, 'ss4_movimientos.png'), 'PNG')
    print('✓ ss4_movimientos.png')

# ────────────────────────────────────────────────────────────
# PANTALLA 5 — MIS PÓLIZAS (Seguros)
# ────────────────────────────────────────────────────────────
def screen_polizas():
    img = new_screen(OFF_WHITE)
    blue_header(img, 'Mis Pólizas', 'Seguros activos', show_back=False)
    d = ImageDraw.Draw(img)

    polizas = [
        ('Seguro de Automóvil', 'Vehículo principal', 'POL-2024-0891', '31/12/2025', BLUE,   '🚗'),
        ('Seguro de Vida',       'Cobertura familiar', 'POL-2023-0234', '30/06/2026', GREEN,  '❤'),
        ('Seguro de Hogar',      'Residencia familiar','POL-2024-1102', '28/02/2026', ORANGE, '🏠'),
    ]

    py2 = HEADER_H + 30
    for i, (name, tipo, pol_num, vence, color, ico) in enumerate(polizas):
        ph3 = 240
        iy = py2 + i*(ph3+20)
        card(img, PAD, iy, W-2*PAD, ph3, r=28, fill=WHITE)
        d = ImageDraw.Draw(img)

        # Franja lateral de color
        d.rounded_rectangle([PAD, iy, PAD+10, iy+ph3], radius=6, fill=color)

        # Ícono grande
        if_f = F('bold', 76)
        d.text((PAD+40, iy+30), ico, fill=color, font=if_f)

        # Textos
        d.text((PAD+160, iy+30), name, fill=DARK, font=F('bold', 44))
        d.text((PAD+160, iy+86), tipo, fill=GRAY, font=F('regular', 32))

        divider(d, iy+138)

        d.text((PAD+40, iy+158), 'N° Póliza:', fill=GRAY, font=F('regular', 30))
        d.text((PAD+200, iy+158), pol_num, fill=DARK, font=F('semi', 30))

        d.text((PAD+40, iy+196), 'Vence:', fill=GRAY, font=F('regular', 30))
        d.text((PAD+200, iy+196), vence, fill=DARK, font=F('semi', 30))

        # Badge "VIGENTE"
        bx3 = W - PAD - 160
        d.rounded_rectangle([bx3, iy+20, bx3+140, iy+60], radius=16, fill=GREEN)
        text_c(d, 'VIGENTE', iy+24, F('bold', 28), WHITE, bx3, bx3+140)

    nav_bar(img, active=3)
    img.save(os.path.join(OUT, 'ss5_polizas.png'), 'PNG')
    print('✓ ss5_polizas.png')

# ────────────────────────────────────────────────────────────
# PANTALLA 6 — COTIZACIÓN RÁPIDA
# ────────────────────────────────────────────────────────────
def screen_cotizacion():
    img = new_screen(WHITE)
    d = ImageDraw.Draw(img)

    # Header azul gradiente
    d.rectangle([0, 0, W, 520], fill=BLUE)
    draw_status(img)

    # Logo pequeño en header
    logo = Image.open(os.path.join(RES, 'playstore.png')).convert('RGBA')
    ls = 110
    logo = logo.resize((ls, ls), Image.LANCZOS)
    img.paste(logo, ((W-ls)//2, STATUS_H+20), logo)

    d = ImageDraw.Draw(img)
    text_c(d, 'Cotiza tu Seguro', STATUS_H+150, F('bold', 62), WHITE)
    text_c(d, 'Obtén la mejor cobertura al mejor precio', STATUS_H+224, F('regular', 34), BLUE_ACCENT)

    # Tarjeta de formulario
    fy3 = 490
    card(img, PAD-10, fy3, W-2*(PAD-10), 1100, r=36, fill=WHITE)
    d = ImageDraw.Draw(img)

    tipos_seguro = [
        ('🚗', 'Automóvil',   True ),
        ('❤', 'Vida',         False),
        ('🏠', 'Hogar',        False),
        ('✈', 'Viaje',        False),
    ]
    ty2 = fy3 + 50
    d.text((PAD+20, ty2), 'Tipo de seguro', fill=DARK, font=F('semi', 42))
    ty2 += 68
    tw3 = (W - 2*PAD - 50) // 4
    for i, (ico, lbl, act) in enumerate(tipos_seguro):
        tx3 = PAD + i*(tw3+14)
        bg3 = BLUE_LIGHT if act else OFF_WHITE
        brd = BLUE if act else LIGHT_GRAY
        d.rounded_rectangle([tx3, ty2, tx3+tw3, ty2+140], radius=20,
                            fill=bg3, outline=brd, width=2)
        if_f = F('bold', 52)
        bb = d.textbbox((0,0), ico, font=if_f)
        d.text((tx3+(tw3-(bb[2]-bb[0]))//2, ty2+16), ico, fill=BLUE if act else GRAY, font=if_f)
        lf2 = F('medium', 28)
        bb2 = d.textbbox((0,0), lbl, font=lf2)
        d.text((tx3+(tw3-(bb2[2]-bb2[0]))//2, ty2+86), lbl,
               fill=BLUE if act else GRAY, font=lf2)

    # Campos
    fields = [
        ('Nombre completo', 'Carlos Martínez López'),
        ('Número de DUI',   '01234567-8'),
        ('Año del vehículo', '2020'),
        ('Marca / Modelo',  'Toyota Corolla'),
    ]
    ffy = ty2 + 176
    for i, (label, val) in enumerate(fields):
        iy2 = ffy + i*136
        d.text((PAD+20, iy2), label, fill=GRAY, font=F('regular', 30))
        iy2 += 38
        d.rounded_rectangle([PAD+10, iy2, W-PAD-10, iy2+80], radius=14,
                            outline=LIGHT_GRAY, fill=OFF_WHITE, width=2)
        d.text((PAD+36, iy2+18), val, fill=DARK, font=F('medium', 38))

    # Botón
    by2 = ffy + len(fields)*136 + 30
    pill_button(d, PAD+20, by2, W-2*PAD-40, 110, 'SOLICITAR COTIZACIÓN', F('bold', 42), ORANGE, WHITE)

    img.save(os.path.join(OUT, 'ss6_cotizacion.png'), 'PNG')
    print('✓ ss6_cotizacion.png')

# ─── Generar todas ──────────────────────────────────────────
if __name__ == '__main__':
    screen_login()
    screen_home()
    screen_beneficios()
    screen_movimientos()
    screen_polizas()
    screen_cotizacion()
    print(f'\nTodas las capturas guardadas en:\n{OUT}')
