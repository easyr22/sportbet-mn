"""
SportBet MN — Flask backend
 Data sources (бүгд үнэгүй):
   ESPN public API      — 15+ спорт, бодит score, API key хэрэггүй
   OpenDota API         — Dota2 лайв, API key хэрэггүй
   PandaScore API       — CS2/LoL/Val/Dota2 бодит match (key хэрэгтэй, үнэгүй tier)
   The Odds API         — бодит bookmaker odds (key хэрэгтэй, үнэгүй tier)

 Key тохируулга (доорх CONFIG хэсэгт нэмнэ):
   PANDASCORE_KEY  → https://app.pandascore.co  (бүртгэл → settings → token)
   ODDS_API_KEY    → https://the-odds-api.com   (бүртгэл → account → API key)
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
from datetime import datetime, timezone
import os, threading, random, time, math, requests as req

app = Flask(__name__,
    static_folder=os.path.join(os.path.dirname(__file__), '..', 'build', 'web'),
    static_url_path='')
CORS(app)

# ═══════════════════════════════════════════════════════
#  CONFIG — API key-үүдийг энд эсвэл environment variable-аар оруулна
# ═══════════════════════════════════════════════════════
PANDASCORE_KEY = os.environ.get("PANDASCORE_KEY", "")   # esports real data
ODDS_API_KEY   = os.environ.get("ODDS_API_KEY",   "")   # real bookmaker odds

# ═══════════════════════════════════════════════════════
#  ESPN SPORT SOURCES  (API key хэрэггүй — бүгд үнэгүй)
# ═══════════════════════════════════════════════════════
ESPN_SOURCES = [
    # ── Football (Soccer) ─────────────────────────────
    {"path": "soccer/eng.1",          "sportId": "football",    "league": "Premier League",      "country": "Англи",      "flag": "🏴󠁧󠁢󠁥󠁮󠁧󠁿"},
    {"path": "soccer/eng.2",          "sportId": "football",    "league": "Championship",        "country": "Англи",      "flag": "🏴󠁧󠁢󠁥󠁮󠁧󠁿"},
    {"path": "soccer/eng.fa",         "sportId": "football",    "league": "FA Cup",              "country": "Англи",      "flag": "🏴󠁧󠁢󠁥󠁮󠁧󠁿"},
    {"path": "soccer/esp.1",          "sportId": "football",    "league": "La Liga",             "country": "Испани",     "flag": "🇪🇸"},
    {"path": "soccer/esp.copa_del_rey","sportId":"football",    "league": "Copa del Rey",        "country": "Испани",     "flag": "🇪🇸"},
    {"path": "soccer/ita.1",          "sportId": "football",    "league": "Serie A",             "country": "Итали",      "flag": "🇮🇹"},
    {"path": "soccer/ger.1",          "sportId": "football",    "league": "Bundesliga",          "country": "Герман",     "flag": "🇩🇪"},
    {"path": "soccer/ger.2",          "sportId": "football",    "league": "Bundesliga 2",        "country": "Герман",     "flag": "🇩🇪"},
    {"path": "soccer/fra.1",          "sportId": "football",    "league": "Ligue 1",             "country": "Франц",      "flag": "🇫🇷"},
    {"path": "soccer/por.1",          "sportId": "football",    "league": "Primeira Liga",       "country": "Португал",   "flag": "🇵🇹"},
    {"path": "soccer/ned.1",          "sportId": "football",    "league": "Eredivisie",          "country": "Нидерланд",  "flag": "🇳🇱"},
    {"path": "soccer/tur.1",          "sportId": "football",    "league": "Süper Lig",           "country": "Турк",       "flag": "🇹🇷"},
    {"path": "soccer/sco.1",          "sportId": "football",    "league": "Scottish Premiership","country": "Шотланд",    "flag": "🏴󠁧󠁢󠁳󠁣󠁴󠁿"},
    {"path": "soccer/bel.1",          "sportId": "football",    "league": "Belgian Pro League",  "country": "Бельги",     "flag": "🇧🇪"},
    {"path": "soccer/aut.1",          "sportId": "football",    "league": "Bundesliga (Aus)",    "country": "Австри",     "flag": "🇦🇹"},
    {"path": "soccer/sui.1",          "sportId": "football",    "league": "Super League",        "country": "Швейцарь",   "flag": "🇨🇭"},
    {"path": "soccer/gre.1",          "sportId": "football",    "league": "Super League 1",      "country": "Грек",       "flag": "🇬🇷"},
    {"path": "soccer/rus.1",          "sportId": "football",    "league": "Premier League",      "country": "Орос",       "flag": "🇷🇺"},
    {"path": "soccer/mex.1",          "sportId": "football",    "league": "Liga MX",             "country": "Мексик",     "flag": "🇲🇽"},
    {"path": "soccer/arg.1",          "sportId": "football",    "league": "Primera División",    "country": "Аргентин",   "flag": "🇦🇷"},
    {"path": "soccer/bra.1",          "sportId": "football",    "league": "Série A",             "country": "Бразил",     "flag": "🇧🇷"},
    {"path": "soccer/jpn.1",          "sportId": "football",    "league": "J.League",            "country": "Япон",       "flag": "🇯🇵"},
    {"path": "soccer/kor.1",          "sportId": "football",    "league": "K League 1",          "country": "Солонгос",   "flag": "🇰🇷"},
    {"path": "soccer/chn.1",          "sportId": "football",    "league": "Chinese Super League","country": "Хятад",      "flag": "🇨🇳"},
    {"path": "soccer/aus.1",          "sportId": "football",    "league": "A-League",            "country": "Австрали",   "flag": "🇦🇺"},
    {"path": "soccer/usa.1",          "sportId": "football",    "league": "MLS",                 "country": "АНУ",        "flag": "🇺🇸"},
    {"path": "soccer/uefa.champions", "sportId": "football",    "league": "Champions League",    "country": "Европ",      "flag": "🌍"},
    {"path": "soccer/uefa.europa",    "sportId": "football",    "league": "Europa League",       "country": "Европ",      "flag": "🌍"},
    {"path": "soccer/uefa.europa.conf","sportId":"football",    "league": "Conference League",   "country": "Европ",      "flag": "🌍"},
    {"path": "soccer/conmebol.libertadores","sportId":"football","league":"Copa Libertadores",   "country": "Өмнөд Америк","flag":"🌎"},
    {"path": "soccer/fifa.worldq.uefa","sportId":"football",    "league": "World Cup Qualifier", "country": "Олон улс",   "flag": "🌍"},
    # ── Basketball ────────────────────────────────────
    {"path": "basketball/nba",        "sportId": "basketball",  "league": "NBA",                 "country": "АНУ",        "flag": "🇺🇸"},
    {"path": "basketball/wnba",       "sportId": "basketball",  "league": "WNBA",                "country": "АНУ",        "flag": "🇺🇸"},
    {"path": "basketball/mens-college-basketball","sportId":"basketball","league":"NCAA","country":"АНУ","flag":"🇺🇸"},
    # ── Baseball ──────────────────────────────────────
    {"path": "baseball/mlb",          "sportId": "baseball",    "league": "MLB",                 "country": "АНУ",        "flag": "🇺🇸"},
    {"path": "baseball/college-baseball","sportId":"baseball",  "league": "NCAA Baseball",       "country": "АНУ",        "flag": "🇺🇸"},
    # ── Hockey ────────────────────────────────────────
    {"path": "hockey/nhl",            "sportId": "hockey",      "league": "NHL",                 "country": "АНУ/Канад",  "flag": "🇺🇸"},
    # ── American Football ─────────────────────────────
    {"path": "football/nfl",          "sportId": "americanfootball", "league": "NFL",            "country": "АНУ",        "flag": "🇺🇸"},
    {"path": "football/college-football", "sportId": "americanfootball", "league": "NCAA",       "country": "АНУ",        "flag": "🇺🇸"},
    # ── MMA / Boxing ──────────────────────────────────
    {"path": "mma/ufc",               "sportId": "mma",         "league": "UFC",                 "country": "Олон улс",   "flag": "🌍"},
    {"path": "mma/pfl",               "sportId": "mma",         "league": "PFL",                 "country": "Олон улс",   "flag": "🌍"},
    # ── Tennis ────────────────────────────────────────
    {"path": "tennis/atp",            "sportId": "tennis",      "league": "ATP Tour",            "country": "Олон улс",   "flag": "🌍"},
    {"path": "tennis/wta",            "sportId": "tennis",      "league": "WTA Tour",            "country": "Олон улс",   "flag": "🌍"},
]

# ═══════════════════════════════════════════════════════
#  ESPORTS — PandaScore integration
#  (key байхгүй үед бодит team нэрүүдтэй simulation ашиглана)
# ═══════════════════════════════════════════════════════
PANDA_GAMES = [
    {"game": "cs2",     "sportId": "esports", "league": "CS2 — BLAST Premier", "country": "Олон улс", "flag": "🌍"},
    {"game": "lol",     "sportId": "esports", "league": "LoL — LCK / MSI",     "country": "Солонгос", "flag": "🇰🇷"},
    {"game": "dota2",   "sportId": "esports", "league": "Dota2 — ESL Pro",      "country": "Олон улс", "flag": "🌍"},
    {"game": "valorant","sportId": "esports", "league": "Valorant — VCT",       "country": "Олон улс", "flag": "🌍"},
    {"game": "rl",      "sportId": "esports", "league": "Rocket League — RLCS", "country": "Олон улс", "flag": "🌍"},
]

# Бодит 2025 esports team нэрүүд (simulation болон fallback-д ашиглана)
ESPORTS_TEAMS = {
    "cs2":     ["Natus Vincere", "FaZe Clan", "G2 Esports", "Team Vitality", "Cloud9",
                "MOUZ", "Team Liquid", "ENCE", "Astralis", "Team Spirit", "Heroic", "OG"],
    "lol":     ["T1", "Gen.G", "JDG Gaming", "LNG Esports", "Cloud9", "Team Liquid",
                "KT Rolster", "Weibo Gaming", "NRG", "100 Thieves", "G2 Esports", "Fnatic"],
    "dota2":   ["Team Liquid", "Team Secret", "OG", "PSG.LGD", "Tundra Esports",
                "Evil Geniuses", "Gaimin Gladiators", "BetBoom Team", "Team Aster", "Aurora"],
    "valorant":["Sentinels", "NRG", "LOUD", "Paper Rex", "Fnatic", "EDG",
                "DRX", "ZETA DIVISION", "Team Liquid", "BBL Esports", "Cloud9", "M80"],
    "rl":      ["Team BDS", "Karmine Corp", "G2 Esports", "FaZe Clan", "NRG",
                "Version1", "Evil Geniuses", "Oxygen Esports"],
}

# Helper: generate fallback logo via ui-avatars.com (PNG, CORS-friendly)
def gen_logo(name, bg="1e5a99", fg="ffffff"):
    safe = name.replace(" ", "+").replace(".", "")
    return f"https://ui-avatars.com/api/?name={safe}&background={bg}&color={fg}&size=64&bold=true&format=png"

# Helper: country flag image via flagcdn (use 2-letter code or full name search via wsrv)
def flag_logo(emoji_flag):
    # Use Twemoji CDN for crisp emoji flag rendering as PNG
    if not emoji_flag: return ""
    cps = "-".join(f"{ord(c):x}" for c in emoji_flag if ord(c) > 127)
    if not cps: return ""
    return f"https://cdn.jsdelivr.net/gh/twitter/twemoji@latest/assets/72x72/{cps}.png"

ESPORTS_LOGOS = {
    "Natus Vincere": "https://upload.wikimedia.org/wikipedia/en/thumb/e/e3/NaVi_logo.svg/80px-NaVi_logo.svg.png",
    "FaZe Clan":    "https://upload.wikimedia.org/wikipedia/en/thumb/8/82/FaZe_Clan_logo.svg/80px-FaZe_Clan_logo.svg.png",
    "G2 Esports":   "https://upload.wikimedia.org/wikipedia/en/thumb/1/13/G2esports_logo.svg/80px-G2esports_logo.svg.png",
    "Team Vitality": "https://upload.wikimedia.org/wikipedia/en/thumb/4/4c/Team_Vitality.svg/80px-Team_Vitality.svg.png",
    "Cloud9":       "https://upload.wikimedia.org/wikipedia/en/thumb/f/f4/Cloud9_logo.svg/80px-Cloud9_logo.svg.png",
    "Team Liquid":  "https://upload.wikimedia.org/wikipedia/en/thumb/3/36/Team_Liquid_logo.svg/80px-Team_Liquid_logo.svg.png",
    "T1":           "https://upload.wikimedia.org/wikipedia/en/thumb/6/67/T1_logo_square.png/80px-T1_logo_square.png",
    "Gen.G":        "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Gen.G_logo.svg/80px-Gen.G_logo.svg.png",
    "Fnatic":       "https://upload.wikimedia.org/wikipedia/en/thumb/8/8a/Fnatic.svg/80px-Fnatic.svg.png",
    "Astralis":     "https://upload.wikimedia.org/wikipedia/en/thumb/8/87/Astralis_logo.svg/80px-Astralis_logo.svg.png",
    "MOUZ":         "https://upload.wikimedia.org/wikipedia/en/thumb/5/56/Mousesports_logo.svg/80px-Mousesports_logo.svg.png",
    "Sentinels":    "https://upload.wikimedia.org/wikipedia/en/thumb/2/2c/Sentinels_logo.svg/80px-Sentinels_logo.svg.png",
    "NRG":          "https://upload.wikimedia.org/wikipedia/en/thumb/6/6f/NRG_Esports_logo.svg/80px-NRG_Esports_logo.svg.png",
    "LOUD":         "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/LOUD_logo.svg/80px-LOUD_logo.svg.png",
    "Paper Rex":    "https://upload.wikimedia.org/wikipedia/en/thumb/e/e0/Paper_Rex_logo.svg/80px-Paper_Rex_logo.svg.png",
    "Team Spirit":  "https://upload.wikimedia.org/wikipedia/en/thumb/4/4d/Team_Spirit_logo.svg/80px-Team_Spirit_logo.svg.png",
    "Team Secret":  "https://upload.wikimedia.org/wikipedia/en/thumb/7/7c/Team_Secret_logo.svg/80px-Team_Secret_logo.svg.png",
    "OG":           "https://upload.wikimedia.org/wikipedia/en/thumb/d/d4/OG_Esports.svg/80px-OG_Esports.svg.png",
    "PSG.LGD":      "https://upload.wikimedia.org/wikipedia/en/thumb/2/22/PSG.LGD_logo.svg/80px-PSG.LGD_logo.svg.png",
    "Karmine Corp": "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Karmine_Corp_logo.svg/80px-Karmine_Corp_logo.svg.png",
    "Team BDS":     "https://upload.wikimedia.org/wikipedia/en/thumb/4/42/Team_BDS_logo.svg/80px-Team_BDS_logo.svg.png",
}

# ═══════════════════════════════════════════════════════
#  TEAM STRENGTH (odds generation)
# ═══════════════════════════════════════════════════════
STRENGTH = {
    # PL
    "Manchester City":92,"Liverpool":90,"Arsenal":85,"Chelsea":82,
    "Manchester United":78,"Tottenham":76,"Newcastle":74,"Aston Villa":74,
    "Brighton":72,"Fulham":70,"Bournemouth":68,"Brentford":68,
    "Wolverhampton Wanderers":64,"Sunderland":62,
    # La Liga
    "Real Madrid":92,"Barcelona":90,"Atletico Madrid":84,"Sevilla":76,
    "Levante":62,"Osasuna":64,
    # Serie A
    "Inter Milan":85,"AC Milan":82,"Juventus":80,"Napoli":82,
    "Torino":68,"Sassuolo":62,
    # Bundesliga
    "Bayern Munich":91,"Borussia Dortmund":83,"Bayer Leverkusen":84,"RB Leipzig":80,
    "Eintracht Frankfurt":76,"SC Freiburg":72,
    # Ligue 1
    "PSG":88,"Monaco":76,"Lyon":72,"Lens":70,"Nantes":64,
    # Portugal
    "Sporting CP":80,"Porto":80,"Benfica":82,"Vitória de Guimaraes":64,
    # Netherlands
    "Ajax":82,"PSV":84,"Feyenoord":80,
    # Turkey
    "Galatasaray":80,"Fenerbahce":78,"Besiktas":74,
    # CL / EL
    "Paris Saint-Germain":88,"Braga":72,"Nottingham Forest":70,
    # NBA
    "Boston Celtics":90,"Miami Heat":82,"Denver Nuggets":86,
    "LA Lakers":80,"Golden State Warriors":84,"Phoenix Suns":78,
    "New York Knicks":80,"Philadelphia 76ers":78,
    "Minnesota Timberwolves":82,"San Antonio Spurs":62,
    # Esports (sim)
    "T1":90,"Natus Vincere":85,"FaZe Clan":83,"G2 Esports":82,"Team Vitality":80,
    "Gen.G":86,"Team Liquid":78,"Cloud9":75,"Sentinels":78,"LOUD":80,"Paper Rex":77,
    "Team Spirit":80,"Fnatic":76,"Astralis":74,"Team Secret":78,"OG":76,"PSG.LGD":82,
}
def strength(n): return STRENGTH.get(n, 72)

# ═══════════════════════════════════════════════════════
#  ODDS GENERATION  (Poisson model)
# ═══════════════════════════════════════════════════════
def _pp(lam, k): return math.exp(-lam) * (lam**k) / math.factorial(k)

def base_soccer_odds(h, a):
    diff = (strength(h) + 3 - strength(a)) / 20.0
    lh = max(0.4, min(3.5, 1.35 + diff * 0.3))
    la = max(0.4, min(3.5, 1.10 - diff * 0.3))
    ph=pd=pa=0.0
    for g1 in range(8):
        for g2 in range(8):
            p = _pp(lh,g1)*_pp(la,g2)
            if g1>g2: ph+=p
            elif g1==g2: pd+=p
            else: pa+=p
    m=1.06
    return round(m/max(ph,.01),2), round(m/max(pd,.01),2), round(m/max(pa,.01),2)

def live_soccer_odds(h,a,hs,as_,min_):
    o1,ox,o2=base_soccer_odds(h,a)
    rem=max(0,90-min_)/90.0; diff=hs-as_; adj=diff*(1-rem)*0.4
    return (round(max(1.04,o1-adj*(o1-1)),2),
            round(max(1.5, ox+abs(diff)*rem*0.3),2),
            round(max(1.04,o2+adj*(o2-1)),2))

def ou_odds(exp,line=2.5):
    p=sum(_pp(exp/2,g1)*_pp(exp/2,g2) for g1 in range(8) for g2 in range(8) if g1+g2>line)
    p=max(.1,min(.9,p)); m=1.05
    return round(m/p,2), round(m/(1-p),2)

def soccer_markets(mid,h,a,hs,as_,min_,live):
    if live:
        o1,ox,o2=live_soccer_odds(h,a,hs,as_,min_)
        exp=max(.5,(hs+as_)+(90-min_)/90*2.4)
    else:
        o1,ox,o2=base_soccer_odds(h,a); exp=2.5
    line=round(hs+as_+.5) if live else 2.5
    ov,un=ou_odds(exp,line)
    bts=1-(_pp(exp/2,0)+_pp(exp/2,0))
    by=round(1.05/max(.1,bts),2); bn=round(1.05/max(.1,1-bts),2)
    dc1x=round(1.03/(1/o1+1/ox)*0.97,2); dcx2=round(1.03/(1/ox+1/o2)*0.97,2)
    return [
        {"id":f"{mid}_1x2","name":"1X2","options":[{"label":"1","odds":o1},{"label":"X","odds":ox},{"label":"2","odds":o2}]},
        {"id":f"{mid}_ou", "name":f"Нийт гол {line}","options":[{"label":"Дээш","odds":ov},{"label":"Доош","odds":un}]},
        {"id":f"{mid}_bts","name":"Хоёул гол оруулах","options":[{"label":"Тийм","odds":by},{"label":"Үгүй","odds":bn}]},
        {"id":f"{mid}_dc", "name":"Давхар боломж","options":[{"label":"1X","odds":dc1x},{"label":"X2","odds":dcx2}]},
    ]

def _ml_odds(h,a):
    ph=max(.1,min(.9,.5+(strength(h)-strength(a))/100))
    return round(1.05/ph,2), round(1.05/(1-ph),2)

def bball_markets(mid,h,a):
    oh,oa=_ml_odds(h,a)
    hn,an=h.split()[-1],a.split()[-1]
    return [
        {"id":f"{mid}_ml","name":"Монейлайн","options":[{"label":hn,"odds":oh},{"label":an,"odds":oa}]},
        {"id":f"{mid}_ou","name":"Нийт оноо 220.5","options":[{"label":"Дээш","odds":1.90},{"label":"Доош","odds":1.90}]},
        {"id":f"{mid}_sp","name":"Спред -4.5","options":[{"label":hn+" -4.5","odds":1.91},{"label":an+" +4.5","odds":1.91}]},
    ]

def baseball_markets(mid,h,a):
    oh,oa=_ml_odds(h,a)
    return [
        {"id":f"{mid}_ml","name":"Монейлайн","options":[{"label":h.split()[-1],"odds":oh},{"label":a.split()[-1],"odds":oa}]},
        {"id":f"{mid}_ou","name":"Нийт оноо 8.5","options":[{"label":"Дээш","odds":1.90},{"label":"Доош","odds":1.90}]},
    ]

def hockey_markets(mid,h,a):
    oh,oa=_ml_odds(h,a)
    return [
        {"id":f"{mid}_ml","name":"Монейлайн","options":[{"label":h.split()[-1],"odds":oh},{"label":"Тэнцэл","odds":3.80},{"label":a.split()[-1],"odds":oa}]},
        {"id":f"{mid}_ou","name":"Нийт гол 5.5","options":[{"label":"Дээш","odds":1.92},{"label":"Доош","odds":1.88}]},
    ]

def mma_markets(mid,h,a):
    oh,oa=_ml_odds(h,a)
    return [
        {"id":f"{mid}_ml","name":"Ялагч","options":[{"label":h.split()[-1],"odds":oh},{"label":a.split()[-1],"odds":oa}]},
        {"id":f"{mid}_rnd","name":"Аль раундад","options":[{"label":"1-р раунд","odds":3.50},{"label":"2-р раунд","odds":3.20},{"label":"3+","odds":2.10}]},
    ]

def tennis_markets(mid,h,a):
    oh,oa=_ml_odds(h,a)
    return [
        {"id":f"{mid}_ml","name":"Ялагч","options":[{"label":h.split()[-1],"odds":oh},{"label":a.split()[-1],"odds":oa}]},
        {"id":f"{mid}_sets","name":"Нийт сет 2.5","options":[{"label":"Дээш","odds":1.80},{"label":"Доош","odds":1.95}]},
    ]

def esports_markets(mid,h,a):
    oh,oa=_ml_odds(h,a)
    return [
        {"id":f"{mid}_ml",  "name":"Ялагч",         "options":[{"label":h,"odds":oh},{"label":a,"odds":oa}]},
        {"id":f"{mid}_maps","name":"Нийт Map 2.5",   "options":[{"label":"Дээш","odds":2.20},{"label":"Доош","odds":1.65}]},
        {"id":f"{mid}_1st", "name":"1-р map ялагч",  "options":[{"label":h,"odds":round(oh*0.9,2)},{"label":a,"odds":round(oa*0.9,2)}]},
    ]

def make_markets(mid,src,h,a,hs,as_,min_,live):
    sp=src["sportId"]
    if sp=="football":    return soccer_markets(mid,h,a,hs,as_,min_,live)
    if sp=="basketball":  return bball_markets(mid,h,a)
    if sp=="baseball":    return baseball_markets(mid,h,a)
    if sp=="hockey":      return hockey_markets(mid,h,a)
    if sp=="mma":         return mma_markets(mid,h,a)
    if sp=="tennis":      return tennis_markets(mid,h,a)
    if sp=="esports":     return esports_markets(mid,h,a)
    return []

# ═══════════════════════════════════════════════════════
#  ESPN PARSER
# ═══════════════════════════════════════════════════════
def parse_espn(ev, src):
    try:
        comp  = ev["competitions"][0]
        comps = comp["competitors"]
        home  = next((c for c in comps if c.get("homeAway")=="home"), comps[0])
        away  = next((c for c in comps if c.get("homeAway")=="away"), comps[-1])
        st    = ev["status"]; sname = st["type"]["name"]
        if sname == "STATUS_FINAL": return None

        live   = sname in ("STATUS_IN_PROGRESS","STATUS_HALFTIME")
        detail = st["type"].get("shortDetail","")
        hs     = int(home.get("score") or 0)
        as_    = int(away.get("score") or 0)
        minute = 0; minute_str=None; period_str=None

        if live:
            sp=src["sportId"]
            if sp=="football":
                clock=st.get("clock",0) or 0
                minute=min(90,int(clock/60)) if clock else 0
                minute_str=str(minute) if minute else detail
                period_str="Хагасийн завсарлага" if sname=="STATUS_HALFTIME" \
                           else("1-р хагас" if st.get("period",1)<=1 else "2-р хагас")
            elif sp=="basketball":
                period_str={1:"Q1",2:"Q2",3:"Q3",4:"Q4"}.get(st.get("period",1),detail)
                minute_str=detail
            elif sp in ("baseball","hockey"):
                period_str=detail; minute_str=detail
            else:
                period_str=detail; minute_str=detail

        h_name=home["team"]["displayName"]; a_name=away["team"]["displayName"]
        h_logo=home["team"].get("logo","");  a_logo=away["team"].get("logo","")
        eid=f"espn_{ev['id']}"; sp=src["sportId"]
        mkts=make_markets(eid,src,h_name,a_name,hs,as_,minute,live)
        return {
            "id":eid, "sportId":sp,
            "league":src["league"], "country":src["country"], "countryFlag":src["flag"],
            "homeTeam":h_name, "awayTeam":a_name, "homeLogo":h_logo, "awayLogo":a_logo,
            "isLive":live, "homeScore":hs, "awayScore":as_,
            "minute":minute, "minuteStr":minute_str, "period":period_str,
            "startTime":ev.get("date", datetime.now(timezone.utc).isoformat()),
            "totalMarkets":len(mkts)*8+random.randint(20,45),
            "markets":mkts,
        }
    except Exception as ex:
        print(f"parse_espn err: {ex}"); return None

# ═══════════════════════════════════════════════════════
#  ESPORTS — PandaScore real data
# ═══════════════════════════════════════════════════════
def fetch_pandascore():
    if not PANDASCORE_KEY: return []
    results=[]
    headers={"Authorization": f"Bearer {PANDASCORE_KEY}"}
    for pg in PANDA_GAMES:
        for status in ["running","upcoming"]:
            try:
                url=f"https://api.pandascore.co/{pg['game']}/matches/{status}"
                r=req.get(url, headers=headers, params={"per_page":10}, timeout=8)
                if r.status_code!=200: continue
                for m in r.json():
                    home_op=m.get("opponents",[{}])[0].get("opponent",{})
                    away_op=m.get("opponents",[{},{}])[1].get("opponent",{}) if len(m.get("opponents",[]))>1 else {}
                    h_name=home_op.get("name","TBD"); a_name=away_op.get("name","TBD")
                    h_logo=home_op.get("image_url","");  a_logo=away_op.get("image_url","")
                    is_live=(status=="running")
                    eid=f"panda_{m['id']}"
                    # scores
                    hs=0;as_=0
                    for res in m.get("results",[]):
                        if res.get("team_id")==home_op.get("id"): hs=res.get("score",0)
                        if res.get("team_id")==away_op.get("id"): as_=res.get("score",0)
                    begin=m.get("begin_at") or datetime.now(timezone.utc).isoformat()
                    game_name=m.get("videogame",{}).get("name","Esports")
                    league_name=m.get("league",{}).get("name",pg["league"])
                    serie=m.get("serie",{}).get("full_name","")
                    full_league=f"{league_name} — {serie}" if serie else league_name
                    detail=""
                    if is_live:
                        cur=m.get("current_game",{}) or {}
                        fn=cur.get("game_number",1)
                        detail=f"Game {fn}"
                    mkts=esports_markets(eid,h_name,a_name)
                    results.append({
                        "id":eid,"sportId":"esports",
                        "league":full_league,"country":pg["country"],"countryFlag":pg["flag"],
                        "homeTeam":h_name,"awayTeam":a_name,
                        "homeLogo":h_logo or ESPORTS_LOGOS.get(h_name,""),
                        "awayLogo":a_logo or ESPORTS_LOGOS.get(a_name,""),
                        "isLive":is_live,"homeScore":hs,"awayScore":as_,
                        "minute":0,"minuteStr":detail if is_live else None,"period":detail if is_live else None,
                        "startTime":begin,
                        "totalMarkets":len(mkts)*5+random.randint(10,25),
                        "markets":mkts,
                    })
            except Exception as ex:
                print(f"PandaScore err ({pg['game']} {status}): {ex}")
    return results

# ═══════════════════════════════════════════════════════
#  ESPORTS SIMULATION (key байхгүй үед)
# ═══════════════════════════════════════════════════════
_esim_matches = []
_esim_lock = threading.Lock()

def _init_esports_sim():
    matches=[]
    game_configs=[
        # CS2 — олон тэмцээн
        ("cs2",     "CS2 — BLAST Premier Final",     "Олон улс", "🌍",  ["Map 1: Mirage","Map 2: Inferno","Map 3: Ancient"], True),
        ("cs2",     "CS2 — IEM Katowice",            "Польш",     "🇵🇱", ["Map 1: Dust2","Map 2: Nuke"],                    True),
        ("cs2",     "CS2 — PGL Major Copenhagen",    "Дани",      "🇩🇰", ["Map 1: Anubis","Map 2: Vertigo","Map 3: Mirage"], True),
        ("cs2",     "CS2 — ESL Pro League",          "Олон улс", "🌍",  ["Map 1: Inferno","Map 2: Overpass"],              False),
        # LoL — олон бүсийн лиг
        ("lol",     "LoL — LCK Spring Finals",       "Солонгос", "🇰🇷", ["Game 1","Game 2","Game 3","Game 4"],            True),
        ("lol",     "LoL — LPL Summer",              "Хятад",    "🇨🇳", ["Game 1","Game 2","Game 3"],                     True),
        ("lol",     "LoL — MSI 2025",                "Олон улс", "🌍",  ["Game 1","Game 2","Game 3"],                     True),
        ("lol",     "LoL — Worlds Play-Ins",         "Олон улс", "🌍",  ["Game 1","Game 2"],                              False),
        # Dota 2
        ("dota2",   "Dota 2 — ESL One Birmingham",   "Англи",    "🏴󠁧󠁢󠁥󠁮󠁧󠁿", ["Game 1","Game 2","Game 3"],                     True),
        ("dota2",   "Dota 2 — DreamLeague S25",      "Швед",     "🇸🇪", ["Game 1","Game 2"],                              True),
        ("dota2",   "Dota 2 — The International 14", "Олон улс", "🌍",  ["Game 1","Game 2","Game 3","Game 4","Game 5"],   False),
        # Valorant
        ("valorant","Valorant — VCT Masters Madrid", "Испани",   "🇪🇸", ["Map 1: Bind","Map 2: Haven","Map 3: Ascent"],   True),
        ("valorant","Valorant — VCT Pacific",        "Япон",     "🇯🇵", ["Map 1: Split","Map 2: Lotus"],                  True),
        ("valorant","Valorant — Champions Tour",     "АНУ",      "🇺🇸", ["Map 1: Sunset","Map 2: Pearl","Map 3: Icebox"], False),
        # Rocket League
        ("rl",      "Rocket League — RLCS Major",    "Олон улс", "🌍",  ["Game 1","Game 2","Game 3"],                     True),
        ("rl",      "Rocket League — RLCS World",    "Канад",    "🇨🇦", ["Game 1","Game 2"],                              False),
    ]
    used={}
    for game,league,country,flag,stages,is_live in game_configs:
        teams=ESPORTS_TEAMS.get(game,[])
        pool=[t for t in teams if used.get(f"{game}_{t}",0)<1]
        if len(pool)<2: pool=teams
        random.shuffle(pool)
        h,a=pool[0],pool[1]
        used[f"{game}_{h}"]=used.get(f"{game}_{h}",0)+1
        used[f"{game}_{a}"]=used.get(f"{game}_{a}",0)+1
        cur_stage=stages[random.randint(0,len(stages)-1)]
        hs=random.randint(0,2) if is_live else 0
        as_=random.randint(0,2) if is_live else 0
        eid=f"esim_{game}_{h}_{a}".replace(" ","_").lower()
        mkts=esports_markets(eid,h,a)
        start_off=0 if is_live else random.uniform(1,8)*3600
        # Realistic in-game scores
        if is_live and game in ("cs2","valorant"):
            hs=random.randint(2,14); as_=random.randint(2,14)
        elif is_live and game=="lol":
            hs=random.randint(3,18); as_=random.randint(3,18)
        elif is_live and game=="dota2":
            hs=random.randint(8,35); as_=random.randint(8,35)
        elif is_live:
            hs=random.randint(0,3); as_=random.randint(0,3)
        else:
            hs=0; as_=0
        matches.append({
            "id":eid,"sportId":"esports",
            "league":league,"country":country,"countryFlag":flag,
            "homeTeam":h,"awayTeam":a,
            "homeLogo":ESPORTS_LOGOS.get(h) or gen_logo(h, "ff6b00"),
            "awayLogo":ESPORTS_LOGOS.get(a) or gen_logo(a, "1e5a99"),
            "isLive":is_live,"homeScore":hs,"awayScore":as_,
            "minute":0,
            "minuteStr":cur_stage if is_live else None,
            "period":cur_stage if is_live else None,
            "_startOffset": start_off,
            "_gameDuration": random.randint(15,50)*60,
            "_elapsed": random.randint(0, 2700) if is_live else 0,
            "_stages": stages,
            "totalMarkets":len(mkts)*5+random.randint(10,30),
            "markets":mkts,
        })
    return matches

def _update_esports_sim():
    with _esim_lock:
        for m in _esim_matches:
            if not m["isLive"]: continue
            m["_elapsed"] = m.get("_elapsed",0) + 60
            dur = m.get("_gameDuration", 2400)

            # Random in-game score updates (CS2 round wins, LoL kills, etc.)
            if random.random() < 0.3:
                if random.random() < 0.5:
                    m["homeScore"] = m.get("homeScore",0) + 1
                else:
                    m["awayScore"] = m.get("awayScore",0) + 1

            if m["_elapsed"] >= dur:
                m["_elapsed"] = 0
                # Move to next stage if exists
                stages = m.get("_stages", [])
                cur = m.get("minuteStr","")
                if cur in stages:
                    idx = stages.index(cur)
                    if idx+1 < len(stages):
                        nxt = stages[idx+1]
                        m["minuteStr"] = nxt
                        m["period"] = nxt
                    else:
                        # last stage finished
                        m["isLive"] = False

with _esim_lock:
    _esim_matches = _init_esports_sim()

# ═══════════════════════════════════════════════════════
#  REAL-PLAYER SIMULATIONS for sports without ESPN data
# ═══════════════════════════════════════════════════════
_othersim_matches = []
_othersim_lock = threading.Lock()

def _init_other_sims():
    matches = []
    now = datetime.now(timezone.utc)

    # ── Tennis (ATP/WTA top players, current season) ──────
    atp_players = [
        ("Carlos Alcaraz","🇪🇸"),("Jannik Sinner","🇮🇹"),("Novak Djokovic","🇷🇸"),
        ("Daniil Medvedev","🇷🇺"),("Alexander Zverev","🇩🇪"),("Andrey Rublev","🇷🇺"),
        ("Stefanos Tsitsipas","🇬🇷"),("Casper Ruud","🇳🇴"),("Hubert Hurkacz","🇵🇱"),
        ("Taylor Fritz","🇺🇸"),("Holger Rune","🇩🇰"),("Grigor Dimitrov","🇧🇬"),
    ]
    wta_players = [
        ("Iga Swiatek","🇵🇱"),("Aryna Sabalenka","🇧🇾"),("Coco Gauff","🇺🇸"),
        ("Elena Rybakina","🇰🇿"),("Jessica Pegula","🇺🇸"),("Ons Jabeur","🇹🇳"),
        ("Karolina Muchova","🇨🇿"),("Maria Sakkari","🇬🇷"),("Qinwen Zheng","🇨🇳"),
        ("Daria Kasatkina","🇷🇺"),
    ]
    tennis_events = [
        ("ATP — Roland Garros", atp_players, "🇫🇷", "Франц"),
        ("ATP — Madrid Open",  atp_players, "🇪🇸", "Испани"),
        ("ATP — Rome Masters", atp_players, "🇮🇹", "Итали"),
        ("WTA — Roland Garros", wta_players, "🇫🇷", "Франц"),
        ("WTA — Madrid Open",  wta_players, "🇪🇸", "Испани"),
    ]
    for league, pool, flag, country in tennis_events:
        random.shuffle(pool)
        for i in range(0, min(6, len(pool)-1), 2):
            h, hf = pool[i]; a, af = pool[i+1]
            is_live = random.random() < 0.5
            sets_h = random.randint(0,2) if is_live else 0
            sets_a = random.randint(0,2) if is_live else 0
            cur_set = sets_h + sets_a + 1 if is_live else 0
            mid = f"tsim_{league}_{h}_{a}".replace(" ","_").replace("—","").lower()
            mkts = [
                {"id":f"{mid}_ml","name":"Ялагч","options":[
                    {"label":h.split()[-1],"odds":round(random.uniform(1.4,3.0),2)},
                    {"label":a.split()[-1],"odds":round(random.uniform(1.4,3.0),2)},
                ]},
                {"id":f"{mid}_sets","name":"Нийт сет 3.5","options":[
                    {"label":"Дээш","odds":1.85},{"label":"Доош","odds":1.95},
                ]},
            ]
            matches.append({
                "id":mid,"sportId":"tennis","league":league,
                "country":country,"countryFlag":flag,
                "homeTeam":h,"awayTeam":a,
                "homeLogo": flag_logo(hf) or gen_logo(h, "1e5a99"),
                "awayLogo": flag_logo(af) or gen_logo(a, "ff6b00"),
                "isLive":is_live,
                "homeScore":sets_h,"awayScore":sets_a,
                "minute":0,
                "minuteStr":f"Сет {cur_set}" if is_live else None,
                "period":f"Сет {cur_set}" if is_live else None,
                "_startOffset": 0 if is_live else random.uniform(2,12)*3600,
                "totalMarkets": 25 + random.randint(5,20),
                "markets": mkts,
            })

    # ── MMA / UFC ────────────────────────────────────
    mma_fighters = [
        ("Islam Makhachev","🇷🇺"),("Alex Pereira","🇧🇷"),("Jon Jones","🇺🇸"),
        ("Leon Edwards","🏴󠁧󠁢󠁥󠁮󠁧󠁿"),("Sean Strickland","🇺🇸"),("Charles Oliveira","🇧🇷"),
        ("Ilia Topuria","🇪🇸"),("Max Holloway","🇺🇸"),("Dustin Poirier","🇺🇸"),
        ("Sean O'Malley","🇺🇸"),("Merab Dvalishvili","🇬🇪"),("Khamzat Chimaev","🇸🇪"),
    ]
    mma_events = [("UFC 305", "🇦🇺", "Австрали"), ("UFC Fight Night", "🇺🇸", "АНУ")]
    for league, flag, country in mma_events:
        random.shuffle(mma_fighters)
        for i in range(0, 6, 2):
            h,hf = mma_fighters[i]; a,af = mma_fighters[i+1]
            is_live = (i==0 and random.random()<0.4)
            mid = f"msim_{league}_{h}_{a}".replace(" ","_").lower()
            ph = round(random.uniform(1.5,2.8),2); pa = round(random.uniform(1.5,2.8),2)
            mkts = [
                {"id":f"{mid}_ml","name":"Ялагч","options":[
                    {"label":h.split()[-1],"odds":ph},{"label":a.split()[-1],"odds":pa},
                ]},
                {"id":f"{mid}_method","name":"Ялалтын арга","options":[
                    {"label":"KO/TKO","odds":2.10},{"label":"Submission","odds":4.50},{"label":"Decision","odds":2.40},
                ]},
                {"id":f"{mid}_rounds","name":"Тулааны үргэлжлэх 2.5","options":[
                    {"label":"Дээш","odds":1.85},{"label":"Доош","odds":1.95},
                ]},
            ]
            rnd = random.randint(1,3) if is_live else 0
            matches.append({
                "id":mid,"sportId":"mma","league":league,
                "country":country,"countryFlag":flag,
                "homeTeam":h,"awayTeam":a,
                "homeLogo": flag_logo(hf) or gen_logo(h, "e53935"),
                "awayLogo": flag_logo(af) or gen_logo(a, "1e5a99"),
                "isLive":is_live,"homeScore":0,"awayScore":0,
                "minute":0,
                "minuteStr":f"Раунд {rnd}" if is_live else None,
                "period":f"Раунд {rnd}" if is_live else None,
                "_startOffset": 0 if is_live else random.uniform(3,48)*3600,
                "totalMarkets": 18,
                "markets": mkts,
            })

    # ── Volleyball (FIVB Nations League) ──────────────
    vb_teams = [("Италийн","🇮🇹"),("Польшийн","🇵🇱"),("Бразилын","🇧🇷"),
                ("Францын","🇫🇷"),("Японы","🇯🇵"),("АНУ-ын","🇺🇸"),
                ("Серби","🇷🇸"),("Слови","🇸🇮"),("Кубын","🇨🇺"),("Аргентин","🇦🇷")]
    random.shuffle(vb_teams)
    for i in range(0, 6, 2):
        h,hf = vb_teams[i]; a,af = vb_teams[i+1]
        is_live = i<=2
        sets_h = random.randint(0,3) if is_live else 0
        sets_a = random.randint(0,3) if is_live else 0
        mid = f"vsim_{h}_{a}".replace(" ","_").lower()
        ph = round(random.uniform(1.5,2.5),2); pa = round(random.uniform(1.5,2.5),2)
        matches.append({
            "id":mid,"sportId":"volleyball","league":"FIVB Nations League 2025",
            "country":"Олон улс","countryFlag":"🌍",
            "homeTeam":f"{h} баг","awayTeam":f"{a} баг",
            "homeLogo": flag_logo(hf) or gen_logo(h, "1e5a99"),
            "awayLogo": flag_logo(af) or gen_logo(a, "ff6b00"),
            "isLive":is_live,"homeScore":sets_h,"awayScore":sets_a,
            "minute":0,
            "minuteStr":f"Сет {sets_h+sets_a+1}" if is_live else None,
            "period":f"Сет {sets_h+sets_a+1}" if is_live else None,
            "_startOffset": 0 if is_live else random.uniform(2,24)*3600,
            "totalMarkets": 15,
            "markets":[
                {"id":f"{mid}_ml","name":"Ялагч","options":[
                    {"label":"1","odds":ph},{"label":"2","odds":pa},
                ]},
                {"id":f"{mid}_sets","name":"Нийт сет 4.5","options":[
                    {"label":"Дээш","odds":1.92},{"label":"Доош","odds":1.88},
                ]},
            ],
        })

    # ── Table Tennis (WTT Champions) ─────────────────
    tt_players = [("Fan Zhendong","🇨🇳"),("Wang Chuqin","🇨🇳"),("Tomokazu Harimoto","🇯🇵"),
                  ("Hugo Calderano","🇧🇷"),("Dimitrij Ovtcharov","🇩🇪"),("Truls Möregårdh","🇸🇪"),
                  ("Lin Yun-Ju","🇹🇼"),("Patrick Franziska","🇩🇪"),("Liang Jingkun","🇨🇳"),("Anton Källberg","🇸🇪")]
    random.shuffle(tt_players)
    for i in range(0, 6, 2):
        h,hf = tt_players[i]; a,af = tt_players[i+1]
        is_live = i<=2
        sh = random.randint(0,3) if is_live else 0
        sa = random.randint(0,3) if is_live else 0
        mid = f"ttsim_{h}_{a}".replace(" ","_").lower()
        ph = round(random.uniform(1.4,2.6),2); pa = round(random.uniform(1.4,2.6),2)
        matches.append({
            "id":mid,"sportId":"tabletennis","league":"WTT Champions",
            "country":"Олон улс","countryFlag":"🌍",
            "homeTeam":h,"awayTeam":a,
            "homeLogo": flag_logo(hf) or gen_logo(h, "e53935"),
            "awayLogo": flag_logo(af) or gen_logo(a, "1e5a99"),
            "isLive":is_live,"homeScore":sh,"awayScore":sa,
            "minute":0,
            "minuteStr":f"Тоглолт {sh+sa+1}" if is_live else None,
            "period":f"Тоглолт {sh+sa+1}" if is_live else None,
            "_startOffset": 0 if is_live else random.uniform(1,8)*3600,
            "totalMarkets": 12,
            "markets":[
                {"id":f"{mid}_ml","name":"Ялагч","options":[
                    {"label":h.split()[-1],"odds":ph},{"label":a.split()[-1],"odds":pa},
                ]},
            ],
        })

    # ── Badminton (BWF World Tour) ──────────────────
    bd_players = [("Viktor Axelsen","🇩🇰"),("Anders Antonsen","🇩🇰"),("Kunlavut Vitidsarn","🇹🇭"),
                  ("Shi Yuqi","🇨🇳"),("Anthony Ginting","🇮🇩"),("Jonatan Christie","🇮🇩"),
                  ("Loh Kean Yew","🇸🇬"),("Lakshya Sen","🇮🇳"),("Lee Zii Jia","🇲🇾"),("Chou Tien-chen","🇹🇼")]
    random.shuffle(bd_players)
    for i in range(0, 4, 2):
        h,hf = bd_players[i]; a,af = bd_players[i+1]
        is_live = i==0
        mid = f"bdsim_{h}_{a}".replace(" ","_").lower()
        ph = round(random.uniform(1.3,2.5),2); pa = round(random.uniform(1.3,2.5),2)
        matches.append({
            "id":mid,"sportId":"badminton","league":"BWF World Tour Finals",
            "country":"Олон улс","countryFlag":"🌍",
            "homeTeam":h,"awayTeam":a,
            "homeLogo": flag_logo(hf) or gen_logo(h, "22b14c"),
            "awayLogo": flag_logo(af) or gen_logo(a, "1e5a99"),
            "isLive":is_live,"homeScore":random.randint(0,2) if is_live else 0,
            "awayScore":random.randint(0,2) if is_live else 0,
            "minute":0,"minuteStr":"Game 2" if is_live else None,
            "period":"Game 2" if is_live else None,
            "_startOffset": 0 if is_live else random.uniform(1,6)*3600,
            "totalMarkets": 10,
            "markets":[
                {"id":f"{mid}_ml","name":"Ялагч","options":[
                    {"label":h.split()[-1],"odds":ph},{"label":a.split()[-1],"odds":pa},
                ]},
            ],
        })

    return matches

with _othersim_lock:
    _othersim_matches = _init_other_sims()

# ═══════════════════════════════════════════════════════
#  GUARANTEED LIVE GENERATOR — fills gaps so every sport has live action
# ═══════════════════════════════════════════════════════
LIVE_FILLER_TEAMS = {
    "football": [
        ("Manchester United","Chelsea","Premier League","Англи","🏴󠁧󠁢󠁥󠁮󠁧󠁿"),
        ("Real Madrid","Barcelona","La Liga","Испани","🇪🇸"),
        ("Bayern Munich","Borussia Dortmund","Bundesliga","Герман","🇩🇪"),
        ("PSG","Marseille","Ligue 1","Франц","🇫🇷"),
        ("Inter Milan","Juventus","Serie A","Итали","🇮🇹"),
        ("Ajax","PSV","Eredivisie","Нидерланд","🇳🇱"),
        ("Boca Juniors","River Plate","Primera División","Аргентин","🇦🇷"),
        ("Flamengo","Palmeiras","Série A","Бразил","🇧🇷"),
    ],
    "basketball": [
        ("Boston Celtics","LA Lakers","NBA","АНУ","🇺🇸"),
        ("Golden State Warriors","Miami Heat","NBA","АНУ","🇺🇸"),
        ("Denver Nuggets","Phoenix Suns","NBA","АНУ","🇺🇸"),
        ("New York Knicks","Philadelphia 76ers","NBA Playoffs","АНУ","🇺🇸"),
        ("Milwaukee Bucks","Dallas Mavericks","NBA","АНУ","🇺🇸"),
    ],
    "hockey": [
        ("Toronto Maple Leafs","Montreal Canadiens","NHL Playoffs","Канад","🇨🇦"),
        ("Boston Bruins","New York Rangers","NHL Playoffs","АНУ","🇺🇸"),
        ("Edmonton Oilers","Calgary Flames","NHL Playoffs","Канад","🇨🇦"),
        ("Tampa Bay Lightning","Florida Panthers","NHL","АНУ","🇺🇸"),
    ],
    "baseball": [
        ("New York Yankees","Boston Red Sox","MLB","АНУ","🇺🇸"),
        ("LA Dodgers","San Francisco Giants","MLB","АНУ","🇺🇸"),
        ("Chicago Cubs","St. Louis Cardinals","MLB","АНУ","🇺🇸"),
        ("Houston Astros","Texas Rangers","MLB","АНУ","🇺🇸"),
    ],
    "americanfootball": [
        ("Kansas City Chiefs","Buffalo Bills","NFL","АНУ","🇺🇸"),
        ("San Francisco 49ers","Dallas Cowboys","NFL","АНУ","🇺🇸"),
        ("Philadelphia Eagles","Green Bay Packers","NFL","АНУ","🇺🇸"),
    ],
}

def gen_live_filler(sport, count):
    """Generate live sim matches for a sport when ESPN data is sparse."""
    teams = LIVE_FILLER_TEAMS.get(sport, [])
    if not teams: return []
    out = []
    pool = list(teams); random.shuffle(pool)
    for i in range(min(count, len(pool))):
        h, a, league, country, flag = pool[i]
        # Realistic live scores per sport
        if sport == "football":
            hs = random.randint(0,3); as_ = random.randint(0,3)
            minute = random.randint(15,85)
            minute_str = f"{minute}'"
            period = "1-р хагас" if minute<=45 else "2-р хагас"
            mkts = soccer_markets(f"lf_{sport}_{i}", h, a, hs, as_, minute, True)
        elif sport == "basketball":
            hs = random.randint(45,110); as_ = random.randint(45,110)
            q = random.randint(2,4)
            minute_str = f"Q{q} {random.randint(1,12)}:00"
            period = f"Q{q}"
            mkts = bball_markets(f"lf_{sport}_{i}", h, a)
            minute = 0
        elif sport == "hockey":
            hs = random.randint(0,5); as_ = random.randint(0,5)
            p = random.randint(1,3)
            minute_str = f"P{p} {random.randint(1,20)}:00"
            period = f"P{p}"
            mkts = hockey_markets(f"lf_{sport}_{i}", h, a)
            minute = 0
        elif sport == "baseball":
            hs = random.randint(0,8); as_ = random.randint(0,8)
            inning = random.randint(2,9)
            minute_str = f"{inning}-р инниг"
            period = minute_str
            mkts = baseball_markets(f"lf_{sport}_{i}", h, a)
            minute = 0
        elif sport == "americanfootball":
            hs = random.randint(0,28); as_ = random.randint(0,28)
            q = random.randint(1,4)
            minute_str = f"Q{q} {random.randint(1,15)}:00"
            period = f"Q{q}"
            mkts = bball_markets(f"lf_{sport}_{i}", h, a)
            minute = 0
        else:
            continue
        out.append({
            "id": f"livefill_{sport}_{i}", "sportId": sport,
            "league": league, "country": country, "countryFlag": flag,
            "homeTeam": h, "awayTeam": a,
            "homeLogo": gen_logo(h, "1e5a99"),
            "awayLogo": gen_logo(a, "ff6b00"),
            "isLive": True, "homeScore": hs, "awayScore": as_,
            "minute": minute, "minuteStr": minute_str, "period": period,
            "startTime": datetime.now(timezone.utc).isoformat(),
            "totalMarkets": len(mkts)*8 + random.randint(20,40),
            "markets": mkts,
        })
    return out

# ═══════════════════════════════════════════════════════
#  REAL ODDS — The Odds API overlay
# ═══════════════════════════════════════════════════════
_odds_cache={}; _odds_lock=threading.Lock()
ODDS_SPORTS=["soccer_epl","soccer_spain_la_liga","soccer_italy_serie_a",
             "soccer_germany_bundesliga","soccer_uefa_champs_league",
             "basketball_nba","baseball_mlb","icehockey_nhl",
             "esports_cs2","esports_lol","esports_dota_2","esports_valorant"]

def fetch_real_odds():
    if not ODDS_API_KEY: return
    for sport in ODDS_SPORTS:
        try:
            r=req.get(f"https://api.the-odds-api.com/v4/sports/{sport}/odds/",
                      params={"apiKey":ODDS_API_KEY,"regions":"eu",
                              "markets":"h2h,totals","oddsFormat":"decimal"},timeout=8)
            if r.status_code!=200: continue
            for game in r.json():
                key=f"{game['home_team']}_{game['away_team']}".lower().replace(" ","_")
                bk=game.get("bookmakers",[])
                if not bk: continue
                mkts=[]
                for m in bk[0].get("markets",[]):
                    if m["key"]=="h2h":
                        opts=[{"label":o["name"].split()[-1],"odds":round(o["price"],2)} for o in m["outcomes"]]
                        mkts.append({"id":f"odds_{key}_h2h","name":"1X2","options":opts})
                    elif m["key"]=="totals":
                        ov=next((o["price"] for o in m["outcomes"] if o["name"]=="Over"),2.0)
                        un=next((o["price"] for o in m["outcomes"] if o["name"]=="Under"),2.0)
                        pt=m["outcomes"][0].get("point",2.5)
                        mkts.append({"id":f"odds_{key}_ou","name":f"Нийт {pt}",
                                     "options":[{"label":"Дээш","odds":round(ov,2)},{"label":"Доош","odds":round(un,2)}]})
                with _odds_lock: _odds_cache[key]=mkts
        except Exception as ex:
            print(f"Odds API err ({sport}): {ex}")

# ═══════════════════════════════════════════════════════
#  MAIN CACHE & BACKGROUND REFRESH
# ═══════════════════════════════════════════════════════
_cache={"events":[],"ts":0}
_cache_lock=threading.Lock()

def _event_key(h,a):
    return f"{h}_{a}".lower().replace(" ","_")

def refresh_all():
    events=[]
    # 1. ESPN (all sports)
    for src in ESPN_SOURCES:
        try:
            r=req.get(f"https://site.api.espn.com/apis/site/v2/sports/{src['path']}/scoreboard",timeout=6)
            if r.status_code!=200: continue
            for ev in r.json().get("events",[]):
                p=parse_espn(ev,src)
                if p:
                    key=_event_key(p["homeTeam"],p["awayTeam"])
                    with _odds_lock:
                        real=_odds_cache.get(key)
                    if real:
                        p["markets"]=real+p["markets"][len(real):]
                    events.append(p)
        except Exception as ex:
            print(f"ESPN err ({src['league']}): {ex}")

    # 2. PandaScore esports (if key set)
    if PANDASCORE_KEY:
        events += fetch_pandascore()
    else:
        # Esports simulation
        _update_esports_sim()
        with _esim_lock:
            for m in _esim_matches:
                off=m.get("_startOffset",0)
                start_ts=time.time() + (0 if m["isLive"] else off)
                start_iso=datetime.fromtimestamp(start_ts,tz=timezone.utc).isoformat()
                events.append({**{k:v for k,v in m.items() if not k.startswith("_")},"startTime":start_iso})

    # 3. Other-sport simulations (tennis/MMA/volleyball/tabletennis/badminton)
    with _othersim_lock:
        for m in _othersim_matches:
            off=m.get("_startOffset",0)
            start_ts=time.time() + (0 if m["isLive"] else off)
            start_iso=datetime.fromtimestamp(start_ts,tz=timezone.utc).isoformat()
            events.append({**{k:v for k,v in m.items() if not k.startswith("_")},"startTime":start_iso})

    # 4. Live-gap filler — guarantee at least 4 live matches per major sport
    MIN_LIVE = 4
    for sport in ["football","basketball","hockey","baseball","americanfootball"]:
        live_count = sum(1 for e in events if e["sportId"]==sport and e["isLive"])
        if live_count < MIN_LIVE:
            events += gen_live_filler(sport, MIN_LIVE - live_count)

    with _cache_lock:
        _cache["events"]=events
        _cache["ts"]=time.time()
    print(f"Refresh: {len(events)} events (live={sum(1 for e in events if e['isLive'])}) | ESPN+{'PandaScore' if PANDASCORE_KEY else 'EsimSim'} | Odds={'real' if ODDS_API_KEY else 'generated'}")

def _bg():
    refresh_all(); fetch_real_odds()
    odds_t=time.time()
    sim_t=time.time()
    while True:
        time.sleep(60)
        refresh_all()
        if time.time()-odds_t>600:
            fetch_real_odds(); odds_t=time.time()
        # Reshuffle other-sport sim every 30 minutes
        if time.time()-sim_t>1800:
            global _othersim_matches
            with _othersim_lock:
                _othersim_matches = _init_other_sims()
            sim_t=time.time()

threading.Thread(target=_bg, daemon=True).start()

# ═══════════════════════════════════════════════════════
#  USERS & AUTH
# ═══════════════════════════════════════════════════════
import hashlib, secrets

users = {}      # username -> {pw_hash, balance, transactions, created}
sessions = {}   # token -> username
users_lock = threading.Lock()

def hash_pw(pw):
    return hashlib.sha256(pw.encode()).hexdigest()

def get_user_from_token(token):
    if not token: return None
    return sessions.get(token)

def now_iso(): return datetime.now(timezone.utc).isoformat()

# default guest user (for backward compat with existing balance/tx endpoints)
GUEST = "_guest_"
users[GUEST] = {"pw_hash": "", "balance": 50000.0, "transactions": [], "created": now_iso()}

bal_lock = threading.Lock()

def _user_for_request():
    """Returns username; falls back to guest if no session."""
    token = request.headers.get("X-Session-Token", "")
    u = get_user_from_token(token)
    return u if u and u in users else GUEST

# ═══════════════════════════════════════════════════════
#  API ROUTES
# ═══════════════════════════════════════════════════════
@app.route("/api/health")
def health():
    with _cache_lock:
        cnt=len(_cache["events"])
        live=sum(1 for e in _cache["events"] if e["isLive"])
    return jsonify({"status":"ok","events":cnt,"live":live,"updatedAt":now_iso(),
                    "realOdds":bool(ODDS_API_KEY),"realEsports":bool(PANDASCORE_KEY)})

@app.route("/api/register", methods=["POST"])
def register():
    data = request.get_json() or {}
    username = (data.get("username") or "").strip()
    password = data.get("password") or ""
    if len(username) < 3: return jsonify({"error":"Хэрэглэгчийн нэр 3+ тэмдэгт байх ёстой"}), 400
    if len(password) < 4: return jsonify({"error":"Нууц үг 4+ тэмдэгт байх ёстой"}), 400
    with users_lock:
        if username in users: return jsonify({"error":"Энэ нэр аль хэдийн бүртгэгдсэн"}), 400
        users[username] = {
            "pw_hash": hash_pw(password),
            "balance": 50000.0,  # шинэ хэрэглэгчид 50,000₮ урамшуулал
            "transactions": [{"id":f"tx_{int(time.time()*1000)}","type":"bonus","amount":50000,
                              "balance":50000,"timestamp":now_iso(),"note":"Шинэ хэрэглэгчийн бонус"}],
            "created": now_iso(),
        }
        token = secrets.token_urlsafe(32)
        sessions[token] = username
    return jsonify({"success":True,"token":token,"username":username,"balance":50000.0})

@app.route("/api/login", methods=["POST"])
def login():
    data = request.get_json() or {}
    username = (data.get("username") or "").strip()
    password = data.get("password") or ""
    with users_lock:
        u = users.get(username)
        if not u or u["pw_hash"] != hash_pw(password):
            return jsonify({"error":"Нэр эсвэл нууц үг буруу"}), 401
        token = secrets.token_urlsafe(32)
        sessions[token] = username
    return jsonify({"success":True,"token":token,"username":username,"balance":u["balance"]})

@app.route("/api/logout", methods=["POST"])
def logout():
    token = request.headers.get("X-Session-Token", "")
    sessions.pop(token, None)
    return jsonify({"success":True})

@app.route("/api/me")
def me():
    uname = _user_for_request()
    u = users[uname]
    return jsonify({"username": uname if uname != GUEST else None,
                    "balance": u["balance"],
                    "guest": uname == GUEST})

@app.route("/api/balance")
def get_balance():
    uname = _user_for_request()
    return jsonify({"balance": users[uname]["balance"], "currency":"MNT"})

@app.route("/api/deposit", methods=["POST"])
def deposit():
    uname = _user_for_request()
    data = request.get_json() or {}; amount = data.get("amount")
    if not isinstance(amount,(int,float)) or amount<=0:
        return jsonify({"error":"Буруу дүн"}),400
    if amount>10_000_000: return jsonify({"error":"10,000,000-с ихгүй"}),400
    with bal_lock:
        users[uname]["balance"] += amount
        cur = users[uname]["balance"]
    tx={"id":f"tx_{int(time.time()*1000)}","type":"deposit","amount":amount,
        "balance":cur,"timestamp":now_iso(),"note":"Орц нэмсэн"}
    users[uname]["transactions"].insert(0,tx)
    return jsonify({"success":True,"balance":cur,"amount":amount,"transaction":tx})

@app.route("/api/withdraw", methods=["POST"])
def withdraw():
    uname = _user_for_request()
    data = request.get_json() or {}; amount = data.get("amount")
    if not isinstance(amount,(int,float)) or amount<=0: return jsonify({"error":"Буруу дүн"}),400
    if amount<1000: return jsonify({"error":"Хамгийн багадаа 1,000₮"}),400
    with bal_lock:
        if amount > users[uname]["balance"]:
            return jsonify({"error":"Үлдэгдэл хүрэлцэхгүй"}),400
        users[uname]["balance"] -= amount
        cur = users[uname]["balance"]
    tx={"id":f"tx_{int(time.time()*1000)}","type":"withdraw","amount":amount,
        "balance":cur,"timestamp":now_iso(),"note":"Гарц авсан"}
    users[uname]["transactions"].insert(0,tx)
    return jsonify({"success":True,"balance":cur,"amount":amount,"transaction":tx})

@app.route("/api/transactions")
def get_tx():
    uname = _user_for_request()
    return jsonify({"transactions": users[uname]["transactions"][:50]})

@app.route("/api/live-events")
def get_live():
    with _cache_lock: live=[e for e in _cache["events"] if e["isLive"]]
    return jsonify({"events":live,"count":len(live),"updatedAt":now_iso()})

@app.route("/api/upcoming-events")
def get_upcoming():
    sport=request.args.get("sport")
    with _cache_lock: evs=[e for e in _cache["events"] if not e["isLive"]]
    if sport: evs=[e for e in evs if e["sportId"]==sport]
    return jsonify({"events":evs,"count":len(evs)})

@app.route("/api/events")
def get_all():
    sport=request.args.get("sport")
    with _cache_lock: evs=list(_cache["events"])
    if sport: evs=[e for e in evs if e["sportId"]==sport]
    return jsonify({"events":evs,"count":len(evs),"updatedAt":now_iso()})

@app.route("/api/refresh", methods=["POST"])
def force_refresh():
    threading.Thread(target=refresh_all,daemon=True).start()
    return jsonify({"ok":True})

# ═══════════════════════════════════════════════════════
#  STATIC FILES  (MUST be last)
# ═══════════════════════════════════════════════════════
@app.route('/')
def index(): return app.send_static_file('index.html')

@app.route('/<path:path>')
def static_files(path):
    try: return app.send_static_file(path)
    except: return app.send_static_file('index.html')

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 3001))
    print("\nSportBet MN — Multi-source backend")
    print(f"  ESPN:    бодит score (15+ спорт, key хэрэггүй)")
    print(f"  Esports: {'PandaScore бодит' if PANDASCORE_KEY else 'Simulation'}")
    print(f"  Odds:    {'The Odds API бодит' if ODDS_API_KEY else 'Generated'}")
    print(f"  http://0.0.0.0:{port}\n")
    app.run(host="0.0.0.0", port=port, debug=False, threaded=True)
