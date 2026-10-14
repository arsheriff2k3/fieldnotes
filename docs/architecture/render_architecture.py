"""Render the FieldNote architecture slide as editable SVG and 4K PNG.

Run with python3 docs/architecture/render_architecture.py (requires Pillow).
"""

from pathlib import Path
from html import escape
import math
from PIL import Image, ImageDraw, ImageFont

OUT = Path(__file__).resolve().parent
W, H, SCALE = 1920, 1080, 2
BG, INK, MUTED = '#FFF9ED', '#192C3C', '#556779'
image = Image.new('RGB', (W * SCALE, H * SCALE), BG)
draw = ImageDraw.Draw(image)
svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080" viewBox="0 0 1920 1080">',
       '<title>FieldNote application architecture</title>',
       '<desc>Flutter Sponsor and Volunteer views connect to Serverpod through generated RPCs and live campaign streams. Serverpod connects to AI, payments, Maps web services, SMTP and persistent storage. Map tiles are client-side.</desc>',
       f'<rect width="1920" height="1080" fill="{BG}"/>']


def font(size, bold=False):
    return ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial' + (' Bold' if bold else '') + '.ttf', size * SCALE)


def text(x, y, value, size=23, color=INK, bold=False):
    f = font(size, bold)
    # y is the common baseline used by both renderers.
    assert draw.textlength(value, font=f) / SCALE < W, value
    draw.text((x * SCALE, y * SCALE), value, font=f, fill=color, anchor='ms')
    svg.append(f'<text x="{x}" y="{y}" text-anchor="middle" font-family="Arial, Helvetica, sans-serif" font-size="{size}" font-weight="{700 if bold else 400}" fill="{color}">{escape(value)}</text>')


def rect(x, y, w, h, color, radius=22):
    draw.rounded_rectangle((x*SCALE, y*SCALE, (x+w)*SCALE, (y+h)*SCALE), radius=radius*SCALE, fill=color)
    svg.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{radius}" fill="{color}"/>')


def line(points, color=MUTED, width=3, dashed=False):
    scaled = [(x*SCALE, y*SCALE) for x,y in points]
    if dashed:
        for (a,b),(c,d) in zip(points,points[1:]):
            length=math.hypot(c-a,d-b)
            for n in range(0,int(length),15):
                t,u=n/length,min(n+8,length)/length
                draw.line(((a+(c-a)*t)*SCALE,(b+(d-b)*t)*SCALE,(a+(c-a)*u)*SCALE,(b+(d-b)*u)*SCALE),fill=color,width=width*SCALE)
    else:
        draw.line(scaled,fill=color,width=width*SCALE)
    coords=' '.join(f'{x},{y}' for x,y in points)
    svg.append(f'<polyline points="{coords}" fill="none" stroke="{color}" stroke-width="{width}"'+(' stroke-dasharray="8 7"' if dashed else '')+'/>')


def arrow(points, color=MUTED, both=False):
    line(points,color)
    ends=[(points[-2],points[-1])]
    if both: ends.append((points[1],points[0]))
    for (a,b),(x,y) in ends:
        angle=math.atan2(y-b,x-a)
        triangle=[(x,y),(x-14*math.cos(angle)+6*math.sin(angle),y-14*math.sin(angle)-6*math.cos(angle)),(x-14*math.cos(angle)-6*math.sin(angle),y-14*math.sin(angle)+6*math.cos(angle))]
        draw.polygon([(p*SCALE,q*SCALE) for p,q in triangle],fill=color)
        svg.append('<polygon points="'+' '.join(f'{p},{q}' for p,q in triangle)+f'" fill="{color}"/>')


def label(x,y,value,size=20):
    width=draw.textlength(value,font=font(size))/SCALE+28
    rect(x-width/2,y-size,width,size+12,BG,8)
    text(x,y,value,size,MUTED)


text(960,73,'FieldNote Architecture',44,bold=True)
text(960,110,'Sponsor intent → nearby volunteer action → evidence-backed impact',23,MUTED)

# Top layer: the same Flutter application serves both account roles.
rect(610,149,700,205,'#16658A')
text(960,192,'Flutter App',32,'#FFFFFF',True)
line([(640,210),(1280,210)],'#5A93AE',2)
text(960,244,'Sponsor views  •  Volunteer views  •  Trust center',24,'#FFFFFF')
text(960,279,'View models → Repositories → Generated Serverpod client',22,'#FFFFFF')
text(960,313,'GPS  •  Camera  •  Dictation  •  Client map tiles',22,'#FFFFFF')
text(960,339,'Android  •  iOS  •  Web',19,'#DBEAF2')

arrow([(924,357),(924,446)])
arrow([(996,446),(996,357)],'#267A85')
label(750,405,'Type-safe RPC calls',20)
label(1193,405,'Live campaign streams',20)

# Center layer follows the reference: three backend responsibility columns.
rect(370,449,1180,274,'#B74D20')
text(960,496,'Serverpod Backend',34,'#FFFFFF',True)
line([(402,516),(1518,516)],'#D78D70',2)
for x,title,rows in [
    (565,'Endpoints',['Auth & profiles • Campaigns','Funding • Participation','Evidence • Impact • Consent']),
    (960,'Core Logic',['Lifecycle & explainable matching','GPS checks • Evidence review','Scheduled jobs & audit trail']),
    (1355,'Integrations',['AI provider routing','Payment verification & webhooks','Maps APIs • Email outbox']),
]:
    text(x,553,title,25,'#FFFFFF',True)
    for n,row in enumerate(rows): text(x,587+n*31,row,21,'#FFFFFF')
line([(765,542),(765,660)],'#D78D70',1)
line([(1155,542),(1155,660)],'#D78D70',1)
text(960,697,'All Dart  •  Generated client  •  PostgreSQL ORM & migrations  •  Private evidence access',21,'#FFF1E9')

# Bottom layer: external providers and the data infrastructure.
cards=[
    (45,'Gemini / Groq','#186F70','Draft & summarize',['Campaign drafting','Voice transcription','Photo + note summaries'],'Manual completion fallback'),
    (419,'Razorpay','#AD3E4B','Verify & reconcile',['Checkout orders','Signed payment webhooks','Reconciliation & refunds'],'Hackathon: Test Mode'),
    (793,'Google Maps','#6550A6','Places & routes',['Places & geocoding','Travel-time ranking','Client-side map tiles'],'Optional; geofence is local math'),
    (1167,'SMTP Email','#866016','Deliver notifications',['Signup & password reset','Campaign notifications','Outbox retries'],'Configured SMTP provider'),
    (1541,'Data & Storage','#35688C','Persist & protect',['PostgreSQL: app state','Private evidence storage','Redis: shared live messages'],'Redis enabled in production config'),
]
starts=[(465,723),(650,723),(960,723),(1270,723),(1455,723)]
for (x,title,color,caption,rows,foot),start in zip(cards,starts):
    cx=x+167
    arrow([start,(cx,830)],both=title=='Razorpay')
    label(cx,784,caption,19)
    rect(x,834,334,191,color,18)
    text(cx,875,title,28,'#FFFFFF',True)
    line([(x+18,892),(x+316,892)],'#FFFFFF',1)
    for n,row in enumerate(rows): text(cx,923+n*27,row,21,'#FFFFFF')
    text(cx,1007,foot,16,'#FFFFFF')

text(960,1063,'Shared state across both roles  •  Secrets stay server-side  •  Evidence is reviewed by people',21,MUTED)
svg.append('</svg>')
OUT.mkdir(parents=True,exist_ok=True)
(OUT/'fieldnote-architecture.svg').write_text('\n'.join(svg)+'\n')
image.save(OUT/'fieldnote-architecture.png')
image.resize((W,H),Image.Resampling.LANCZOS).save(OUT/'fieldnote-architecture-1080p.png')
print('Created editable SVG, 3840 × 2160 PNG, and 1920 × 1080 PNG.')
