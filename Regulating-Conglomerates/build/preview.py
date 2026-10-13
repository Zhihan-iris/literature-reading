# -*- coding: utf-8 -*-
"""Render the same SLIDES spec as HTML at 96 dpi so the pptx layout can be
eyeballed in Chrome before shipping."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from build_ppt import SLIDES, ASSETS, fit_image

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "preview")
os.makedirs(OUT, exist_ok=True)
PX = 96.0


def hexc(c):
    if isinstance(c, str):
        return c
    return "#%02X%02X%02X" % (c[0], c[1], c[2])


def box(v):
    return v * PX


def esc(s):
    return (str(s).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"))


def render_block(b, img_src=None):
    k = b["kind"]
    x, y, w, h = b["x"], b["y"], b["w"], b["h"]
    base = ("position:absolute;left:%.2fpx;top:%.2fpx;width:%.2fpx;height:%.2fpx;"
            % (box(x), box(y), box(w), box(h)))

    if k == "txt":
        runs = b["runs"]
        if isinstance(runs, str):
            runs = [(runs, b["bold"], b["color"], b["size"])]
        al = {"l": "left", "c": "center", "r": "right"}[b["align"]]
        inner = ""
        for t, bd, col, sz in runs:
            seg = esc(t).replace("\n", "<br>")
            inner += ("<span style='font-size:%.2fpx;color:%s;font-weight:%s'>%s</span>"
                      % (sz * PX / 72, hexc(col), "700" if bd else "400", seg))
        return ("<div style='%s;text-align:%s;line-height:%.2f;font-family:%s'>%s</div>"
                % (base, al, b["spacing"], "'PingFang SC',sans-serif", inner))

    if k == "bul":
        out = "<div style='%s'>" % base
        for it in b["items"]:
            out += ("<div style=\"padding-left:15px;text-indent:-15px;"
                    "margin-bottom:%.2fpx;font-size:%.2fpx;line-height:%.2f\">"
                    "<span style='color:#999'>·</span> %s</div>"
                    % (b["gap"], b["size"] * PX / 72, b["spacing"], esc(it)))
        return out + "</div>"

    if k == "eq":
        al = {"l": "left", "c": "center", "r": "right"}[b["align"]]
        lines = "".join("<div>%s</div>" % esc(l) for l in b["lines"])
        return ("<div style='%s;background:#F6F7F9;border:1px solid #DDE2E8;"
                "display:flex;flex-direction:column;justify-content:center;"
                "padding:0 11px;box-sizing:border-box;text-align:%s;"
                "font-family:Georgia,serif;font-size:%.2fpx;color:%s;"
                "line-height:1.28'>%s</div>"
                % (base, al, b["size"] * PX / 72, hexc(b["color"]), lines))

    if k == "co":
        lines = "".join("<div>%s</div>" % esc(l) for l in b["text"].split("\n"))
        return ("<div style='%s;background:%s;border:1px solid #E8C9CE;"
                "border-left:4px solid %s;display:flex;flex-direction:column;"
                "justify-content:center;padding:0 14px 0 15px;box-sizing:border-box;"
                "font-size:%.2fpx;line-height:1.30'>%s</div>"
                % (base, hexc(b["fill"]), hexc("#A6192E"),
                   b["size"] * PX / 72, lines))

    if k in ("box", "g4"):
        items = b["items"]
        gap = b["gap"]
        if k == "box":
            n = len(items)
            bw = (w - gap * (n - 1)) / n
            cells = []
            for i, (hd, bd) in enumerate(items):
                cells.append((x + i * (bw + gap), y, bw, h, hd, bd))
        else:
            bw = (w - gap) / 2
            bh = (h - gap) / 2
            cells = [(x + (i % 2) * (bw + gap), y + (i // 2) * (bh + gap),
                      bw, bh, hd, bd) for i, (hd, bd) in enumerate(items)]
        out = ""
        for cx, cy, cw, ch, hd, bd in cells:
            out += ("<div style='position:absolute;left:%.2fpx;top:%.2fpx;"
                    "width:%.2fpx;height:%.2fpx;background:#F8F8F6;"
                    "border:1px solid #D8D8D8;box-sizing:border-box;"
                    "padding:9px 12px 0 12px'>"
                    "<div style='color:#A6192E;font-weight:700;font-size:%.2fpx;"
                    "margin-bottom:5px'>%s</div>"
                    "<div style='font-size:%.2fpx;line-height:1.32'>%s</div></div>"
                    % (box(cx), box(cy), box(cw), box(ch),
                       b["size"] * PX / 72, esc(hd),
                       (b["size"] - (1 if k == "box" else 1.5)) * PX / 72, esc(bd)))
        return out

    if k == "kv":
        out = "<div style='%s'>" % base
        out += ("<div style='color:%s;font-weight:700;font-size:%.2fpx;"
                "margin-bottom:5px'>%s</div>"
                % (hexc(b["accent"]), (b["size"] + 1.5) * PX / 72, esc(b["heading"])))
        for lab, val in b["items"]:
            out += ("<div style='font-size:%.2fpx;line-height:1.28;"
                    "margin-bottom:%.2fpx'><b>%s</b>%s</div>"
                    % (b["size"] * PX / 72, b["gap"], esc(lab), esc(val)))
        return out + "</div>"

    if k == "kpi":
        n = len(b["items"]); gap = b["gap"]
        cw = (w - gap * (n - 1)) / n
        out = ""
        for i, (num, lab, hl) in enumerate(b["items"]):
            cx = x + i * (cw + gap)
            bg = "#FCF3F4" if hl else "#F7F7F5"
            bd = "#E8C9CE" if hl else "#D8D8D8"
            col = "#A6192E" if hl else "#1F3A5F"
            fs = 30 if len(num) <= 8 else 24
            out += ("<div style='position:absolute;left:%.2fpx;top:%.2fpx;"
                    "width:%.2fpx;height:%.2fpx;background:%s;border:1px solid %s;"
                    "box-sizing:border-box;display:flex;flex-direction:column;"
                    "align-items:center;justify-content:center;text-align:center'>"
                    "<div style='font-family:Georgia,serif;font-weight:700;"
                    "font-size:%.2fpx;color:%s'>%s</div>"
                    "<div style='font-size:%.2fpx;margin-top:3px'>%s</div></div>"
                    % (box(cx), box(y), box(cw), box(h), bg, bd,
                       fs * PX / 72, col, esc(num), 12 * PX / 72, esc(lab)))
        return out

    if k == "tbl":
        data = b["data"]
        cws = b["col_w"] or [w / len(data[0])] * len(data[0])
        pct = [c / sum(cws) * 100 for c in cws]
        out = "<table style='border-collapse:collapse;table-layout:fixed;%s'>" % base
        out += "<colgroup>" + "".join("<col style='width:%.3f%%'>" % p for p in pct) + "</colgroup>"
        for ri, row in enumerate(data):
            out += "<tr style='height:%.2fpx'>" % box(b["row_h"])
            for ci, val in enumerate(row):
                hd = b["header"] and ri == 0
                em = b["emphase"].get((ri, ci))
                bg = "#1F3A5F" if hd else "#FAFAF8"
                col = "#FFFFFF" if hd else ("#A6192E" if em else "#1A1A1A")
                wt = "700" if (hd or em) else ("700" if str(val).startswith(("A.", "B.", "C.")) else "400")
                bord = "border-bottom:1px solid " + ("#1F3A5F" if hd else "#E8E8E6")
                out += ("<td style='background:%s;color:%s;font-weight:%s;%s;"
                        "font-size:%.2fpx;padding:3px 7px;vertical-align:middle;"
                        "line-height:1.16;box-sizing:border-box'>%s</td>"
                        % (bg, col, wt, bord, b["size"] * PX / 72, esc(val)))
            out += "</tr>"
        return out + "</table>"

    if k == "img":
        ip = os.path.join(ASSETS, b["name"])
        src = img_src(b["name"]) if img_src else "file://" + ip
        caph = 0.58 if b["caption"] else 0
        iw, ih = fit_image(ip, w, h - caph)
        px = x + (w - iw) / 2
        out = ("<img src='%s' style='position:absolute;left:%.2fpx;top:%.2fpx;"
               "width:%.2fpx;height:%.2fpx;border:1px solid #D8D8D8;box-sizing:border-box'>"
               % (src, box(px), box(y), box(iw), box(ih)))
        if b["caption"]:
            out += ("<div style='position:absolute;left:%.2fpx;top:%.2fpx;"
                    "width:%.2fpx;font-size:%.2fpx;color:#767676;line-height:1.22'>%s</div>"
                    % (box(x), box(y + ih + 0.07), box(w),
                       b["cap_size"] * PX / 72, esc(b["caption"])))
        return out

    if k == "row":
        n = len(b["items"]); gap = b["gap"]
        cw = (w - gap * (n - 1)) / n
        caph = 0.62
        out = ""
        for i, (name, cap) in enumerate(b["items"]):
            bx = x + i * (cw + gap)
            ip = os.path.join(ASSETS, name)
            src = img_src(name) if img_src else "file://" + ip
            iw, ih = fit_image(ip, cw, h - caph)
            out += ("<img src='%s' style='position:absolute;left:%.2fpx;"
                    "top:%.2fpx;width:%.2fpx;height:%.2fpx;"
                    "border:1px solid #D8D8D8;box-sizing:border-box'>"
                    % (src, box(bx + (cw - iw) / 2), box(y), box(iw), box(ih)))
            lines = cap.split("\n")
            inner = ""
            for j, ln in enumerate(lines):
                inner += ("<div style='font-size:%.2fpx;color:%s;font-weight:%s'>%s</div>"
                          % ((b["cap_size"] + (0.5 if j == 0 else 0)) * PX / 72,
                             "#1A1A1A" if j == 0 else "#767676",
                             "700" if j == 0 else "400", esc(ln)))
            out += ("<div style='position:absolute;left:%.2fpx;top:%.2fpx;"
                    "width:%.2fpx;line-height:1.2'>%s</div>"
                    % (box(bx), box(y + ih + 0.07), box(cw), inner))
        return out

    return ""


def render_slide(spec, idx, total, img_src=None):
    hdr = ""
    if spec.get("cover"):
        c = spec["cover"]
        hdr = ("<div style='position:absolute;left:%.2fpx;top:%.2fpx;font-size:%.2fpx;"
               "color:#767676'>%s</div>"
               "<div style='position:absolute;left:%.2fpx;top:%.2fpx;width:%.2fpx;"
               "font-size:%.2fpx;font-weight:700'>%s</div>"
               "<div style='position:absolute;left:%.2fpx;top:%.2fpx;width:%.2fpx;"
               "font-size:%.2fpx;color:#A6192E;font-family:Georgia,serif'>%s</div>"
               "<div style='position:absolute;left:%.2fpx;top:%.2fpx;width:%.2fpx;"
               "font-size:%.2fpx'>%s</div>"
               "<div style='position:absolute;left:%.2fpx;top:%.2fpx;width:%.2fpx;"
               "height:4px;background:#A6192E'></div>"
               "<div style='position:absolute;left:%.2fpx;top:%.2fpx;width:%.2fpx;"
               "font-size:%.2fpx;line-height:1.7'>%s<div style='color:#767676;"
               "margin-top:9px'>%s</div>"
               "<div style='margin-top:9px'>%s</div></div>"
               % (box(1.15), box(0.72), 13 * PX / 72, esc(c["tag"]),
                  box(1.15), box(1.55), box(11.0), 44 * PX / 72, esc(c["cn"]),
                  box(1.15), box(2.85), box(11.0), 26 * PX / 72, esc(c["en"]),
                  box(1.15), box(3.35), box(11.0), 20 * PX / 72, esc(c["sub"]),
                  box(1.15), box(4.62), box(1.35),
                  box(1.15), box(4.98), box(11.0), 15 * PX / 72,
                  "<br>".join(esc(a) for a in c["authors"]), esc(c["journal"]),
                  esc(c["presenter"])))
    else:
        blocks = "".join(render_block(b, img_src) for b in spec["blocks"])
        hdr = (("<div style='position:absolute;left:%.2fpx;top:%.2fpx;font-size:%.2fpx;"
                "color:#767676'>%s</div>"
                "<div style='position:absolute;right:%.2fpx;top:%.2fpx;font-size:%.2fpx;"
                "color:#AAAAAA;font-family:Georgia,serif'>REGULATING CONGLOMERATES · %02d / %d</div>"
                "<div style='position:absolute;left:%.2fpx;top:%.2fpx;width:%.2fpx;"
                "height:0.75in;font-size:%.2fpx;font-weight:700;line-height:1.2'>%s</div>"
                "<div style='position:absolute;left:%.2fpx;top:%.2fpx;width:%.2fpx;"
                "height:4px;background:#A6192E'></div>"
                % (box(0.70), box(0.34), 11.5 * PX / 72, esc(spec["eyebrow"]),
                   box(0.70), box(0.34), 9.5 * PX / 72, idx, total,
                   box(0.70), box(0.66), box(11.93), 27 * PX / 72, esc(spec["title"]),
                   box(0.70), box(1.40), box(1.5))) + blocks)
        hdr += ("<div style='position:absolute;left:%.2fpx;top:%.2fpx;width:%.2fpx;"
                "font-size:%.2fpx;color:#A0A0A0;font-family:Georgia,serif'>"
                "Chen et al. (2025) · AER 115(2): 408–447 · DOI 10.1257/aer.20211455</div>"
                % (box(0.70), box(6.96), box(11.93), 9 * PX / 72))

    return ("<!DOCTYPE html><html><head><meta charset='utf-8'>"
            "<style>*{margin:0;padding:0;box-sizing:border-box}"
            "body{width:%.2fpx;height:%.2fpx;background:#fff;"
            "font-family:'PingFang SC',sans-serif;color:#1A1A1A;position:relative}"
            "</style></head><body>%s</body></html>" % (box(13.3333), box(7.5), hdr))


if __name__ == "__main__":
    for i, spec in enumerate(SLIDES, 1):
        with open(os.path.join(OUT, "%02d.html" % i), "w", encoding="utf-8") as f:
            f.write(render_slide(spec, i, len(SLIDES)))
    print("wrote", len(SLIDES), "preview pages to", OUT)
